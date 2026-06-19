import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/learning_material.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class TeacherMaterialsScreen extends StatelessWidget {
  const TeacherMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final mine = data.materialsByTeacher(user.id)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final df = DateFormat('dd MMM yyyy', 'id_ID');

    return RoleScaffold(
      title: 'Materi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Materi Pembelajaran',
            subtitle: '${mine.length} materi yang Anda buat',
            action: FilledButton.icon(
              onPressed: () => context.go('/teacher/materials/new'),
              icon: const Icon(Icons.add),
              label: const Text('Buat Materi'),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<LearningMaterial>(
                    items: mine,
                    onRowTap: (m) => context.go('/teacher/materials/${m.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Judul',
                        build: (m) => Text(m.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                      AppTableColumn(
                        label: 'Mapel',
                        build: (m) =>
                            Text(data.subjectById(m.subjectId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Kelas',
                        build: (m) =>
                            Text(data.classById(m.classId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Dibuat',
                        build: (m) => Text(df.format(m.createdAt)),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, m) =>
                            ctx.go('/teacher/materials/${m.id}'),
                      ),
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, m) async {
                          await ctx
                              .read<DataProvider>()
                              .deleteMaterial(m.id);
                        },
                      ),
                    ],
                    emptyIcon: Icons.menu_book_outlined,
                    emptyTitle: 'Belum ada materi',
                    emptyMessage:
                        'Mulai dengan membuat materi pembelajaran pertama Anda.',
                    emptyAction: FilledButton.icon(
                      onPressed: () => context.go('/teacher/materials/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Materi'),
                    ),
                  ),
                ),
              ),
              mobile: mine.isEmpty
                  ? EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'Belum ada materi',
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.go('/teacher/materials/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Materi'),
                      ),
                    )
                  : PaginatedListView<LearningMaterial>(
                      items: mine,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, m, i) {
                        return Card(
                          child: ListTile(
                            onTap: () =>
                                context.go('/teacher/materials/${m.id}'),
                            leading: const Icon(Icons.article_outlined),
                            title: Text('${i + 1}. ${m.title}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${data.subjectById(m.subjectId)?.name ?? '-'} • ${data.classById(m.classId)?.name ?? '-'}\n${df.format(m.createdAt)}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context
                                  .read<DataProvider>()
                                  .deleteMaterial(m.id),
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
              onPressed: () => context.go('/teacher/materials/new'),
              icon: const Icon(Icons.add),
              label: const Text('Materi'),
            )
          : null,
    );
  }
}
