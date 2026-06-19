import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/audit_log.dart';
import '../../models/school_class.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class AdminClassesScreen extends StatelessWidget {
  const AdminClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final classes = [...data.classes]
      ..sort((a, b) => a.name.compareTo(b.name));

    return RoleScaffold(
      title: 'Kelas',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Kelas',
            subtitle: '${classes.length} kelas terdaftar',
            action: FilledButton.icon(
              onPressed: () => context.go('/admin/classes/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kelas'),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<SchoolClass>(
                    items: classes,
                    onRowTap: (c) => context.go('/admin/classes/${c.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Kelas',
                        build: (c) => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.class_outlined,
                                  size: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(c.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      AppTableColumn(
                        label: 'Tingkat',
                        build: (c) => Text(c.gradeLevel.isEmpty ? '-' : c.gradeLevel),
                      ),
                      AppTableColumn(
                        label: 'Wali Kelas',
                        build: (c) {
                          final t = c.homeroomTeacherId == null
                              ? null
                              : data.userById(c.homeroomTeacherId!);
                          return Text(t?.name ?? '-');
                        },
                      ),
                      AppTableColumn(
                        label: 'Jumlah Siswa',
                        numeric: true,
                        build: (c) => Text('${c.studentIds.length}'),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, c) =>
                            ctx.go('/admin/classes/${c.id}'),
                      ),
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, c) => _confirmDelete(ctx, c),
                      ),
                    ],
                    emptyIcon: Icons.class_outlined,
                    emptyTitle: 'Belum ada kelas',
                    emptyMessage: 'Mulai dengan membuat kelas baru.',
                    emptyAction: FilledButton.icon(
                      onPressed: () => context.go('/admin/classes/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Kelas'),
                    ),
                  ),
                ),
              ),
              mobile: classes.isEmpty
                  ? EmptyState(
                      icon: Icons.class_outlined,
                      title: 'Belum ada kelas',
                      action: FilledButton.icon(
                        onPressed: () => context.go('/admin/classes/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Kelas'),
                      ),
                    )
                  : PaginatedListView<SchoolClass>(
                      items: classes,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, c, i) {
                        final teacher = c.homeroomTeacherId == null
                            ? null
                            : data.userById(c.homeroomTeacherId!);
                        return Card(
                          child: ListTile(
                            onTap: () => context.go('/admin/classes/${c.id}'),
                            leading: const Icon(Icons.class_outlined),
                            title: Text('${i + 1}. ${c.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                'Tingkat ${c.gradeLevel.isEmpty ? '-' : c.gradeLevel} • ${c.studentIds.length} siswa\nWali: ${teacher?.name ?? '-'}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(context, c),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: MediaQuery.of(context).size.width < 900
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/admin/classes/new'),
              icon: const Icon(Icons.add),
              label: const Text('Kelas'),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, SchoolClass c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus kelas?'),
        content: Text('Kelas ${c.name} akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final data = context.read<DataProvider>();
      final actor = context.read<AuthProvider>().user;
      await data.deleteClass(c.id);
      if (actor != null) {
        await data.recordAudit(
          actor: actor,
          action: AuditAction.classDelete,
          targetType: 'class',
          targetId: c.id,
          targetLabel: c.name,
        );
      }
    }
  }
}
