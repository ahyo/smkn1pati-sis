import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/teaching_journal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class TeacherJournalsScreen extends StatelessWidget {
  const TeacherJournalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final journals = data.teachingJournalsByTeacher(user.id);
    final df = DateFormat('dd MMM yyyy', 'id_ID');

    return RoleScaffold(
      title: 'Jurnal Mengajar',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Jurnal Mengajar',
            subtitle: '${journals.length} catatan mengajar',
            action: FilledButton.icon(
              onPressed: () => context.go('/teacher/journals/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jurnal'),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<TeachingJournal>(
                    items: journals,
                    onRowTap: (j) => context.go('/teacher/journals/${j.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Tanggal',
                        build: (j) => Text(df.format(j.date)),
                      ),
                      AppTableColumn(
                        label: 'Kelas',
                        build: (j) =>
                            Text(data.classById(j.classId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Mapel',
                        build: (j) =>
                            Text(data.subjectById(j.subjectId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Topik',
                        build: (j) => Text(j.topic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                      AppTableColumn(
                        label: 'Kehadiran',
                        build: (j) {
                          final pct = j.totalStudents == 0
                              ? 0
                              : (j.attendanceCount / j.totalStudents * 100)
                                  .round();
                          return Text(
                              '${j.attendanceCount}/${j.totalStudents} ($pct%)');
                        },
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, j) =>
                            ctx.go('/teacher/journals/${j.id}'),
                      ),
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, j) => ctx
                            .read<DataProvider>()
                            .deleteTeachingJournal(j.id),
                      ),
                    ],
                    emptyIcon: Icons.event_note_outlined,
                    emptyTitle: 'Belum ada jurnal mengajar',
                    emptyMessage:
                        'Catat aktivitas mengajar Anda hari ini.',
                    emptyAction: FilledButton.icon(
                      onPressed: () => context.go('/teacher/journals/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Jurnal'),
                    ),
                  ),
                ),
              ),
              mobile: journals.isEmpty
                  ? EmptyState(
                      icon: Icons.event_note_outlined,
                      title: 'Belum ada jurnal mengajar',
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.go('/teacher/journals/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Jurnal'),
                      ),
                    )
                  : PaginatedListView<TeachingJournal>(
                      items: journals,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, j, i) {
                        final cls = data.classById(j.classId);
                        final subject = data.subjectById(j.subjectId);
                        final pct = j.totalStudents == 0
                            ? 0
                            : (j.attendanceCount / j.totalStudents * 100)
                                .round();
                        return Card(
                          child: ListTile(
                            onTap: () =>
                                context.go('/teacher/journals/${j.id}'),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text('${j.date.day}'),
                            ),
                            title: Text('${i + 1}. ${j.topic}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${df.format(j.date)}\n${cls?.name ?? '-'} • ${subject?.name ?? '-'} • Hadir $pct%'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context
                                  .read<DataProvider>()
                                  .deleteTeachingJournal(j.id),
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
              onPressed: () => context.go('/teacher/journals/new'),
              icon: const Icon(Icons.add),
              label: const Text('Jurnal'),
            )
          : null,
    );
  }
}
