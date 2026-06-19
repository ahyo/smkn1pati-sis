import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/exam.dart';
import '../../models/exam_submission.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class TeacherGradeSubmissionScreen extends StatefulWidget {
  const TeacherGradeSubmissionScreen({
    super.key,
    required this.examId,
    required this.submissionId,
  });

  final String examId;
  final String submissionId;

  @override
  State<TeacherGradeSubmissionScreen> createState() =>
      _TeacherGradeSubmissionScreenState();
}

class _TeacherGradeSubmissionScreenState
    extends State<TeacherGradeSubmissionScreen> {
  final Map<String, TextEditingController> _scoreCtrls = {};
  final Map<String, TextEditingController> _feedbackCtrls = {};
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _scoreCtrls.values) {
      c.dispose();
    }
    for (final c in _feedbackCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(Exam exam, ExamSubmission sub) {
    if (_hydrated) return;
    for (final q in exam.questions) {
      if (q.isEssay) {
        _scoreCtrls[q.id] = TextEditingController(
          text: sub.essayScores[q.id]?.toString() ?? '',
        );
        _feedbackCtrls[q.id] = TextEditingController(
          text: sub.essayFeedback[q.id] ?? '',
        );
      }
    }
    _hydrated = true;
  }

  Future<void> _save(Exam exam, ExamSubmission sub) async {
    setState(() => _saving = true);
    final newScores = <String, int>{};
    final newFeedback = <String, String>{};
    for (final q in exam.questions.where((q) => q.isEssay)) {
      final raw = _scoreCtrls[q.id]?.text.trim() ?? '';
      if (raw.isEmpty) continue;
      final score = int.tryParse(raw);
      if (score == null) continue;
      newScores[q.id] = score.clamp(0, q.points);
      final fb = _feedbackCtrls[q.id]?.text.trim() ?? '';
      if (fb.isNotEmpty) newFeedback[q.id] = fb;
    }
    final newScore = ExamSubmission.computeScore(
      exam: exam,
      mcAnswers: sub.answers,
      complexAnswers: sub.complexAnswers,
      trueFalseAnswers: sub.trueFalseAnswers,
      essayScores: newScores,
    );
    final updated = sub.copyWith(
      essayScores: newScores,
      essayFeedback: newFeedback,
      score: newScore,
      gradedAt: DateTime.now(),
    );
    await context.read<DataProvider>().submitExam(updated);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Penilaian disimpan')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final exam = data.examById(widget.examId);
    final sub = data.submissions
        .where((s) => s.id == widget.submissionId)
        .firstOrNull;
    if (exam == null || sub == null) {
      return const RoleScaffold(
        title: 'Penilaian',
        body: Center(child: Text('Submisi tidak ditemukan')),
      );
    }
    _hydrate(exam, sub);
    final student = data.userById(sub.studentId);
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    final objectiveMax = exam.questions
        .where((q) => q.isObjective)
        .fold<int>(0, (s, q) => s + q.points);
    final objectiveScore = ExamSubmission.computeScore(
      exam: exam,
      mcAnswers: sub.answers,
      complexAnswers: sub.complexAnswers,
      trueFalseAnswers: sub.trueFalseAnswers,
      essayScores: const {},
    );

    return RoleScaffold(
      title: 'Nilai Submisi',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              PageHeader(
                title: 'Penilaian: ${student?.name ?? '-'}',
                subtitle:
                    'Ujian "${exam.title}" • Dikumpulkan ${df.format(sub.submittedAt)}',
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _MiniMetric(
                        label: 'Objektif',
                        value: '$objectiveScore / $objectiveMax',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _MiniMetric(
                        label: 'Total Saat Ini',
                        value: '${sub.score} / ${sub.totalPoints}',
                        color: Colors.indigo.shade700,
                      ),
                      const SizedBox(width: 12),
                      _MiniMetric(
                        label: 'Status',
                        value: sub.isFullyGradedFor(exam)
                            ? 'Sudah dinilai'
                            : 'Menunggu',
                        color: sub.isFullyGradedFor(exam)
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...exam.questions.asMap().entries.map((entry) {
                final i = entry.key;
                final q = entry.value;
                if (q.isObjective) {
                  final picked = sub.answers[q.id];
                  final pickedComplex =
                      sub.complexAnswers[q.id] ?? const <int>[];
                  final pickedTrueFalse =
                      sub.trueFalseAnswers[q.id] ?? const <bool>[];
                  final correct = q.isMultipleChoice
                      ? picked == q.correctIndex
                      : q.isMultipleChoiceComplex
                      ? _sameIntSet(pickedComplex, q.correctIndexes)
                      : _sameBoolList(pickedTrueFalse, q.trueFalseAnswers);
                  final color = q.isTrueFalse
                      ? Colors.teal
                      : q.isMultipleChoiceComplex
                      ? Colors.orange.shade800
                      : Theme.of(context).colorScheme.primary;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _QHeader(
                            number: i + 1,
                            type: q.type.label,
                            points: q.points,
                            color: color,
                          ),
                          const SizedBox(height: 8),
                          Text(q.prompt),
                          const SizedBox(height: 8),
                          if (q.isTrueFalse)
                            for (var j = 0; j < q.options.length; j++)
                              _TrueFalseRow(
                                text: q.options[j],
                                correctAnswer:
                                    q.trueFalseAnswers.elementAtOrNull(j) ??
                                    false,
                                pickedAnswer: pickedTrueFalse.elementAtOrNull(
                                  j,
                                ),
                              )
                          else
                            for (var j = 0; j < q.options.length; j++)
                              _OptionRow(
                                text: q.options[j],
                                isCorrect: q.isMultipleChoice
                                    ? j == q.correctIndex
                                    : q.correctIndexes.contains(j),
                                isPicked: q.isMultipleChoice
                                    ? picked == j
                                    : pickedComplex.contains(j),
                              ),
                          const SizedBox(height: 4),
                          Text(
                            correct
                                ? 'Jawaban benar (+${q.points} poin)'
                                : 'Jawaban salah (0 poin)',
                            style: TextStyle(
                              color: correct
                                  ? Colors.green.shade700
                                  : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Essay
                final answer = sub.essayAnswers[q.id] ?? '';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QHeader(
                          number: i + 1,
                          type: q.type.label,
                          points: q.points,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.prompt,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jawaban Siswa',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                answer.isEmpty ? '(tidak ada jawaban)' : answer,
                                style: answer.isEmpty
                                    ? TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        if (q.sampleAnswer != null &&
                            q.sampleAnswer!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            title: Text(
                              'Lihat Rubrik / Contoh Jawaban',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            children: [
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
                                child: Text(q.sampleAnswer!),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: TextField(
                                controller: _scoreCtrls[q.id],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Skor',
                                  helperText: 'Maks ${q.points}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _feedbackCtrls[q.id],
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Catatan untuk siswa (opsional)',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.go('/teacher/exams/${exam.id}/submissions'),
                    child: const Text('Kembali'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : () => _save(exam, sub),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Menyimpan...' : 'Simpan Penilaian'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

bool _sameIntSet(List<int> a, List<int> b) {
  final aa = [...a]..sort();
  final bb = [...b]..sort();
  if (aa.length != bb.length) return false;
  for (var i = 0; i < aa.length; i++) {
    if (aa[i] != bb[i]) return false;
  }
  return true;
}

bool _sameBoolList(List<bool> a, List<bool> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _QHeader extends StatelessWidget {
  const _QHeader({
    required this.number,
    required this.type,
    required this.points,
    required this.color,
  });
  final int number;
  final String type;
  final int points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            type,
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
          'Maks $points poin',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.text,
    required this.isCorrect,
    required this.isPicked,
  });
  final String text;
  final bool isCorrect;
  final bool isPicked;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    if (isCorrect) {
      icon = Icons.check_circle;
      color = Colors.green.shade700;
    } else if (isPicked) {
      icon = Icons.cancel;
      color = Theme.of(context).colorScheme.error;
    } else {
      icon = Icons.radio_button_unchecked;
      color = Theme.of(context).colorScheme.outline;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: (isCorrect || isPicked)
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: color,
              ),
            ),
          ),
          if (isPicked && !isCorrect)
            Text(
              '(jawaban siswa)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          if (isCorrect && isPicked)
            Text(
              '✓ benar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _TrueFalseRow extends StatelessWidget {
  const _TrueFalseRow({
    required this.text,
    required this.correctAnswer,
    required this.pickedAnswer,
  });

  final String text;
  final bool correctAnswer;
  final bool? pickedAnswer;

  @override
  Widget build(BuildContext context) {
    final correct = pickedAnswer == correctAnswer;
    final color = correct
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          Text(
            'Siswa: ${pickedAnswer == null
                ? '-'
                : pickedAnswer!
                ? 'Benar'
                : 'Salah'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
          Text(
            'Kunci: ${correctAnswer ? 'Benar' : 'Salah'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
