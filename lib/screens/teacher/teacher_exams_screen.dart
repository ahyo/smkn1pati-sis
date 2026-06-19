import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/exam.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class TeacherExamsScreen extends StatelessWidget {
  const TeacherExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final mine = data.examsByTeacher(user.id)
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    return RoleScaffold(
      title: 'Ujian',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Ujian',
            subtitle: '${mine.length} ujian Anda kelola',
            action: FilledButton.icon(
              onPressed: () => context.go('/teacher/exams/new'),
              icon: const Icon(Icons.add),
              label: const Text('Buat Ujian'),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<Exam>(
                    items: mine,
                    onRowTap: (e) => context.go('/teacher/exams/${e.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Judul',
                        build: (e) => Text(e.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                      AppTableColumn(
                        label: 'Mapel',
                        build: (e) =>
                            Text(data.subjectById(e.subjectId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Kelas',
                        build: (e) =>
                            Text(data.classById(e.classId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Soal',
                        numeric: true,
                        build: (e) => Text('${e.questions.length}'),
                      ),
                      AppTableColumn(
                        label: 'Jadwal',
                        build: (e) => Text(df.format(e.startAt)),
                      ),
                      AppTableColumn(
                        label: 'Submisi',
                        numeric: true,
                        build: (e) =>
                            Text('${data.submissionsForExam(e.id).length}'),
                      ),
                      AppTableColumn(
                        label: 'Status',
                        build: (e) => _StatusChip(exam: e),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.assessment_outlined,
                        tooltip: 'Lihat hasil',
                        onPressed: (ctx, e) =>
                            ctx.go('/teacher/exams/${e.id}/submissions'),
                      ),
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, e) =>
                            ctx.go('/teacher/exams/${e.id}'),
                      ),
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, e) =>
                            ctx.read<DataProvider>().deleteExam(e.id),
                      ),
                    ],
                    emptyIcon: Icons.quiz_outlined,
                    emptyTitle: 'Belum ada ujian',
                    emptyMessage: 'Buat ujian pertama Anda untuk siswa.',
                    emptyAction: FilledButton.icon(
                      onPressed: () => context.go('/teacher/exams/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Ujian'),
                    ),
                  ),
                ),
              ),
              mobile: mine.isEmpty
                  ? EmptyState(
                      icon: Icons.quiz_outlined,
                      title: 'Belum ada ujian',
                      action: FilledButton.icon(
                        onPressed: () => context.go('/teacher/exams/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Ujian'),
                      ),
                    )
                  : PaginatedListView<Exam>(
                      items: mine,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, e, i) {
                        return Card(
                          child: ListTile(
                            onTap: () =>
                                context.go('/teacher/exams/${e.id}'),
                            leading: const Icon(Icons.quiz_outlined),
                            title: Text('${i + 1}. ${e.title}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${data.subjectById(e.subjectId)?.name ?? '-'} • ${data.classById(e.classId)?.name ?? '-'}\n${e.questions.length} soal • ${df.format(e.startAt)} • ${data.submissionsForExam(e.id).length} submisi'),
                            isThreeLine: true,
                            trailing: _StatusChip(exam: e),
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
              onPressed: () => context.go('/teacher/exams/new'),
              icon: const Icon(Icons.add),
              label: const Text('Ujian'),
            )
          : null,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String label;
    final Color color;
    if (exam.isActive) {
      label = 'Aktif';
      color = Colors.green.shade700;
    } else if (exam.startAt.isAfter(now)) {
      label = 'Terjadwal';
      color = Colors.orange.shade700;
    } else {
      label = 'Berakhir';
      color = Colors.grey.shade600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
