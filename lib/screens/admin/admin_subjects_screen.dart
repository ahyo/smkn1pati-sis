import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/audit_log.dart';
import '../../models/subject.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class AdminSubjectsScreen extends StatelessWidget {
  const AdminSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final subjects = [...data.subjects]
      ..sort((a, b) => a.name.compareTo(b.name));

    return RoleScaffold(
      title: 'Mata Pelajaran',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Mata Pelajaran',
            subtitle: '${subjects.length} mapel terdaftar',
            action: FilledButton.icon(
              onPressed: () => context.go('/admin/subjects/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Mapel'),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<Subject>(
                    items: subjects,
                    onRowTap: (s) => context.go('/admin/subjects/${s.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Nama',
                        build: (s) => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.menu_book_outlined,
                                  size: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(s.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      AppTableColumn(
                        label: 'Kode',
                        build: (s) => Text(s.code.isEmpty ? '-' : s.code),
                      ),
                      AppTableColumn(
                        label: 'Deskripsi',
                        build: (s) => Text(
                          s.description ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, s) =>
                            ctx.go('/admin/subjects/${s.id}'),
                      ),
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, s) => _confirmDelete(ctx, s),
                      ),
                    ],
                    emptyIcon: Icons.menu_book_outlined,
                    emptyTitle: 'Belum ada mata pelajaran',
                    emptyMessage:
                        'Tambahkan mapel agar guru bisa memakainya untuk materi & ujian.',
                    emptyAction: FilledButton.icon(
                      onPressed: () => context.go('/admin/subjects/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Mapel'),
                    ),
                  ),
                ),
              ),
              mobile: subjects.isEmpty
                  ? EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'Belum ada mapel',
                      action: FilledButton.icon(
                        onPressed: () => context.go('/admin/subjects/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Mapel'),
                      ),
                    )
                  : PaginatedListView<Subject>(
                      items: subjects,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, s, i) {
                        return Card(
                          child: ListTile(
                            onTap: () =>
                                context.go('/admin/subjects/${s.id}'),
                            leading: const Icon(Icons.menu_book_outlined),
                            title: Text('${i + 1}. ${s.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${s.code.isEmpty ? '-' : s.code}${s.description != null ? '\n${s.description}' : ''}'),
                            isThreeLine: s.description != null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(context, s),
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
              onPressed: () => context.go('/admin/subjects/new'),
              icon: const Icon(Icons.add),
              label: const Text('Mapel'),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Subject s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus mata pelajaran?'),
        content: Text('Mapel ${s.name} akan dihapus.'),
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
      await data.deleteSubject(s.id);
      if (actor != null) {
        await data.recordAudit(
          actor: actor,
          action: AuditAction.subjectDelete,
          targetType: 'subject',
          targetId: s.id,
          targetLabel: s.name,
        );
      }
    }
  }
}
