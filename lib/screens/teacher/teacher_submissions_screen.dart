import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/exam.dart';
import '../../models/exam_submission.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class TeacherSubmissionsScreen extends StatelessWidget {
  const TeacherSubmissionsScreen({super.key, required this.examId});
  final String examId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final Exam? exam = data.examById(examId);
    final subs = data.submissionsForExam(examId)
      ..sort((a, b) => b.score.compareTo(a.score));
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
    final hasEssay = exam?.hasEssayQuestions ?? false;
    final pendingCount = exam == null
        ? 0
        : subs.where((s) => !s.isFullyGradedFor(exam)).length;

    return RoleScaffold(
      title: 'Hasil Ujian',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: exam?.title ?? 'Hasil Ujian',
            subtitle: hasEssay
                ? '${subs.length} submisi • $pendingCount belum dinilai (essay)'
                : '${subs.length} siswa sudah mengerjakan',
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<ExamSubmission>(
                    items: subs,
                    columns: [
                      AppTableColumn(
                        label: 'Siswa',
                        build: (s) {
                          final st = data.userById(s.studentId);
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                child: Text(
                                  st?.name.substring(0, 1).toUpperCase() ?? '?',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(st?.name ?? '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          );
                        },
                      ),
                      AppTableColumn(
                        label: 'Dikumpulkan',
                        build: (s) => Text(df.format(s.submittedAt)),
                      ),
                      AppTableColumn(
                        label: 'Skor',
                        numeric: true,
                        build: (s) => Text('${s.score}/${s.totalPoints}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                      AppTableColumn(
                        label: 'Persentase',
                        build: (s) => _ScoreBar(percentage: s.percentage),
                      ),
                      if (hasEssay)
                        AppTableColumn(
                          label: 'Status',
                          build: (s) => _GradeStatusChip(
                            graded: exam == null
                                ? false
                                : s.isFullyGradedFor(exam),
                          ),
                        ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.grading_outlined,
                        tooltip: 'Lihat & nilai',
                        onPressed: (ctx, s) => ctx.go(
                            '/teacher/exams/$examId/submissions/${s.id}'),
                      ),
                    ],
                    emptyIcon: Icons.assessment_outlined,
                    emptyTitle: 'Belum ada submisi',
                    emptyMessage:
                        'Belum ada siswa yang mengerjakan ujian ini.',
                  ),
                ),
              ),
              mobile: subs.isEmpty
                  ? const EmptyState(
                      icon: Icons.assessment_outlined,
                      title: 'Belum ada submisi',
                    )
                  : PaginatedListView<ExamSubmission>(
                      items: subs,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, s, i) {
                        final st = data.userById(s.studentId);
                        final graded =
                            exam == null ? false : s.isFullyGradedFor(exam);
                        return Card(
                          child: ListTile(
                            onTap: () => context.go(
                                '/teacher/exams/$examId/submissions/${s.id}'),
                            leading: CircleAvatar(
                              child: Text(
                                  st?.name.substring(0, 1).toUpperCase() ?? '?'),
                            ),
                            title: Text('${i + 1}. ${st?.name ?? '-'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(df.format(s.submittedAt)),
                                if (hasEssay) ...[
                                  const SizedBox(height: 4),
                                  _GradeStatusChip(graded: graded),
                                ],
                              ],
                            ),
                            isThreeLine: hasEssay,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${s.score}/${s.totalPoints}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(
                                    '${s.percentage.toStringAsFixed(0)}%'),
                              ],
                            ),
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

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.percentage});
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final color = percentage >= 75
        ? Colors.green.shade600
        : percentage >= 60
            ? Colors.orange.shade600
            : Theme.of(context).colorScheme.error;
    return SizedBox(
      width: 160,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeStatusChip extends StatelessWidget {
  const _GradeStatusChip({required this.graded});
  final bool graded;

  @override
  Widget build(BuildContext context) {
    final color = graded ? Colors.green.shade700 : Colors.orange.shade700;
    final label = graded ? 'Sudah dinilai' : 'Menunggu nilai';
    final icon = graded ? Icons.check_circle_outline : Icons.pending_outlined;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
