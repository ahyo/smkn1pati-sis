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

class StudentMaterialsScreen extends StatelessWidget {
  const StudentMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final materials = user.classId == null
        ? <LearningMaterial>[]
        : (data.materialsForClass(user.classId!)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    final df = DateFormat('dd MMM yyyy', 'id_ID');

    return RoleScaffold(
      title: 'Materi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Materi Pembelajaran',
            subtitle: '${materials.length} materi tersedia di kelas Anda',
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<LearningMaterial>(
                    items: materials,
                    onRowTap: (m) => context.go('/student/materials/${m.id}'),
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
                        label: 'Guru',
                        build: (m) =>
                            Text(data.userById(m.teacherId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Tanggal',
                        build: (m) => Text(df.format(m.createdAt)),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.visibility_outlined,
                        tooltip: 'Buka',
                        onPressed: (ctx, m) =>
                            ctx.go('/student/materials/${m.id}'),
                      ),
                    ],
                    emptyIcon: Icons.menu_book_outlined,
                    emptyTitle: 'Belum ada materi',
                    emptyMessage:
                        'Materi akan muncul di sini ketika guru menambahkannya.',
                  ),
                ),
              ),
              mobile: materials.isEmpty
                  ? const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'Belum ada materi',
                      message: 'Cek lagi nanti.',
                    )
                  : PaginatedListView<LearningMaterial>(
                      items: materials,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, m, i) {
                        return Card(
                          child: ListTile(
                            onTap: () =>
                                context.go('/student/materials/${m.id}'),
                            leading: const Icon(Icons.article_outlined),
                            title: Text('${i + 1}. ${m.title}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${data.subjectById(m.subjectId)?.name ?? '-'} • ${data.userById(m.teacherId)?.name ?? '-'}\n${df.format(m.createdAt)}'),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
