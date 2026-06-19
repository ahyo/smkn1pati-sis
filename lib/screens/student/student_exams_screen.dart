import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/exam.dart';
import '../../models/exam_submission.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class StudentExamsScreen extends StatelessWidget {
  const StudentExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final exams = user.classId == null
        ? <Exam>[]
        : (data.examsForClass(user.classId!)
          ..sort((a, b) => b.startAt.compareTo(a.startAt)));
    final mySubs = data.submissionsByStudent(user.id);
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    ExamSubmission? subFor(String examId) {
      for (final s in mySubs) {
        if (s.examId == examId) return s;
      }
      return null;
    }

    Widget statusFor(Exam e) {
      final mySub = subFor(e.id);
      if (mySub != null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Selesai',
              style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        );
      }
      if (e.isActive) {
        return FilledButton(
          onPressed: () => context.go('/student/exams/${e.id}'),
          style: FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
          child: const Text('Kerjakan'),
        );
      }
      final label = e.startAt.isAfter(DateTime.now())
          ? 'Belum mulai'
          : 'Berakhir';
      final color = e.startAt.isAfter(DateTime.now())
          ? Colors.orange.shade700
          : Colors.grey.shade600;
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

    return RoleScaffold(
      title: 'Ujian',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Ujian',
            subtitle: '${exams.length} ujian terjadwal',
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<Exam>(
                    items: exams,
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
                        label: 'Soal',
                        numeric: true,
                        build: (e) => Text('${e.questions.length}'),
                      ),
                      AppTableColumn(
                        label: 'Durasi',
                        build: (e) => Text('${e.durationMinutes} menit'),
                      ),
                      AppTableColumn(
                        label: 'Mulai',
                        build: (e) => Text(df.format(e.startAt)),
                      ),
                      AppTableColumn(
                        label: 'Status',
                        build: statusFor,
                      ),
                      AppTableColumn(
                        label: 'Skor',
                        build: (e) {
                          final s = subFor(e.id);
                          if (s == null) return const Text('-');
                          return Text('${s.score}/${s.totalPoints}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600));
                        },
                      ),
                    ],
                    emptyIcon: Icons.quiz_outlined,
                    emptyTitle: 'Belum ada ujian',
                    emptyMessage: 'Ujian akan muncul saat guru membuatnya.',
                  ),
                ),
              ),
              mobile: exams.isEmpty
                  ? const EmptyState(
                      icon: Icons.quiz_outlined,
                      title: 'Belum ada ujian',
                    )
                  : PaginatedListView<Exam>(
                      items: exams,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, e, i) {
                        final mySub = subFor(e.id);
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              mySub != null
                                  ? Icons.check_circle
                                  : Icons.quiz_outlined,
                              color: mySub != null
                                  ? Colors.green.shade700
                                  : null,
                            ),
                            title: Text('${i + 1}. ${e.title}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${data.subjectById(e.subjectId)?.name ?? '-'} • ${e.questions.length} soal • ${e.durationMinutes} menit\nMulai: ${df.format(e.startAt)}'),
                            isThreeLine: true,
                            trailing: statusFor(e),
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
