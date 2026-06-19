import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/exam_submission.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class StudentResultsScreen extends StatelessWidget {
  const StudentResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final subs = data.submissionsByStudent(user.id)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
    final avg = subs.isEmpty
        ? 0.0
        : subs.map((s) => s.percentage).reduce((a, b) => a + b) / subs.length;

    return RoleScaffold(
      title: 'Hasil Ujian',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Hasil Ujian',
            subtitle:
                '${subs.length} ujian selesai${subs.isNotEmpty ? ' • Rata-rata ${avg.toStringAsFixed(0)}%' : ''}',
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
                        label: 'Ujian',
                        build: (s) {
                          final ex = data.examById(s.examId);
                          return Text(ex?.title ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500));
                        },
                      ),
                      AppTableColumn(
                        label: 'Mapel',
                        build: (s) {
                          final ex = data.examById(s.examId);
                          return Text(
                              ex == null
                                  ? '-'
                                  : data.subjectById(ex.subjectId)?.name ?? '-');
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
                    ],
                    emptyIcon: Icons.assessment_outlined,
                    emptyTitle: 'Belum ada hasil',
                    emptyMessage:
                        'Hasil akan muncul setelah Anda mengerjakan ujian.',
                  ),
                ),
              ),
              mobile: subs.isEmpty
                  ? const EmptyState(
                      icon: Icons.assessment_outlined,
                      title: 'Belum ada hasil',
                    )
                  : PaginatedListView<ExamSubmission>(
                      items: subs,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, s, i) {
                        final ex = data.examById(s.examId);
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.assessment_outlined),
                            title: Text('${i + 1}. ${ex?.title ?? 'Ujian'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${ex == null ? '-' : data.subjectById(ex.subjectId)?.name ?? '-'} • ${df.format(s.submittedAt)}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${s.score}/${s.totalPoints}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text('${s.percentage.toStringAsFixed(0)}%'),
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
