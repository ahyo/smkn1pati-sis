import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/exam.dart';
import '../../models/exam_submission.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/role_scaffold.dart';

class StudentExamRunnerScreen extends StatefulWidget {
  const StudentExamRunnerScreen({super.key, required this.examId});
  final String examId;

  @override
  State<StudentExamRunnerScreen> createState() =>
      _StudentExamRunnerScreenState();
}

class _StudentExamRunnerScreenState extends State<StudentExamRunnerScreen> {
  final Map<String, int> _mcAnswers = {};
  final Map<String, Set<int>> _complexAnswers = {};
  final Map<String, List<bool?>> _trueFalseAnswers = {};
  final Map<String, TextEditingController> _essayCtrls = {};
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _submitted = false;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = context.read<DataProvider>();
      final exam = data.examById(widget.examId);
      if (exam != null) {
        // Initialize controllers for essay questions
        for (final q in exam.questions) {
          if (q.isEssay) {
            _essayCtrls[q.id] = TextEditingController();
          } else if (q.isMultipleChoiceComplex) {
            _complexAnswers[q.id] = <int>{};
          } else if (q.isTrueFalse) {
            _trueFalseAnswers[q.id] = List<bool?>.filled(
              q.options.length,
              null,
            );
          }
        }
        _deadline = DateTime.now().add(Duration(minutes: exam.durationMinutes));
        _startTimer();
        if (mounted) setState(() {});
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_deadline == null) return;
      final left = _deadline!.difference(DateTime.now());
      if (left.isNegative) {
        _submit(auto: true);
      } else {
        if (mounted) setState(() => _remaining = left);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _essayCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit({bool auto = false}) async {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();
    final data = context.read<DataProvider>();
    final user = context.read<AuthProvider>().user!;
    final exam = data.examById(widget.examId);
    if (exam == null) return;

    // Auto-score MC; essays start with 0 (awaiting teacher grading).
    final essayAnswers = <String, String>{
      for (final entry in _essayCtrls.entries)
        entry.key: entry.value.text.trim(),
    };
    final complexAnswers = <String, List<int>>{
      for (final entry in _complexAnswers.entries)
        entry.key: (entry.value.toList()..sort()),
    };
    final trueFalseAnswers = <String, List<bool>>{
      for (final entry in _trueFalseAnswers.entries)
        entry.key: entry.value.map((v) => v ?? false).toList(),
    };
    final score = ExamSubmission.computeScore(
      exam: exam,
      mcAnswers: _mcAnswers,
      complexAnswers: complexAnswers,
      trueFalseAnswers: trueFalseAnswers,
      essayScores: const {},
    );
    final submission = ExamSubmission(
      id: const Uuid().v4(),
      examId: exam.id,
      studentId: user.id,
      answers: _mcAnswers,
      complexAnswers: complexAnswers,
      trueFalseAnswers: trueFalseAnswers,
      essayAnswers: essayAnswers,
      score: score,
      totalPoints: exam.totalPoints,
      submittedAt: DateTime.now(),
    );
    await data.submitExam(submission);
    if (!mounted) return;

    final objectiveMax = exam.questions
        .where((q) => q.isObjective)
        .fold<int>(0, (s, q) => s + q.points);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(auto ? 'Waktu Habis' : 'Ujian Dikumpulkan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skor objektif: $score / $objectiveMax'),
            if (exam.hasEssayQuestions) ...[
              const SizedBox(height: 8),
              Text(
                '${exam.essayCount} soal essay menunggu dinilai oleh guru.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Total nilai akhir akan terlihat setelah essay dinilai.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/student/results');
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final exam = data.examById(widget.examId);
    if (exam == null) {
      return const RoleScaffold(
        title: 'Ujian',
        body: Center(child: Text('Ujian tidak ditemukan')),
      );
    }
    return RoleScaffold(
      title: exam.title,
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Chip(
              avatar: const Icon(Icons.timer_outlined, size: 18),
              label: Text(_format(_remaining)),
            ),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(exam.description),
          if (exam.hasEssayQuestions) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ujian ini memuat ${exam.objectiveCount} soal objektif dan ${exam.essayCount} soal essay. '
                      'Soal essay akan dinilai oleh guru setelah dikumpulkan.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...exam.questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            return _QuestionCard(
              number: i + 1,
              question: q,
              mcSelected: _mcAnswers[q.id],
              onMcChange: (v) => setState(() => _mcAnswers[q.id] = v),
              complexSelected: _complexAnswers[q.id] ?? const <int>{},
              onComplexChange: (optionIndex, selected) => setState(() {
                final answers = _complexAnswers.putIfAbsent(
                  q.id,
                  () => <int>{},
                );
                if (selected) {
                  answers.add(optionIndex);
                } else {
                  answers.remove(optionIndex);
                }
              }),
              trueFalseSelected: _trueFalseAnswers[q.id],
              onTrueFalseChange: (statementIndex, value) => setState(() {
                final answers = _trueFalseAnswers.putIfAbsent(
                  q.id,
                  () => List<bool?>.filled(q.options.length, null),
                );
                answers[statementIndex] = value;
              }),
              essayCtrl: _essayCtrls[q.id],
            );
          }),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _submit(),
            icon: const Icon(Icons.send),
            label: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.mcSelected,
    required this.onMcChange,
    required this.complexSelected,
    required this.onComplexChange,
    required this.trueFalseSelected,
    required this.onTrueFalseChange,
    required this.essayCtrl,
  });

  final int number;
  final ExamQuestion question;
  final int? mcSelected;
  final ValueChanged<int> onMcChange;
  final Set<int> complexSelected;
  final void Function(int optionIndex, bool selected) onComplexChange;
  final List<bool?>? trueFalseSelected;
  final void Function(int statementIndex, bool value) onTrueFalseChange;
  final TextEditingController? essayCtrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = question.isEssay
        ? Colors.deepPurple
        : question.isTrueFalse
        ? Colors.teal
        : question.isMultipleChoiceComplex
        ? Colors.orange.shade800
        : theme.colorScheme.primary;
    return Card(
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
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.type.label,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${question.points} poin',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$number. ${question.prompt}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (question.isMultipleChoice)
              ...question.options.asMap().entries.map(
                (opt) => RadioListTile<int>(
                  title: Text(opt.value),
                  value: opt.key,
                  groupValue: mcSelected,
                  onChanged: (v) => v == null ? null : onMcChange(v),
                  contentPadding: EdgeInsets.zero,
                ),
              )
            else if (question.isMultipleChoiceComplex)
              ...question.options.asMap().entries.map(
                (opt) => CheckboxListTile(
                  title: Text(opt.value),
                  value: complexSelected.contains(opt.key),
                  onChanged: (v) => onComplexChange(opt.key, v ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              )
            else if (question.isTrueFalse)
              ...question.options.asMap().entries.map(
                (opt) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(opt.value)),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Benar')),
                          ButtonSegment(value: false, label: Text('Salah')),
                        ],
                        selected: trueFalseSelected?[opt.key] == null
                            ? const <bool>{}
                            : {trueFalseSelected![opt.key]!},
                        emptySelectionAllowed: true,
                        onSelectionChanged: (s) {
                          if (s.isNotEmpty) {
                            onTrueFalseChange(opt.key, s.first);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              TextField(
                controller: essayCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Tulis jawaban Anda di sini...',
                  alignLabelWithHint: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
