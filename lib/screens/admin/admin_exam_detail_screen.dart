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
import '../../widgets/role_scaffold.dart';

class AdminExamDetailScreen extends StatelessWidget {
  const AdminExamDetailScreen({super.key, required this.examId});
  final String examId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final exam = data.examById(examId);
    if (exam == null) {
      return const RoleScaffold(
        title: 'Detail Ujian',
        body: Center(child: Text('Ujian tidak ditemukan')),
      );
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
    final dfShort = DateFormat('dd MMM HH:mm', 'id_ID');
    final subject = data.subjectById(exam.subjectId);
    final cls = data.classById(exam.classId);
    final teacher = data.userById(exam.teacherId);
    final subs = data.submissionsForExam(exam.id)
      ..sort((a, b) => b.score.compareTo(a.score));
    final classRoster = cls?.studentIds.length ?? 0;
    final submitRate = classRoster == 0
        ? 0
        : (subs.length / classRoster * 100).round();
    final avg = subs.isEmpty
        ? 0.0
        : subs.map((s) => s.percentage).reduce((a, b) => a + b) / subs.length;
    const passing = 70;
    final passed = subs.where((s) => s.percentage >= passing).length;
    final pendingGrading = subs.where((s) => !s.isFullyGradedFor(exam)).length;

    return RoleScaffold(
      title: 'Detail Ujian',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              PageHeader(
                title: exam.title,
                subtitle:
                    '${subject?.name ?? '-'} • ${cls?.name ?? '-'} • ${teacher?.name ?? '-'}',
                action: OutlinedButton.icon(
                  onPressed: () => context.go('/admin/exams'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exam.description.isNotEmpty) ...[
                        Text(exam.description),
                        const SizedBox(height: 16),
                      ],
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _Info(
                            icon: Icons.timer_outlined,
                            label: 'Durasi',
                            value: '${exam.durationMinutes} menit',
                          ),
                          _Info(
                            icon: Icons.event_available_outlined,
                            label: 'Mulai',
                            value: df.format(exam.startAt),
                          ),
                          _Info(
                            icon: Icons.event_busy_outlined,
                            label: 'Selesai',
                            value: df.format(exam.endAt),
                          ),
                          _Info(
                            icon: Icons.help_outline,
                            label: 'Total Soal',
                            value:
                                '${exam.questions.length} (${exam.mcCount} PG · ${exam.essayCount} Essay)',
                          ),
                          _Info(
                            icon: Icons.grade_outlined,
                            label: 'Total Poin',
                            value: '${exam.totalPoints}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    label: 'Submisi',
                    value: '${subs.length}',
                    sub: 'dari $classRoster siswa kelas ($submitRate%)',
                    icon: Icons.assignment_turned_in_outlined,
                    color: scheme.primary,
                  ),
                  _StatCard(
                    label: 'Rata-rata Nilai',
                    value: subs.isEmpty ? '-' : '${avg.toStringAsFixed(1)}%',
                    sub: 'dari semua submisi',
                    icon: Icons.trending_up,
                    color: Colors.indigo.shade700,
                  ),
                  _StatCard(
                    label: 'Lulus KKM ($passing)',
                    value: subs.isEmpty ? '-' : '$passed dari ${subs.length}',
                    sub: subs.isEmpty
                        ? '-'
                        : '${(passed / subs.length * 100).round()}% lulus',
                    icon: Icons.verified_outlined,
                    color: Colors.green.shade700,
                  ),
                  if (exam.hasEssayQuestions)
                    _StatCard(
                      label: 'Belum Dinilai',
                      value: '$pendingGrading',
                      sub: 'submisi essay menunggu',
                      icon: Icons.pending_outlined,
                      color: Colors.orange.shade700,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Daftar Soal (${exam.questions.length})',
                child: Column(
                  children: [
                    for (var i = 0; i < exam.questions.length; i++)
                      _QuestionCard(number: i + 1, question: exam.questions[i]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Hasil Submisi (${subs.length})',
                child: subs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(
                          icon: Icons.assessment_outlined,
                          title: 'Belum ada submisi',
                          message:
                              'Belum ada siswa yang mengerjakan ujian ini.',
                        ),
                      )
                    : AppTable<ExamSubmission>(
                        items: subs,
                        initialPageSize: 10,
                        columns: [
                          AppTableColumn(
                            label: 'Siswa',
                            build: (s) {
                              final st = data.userById(s.studentId);
                              return Text(
                                st?.name ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                          AppTableColumn(
                            label: 'Dikumpulkan',
                            build: (s) => Text(dfShort.format(s.submittedAt)),
                          ),
                          AppTableColumn(
                            label: 'Skor',
                            numeric: true,
                            build: (s) => Text(
                              '${s.score}/${s.totalPoints}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          AppTableColumn(
                            label: 'Nilai',
                            build: (s) => _Bar(percent: s.percentage),
                          ),
                          AppTableColumn(
                            label: 'Status',
                            build: (s) => _PassChip(
                              percent: s.percentage,
                              graded: s.isFullyGradedFor(exam),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        child,
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.number, required this.question});
  final int number;
  final ExamQuestion question;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = question.isEssay
        ? Colors.deepPurple
        : question.isTrueFalse
        ? Colors.teal
        : question.isMultipleChoiceComplex
        ? Colors.orange.shade800
        : scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.type.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Soal $number',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${question.points} poin',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(question.prompt, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              if (question.isMultipleChoice || question.isMultipleChoiceComplex)
                Column(
                  children: [
                    for (var j = 0; j < question.options.length; j++)
                      _MCRow(
                        index: j,
                        text: question.options[j],
                        isCorrect: question.isMultipleChoice
                            ? j == question.correctIndex
                            : question.correctIndexes.contains(j),
                      ),
                  ],
                )
              else if (question.isTrueFalse)
                Column(
                  children: [
                    for (var j = 0; j < question.options.length; j++)
                      _TrueFalseKeyRow(
                        text: question.options[j],
                        answer:
                            question.trueFalseAnswers.elementAtOrNull(j) ??
                            false,
                      ),
                  ],
                )
              else if (question.sampleAnswer != null &&
                  question.sampleAnswer!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contoh / Rubrik Jawaban',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(question.sampleAnswer!),
                    ],
                  ),
                )
              else
                Text(
                  '(tidak ada rubrik)',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrueFalseKeyRow extends StatelessWidget {
  const _TrueFalseKeyRow({required this.text, required this.answer});

  final String text;
  final bool answer;

  @override
  Widget build(BuildContext context) {
    final color = answer ? Colors.green.shade700 : Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            answer ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          Text(
            answer ? 'Benar' : 'Salah',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MCRow extends StatelessWidget {
  const _MCRow({
    required this.index,
    required this.text,
    required this.isCorrect,
  });
  final int index;
  final String text;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isCorrect ? Colors.green.shade700 : scheme.outline;
    final letter = String.fromCharCode(65 + index); // A, B, C, ...
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withValues(alpha: 0.15)
                  : scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: isCorrect ? 1.5 : 0.5),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                color: isCorrect ? color : null,
              ),
            ),
          ),
          if (isCorrect) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              'Jawaban benar',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final c = percent >= 75
        ? Colors.green.shade600
        : percent >= 60
        ? Colors.orange.shade600
        : Theme.of(context).colorScheme.error;
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(c),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(color: c, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassChip extends StatelessWidget {
  const _PassChip({required this.percent, required this.graded});
  final double percent;
  final bool graded;

  @override
  Widget build(BuildContext context) {
    if (!graded) {
      final c = Colors.orange.shade700;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Menunggu nilai',
          style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }
    final passed = percent >= 70;
    final c = passed
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        passed ? 'Lulus' : 'Tidak Lulus',
        style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
