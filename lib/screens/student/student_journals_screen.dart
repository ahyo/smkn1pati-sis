import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/study_journal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class StudentJournalsScreen extends StatelessWidget {
  const StudentJournalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final journals = data.studyJournalsByStudent(user.id);
    final df = DateFormat('dd MMM yyyy', 'id_ID');
    final totalMinutes =
        journals.fold<int>(0, (s, j) => s + j.durationMinutes);

    return RoleScaffold(
      title: 'Jurnal Belajar',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Jurnal Belajar',
            subtitle: journals.isEmpty
                ? 'Catat aktivitas belajar mandiri Anda'
                : '${journals.length} catatan • Total ${totalMinutes ~/ 60} jam ${totalMinutes % 60} menit',
            action: FilledButton.icon(
              onPressed: () => context.go('/student/journals/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Catatan'),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<StudyJournal>(
                    items: journals,
                    onRowTap: (j) => context.go('/student/journals/${j.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Tanggal',
                        build: (j) => Text(df.format(j.date)),
                      ),
                      AppTableColumn(
                        label: 'Mapel',
                        build: (j) => Text(
                          j.subjectId == null
                              ? 'Umum'
                              : data.subjectById(j.subjectId!)?.name ?? '-',
                        ),
                      ),
                      AppTableColumn(
                        label: 'Topik',
                        build: (j) => Text(j.topic,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                      AppTableColumn(
                        label: 'Ringkasan',
                        build: (j) => SizedBox(
                          width: 320,
                          child: Text(
                            j.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      AppTableColumn(
                        label: 'Durasi',
                        numeric: true,
                        build: (j) => Text('${j.durationMinutes} menit'),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, j) =>
                            ctx.go('/student/journals/${j.id}'),
                      ),
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, j) =>
                            ctx.read<DataProvider>().deleteStudyJournal(j.id),
                      ),
                    ],
                    emptyIcon: Icons.book_outlined,
                    emptyTitle: 'Belum ada catatan belajar',
                    emptyMessage:
                        'Mulai catat apa yang Anda pelajari hari ini.',
                    emptyAction: FilledButton.icon(
                      onPressed: () => context.go('/student/journals/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Catatan'),
                    ),
                  ),
                ),
              ),
              mobile: journals.isEmpty
                  ? EmptyState(
                      icon: Icons.book_outlined,
                      title: 'Belum ada catatan belajar',
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.go('/student/journals/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Catatan'),
                      ),
                    )
                  : PaginatedListView<StudyJournal>(
                      items: journals,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, j, i) {
                        final subject = j.subjectId == null
                            ? null
                            : data.subjectById(j.subjectId!);
                        return Card(
                          child: ListTile(
                            onTap: () =>
                                context.go('/student/journals/${j.id}'),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              child: Text('${j.date.day}'),
                            ),
                            title: Text('${i + 1}. ${j.topic}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${df.format(j.date)} • ${subject?.name ?? 'Umum'} • ${j.durationMinutes} menit\n${j.summary}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context
                                  .read<DataProvider>()
                                  .deleteStudyJournal(j.id),
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
              onPressed: () => context.go('/student/journals/new'),
              icon: const Icon(Icons.add),
              label: const Text('Catat'),
            )
          : null,
    );
  }
}
