import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/exam.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/csv_download.dart';
import '../../utils/exam_csv_import.dart';
import '../../widgets/role_scaffold.dart';

IconData _questionTypeIcon(QuestionType type) {
  switch (type) {
    case QuestionType.multipleChoice:
      return Icons.radio_button_checked;
    case QuestionType.multipleChoiceComplex:
      return Icons.checklist_outlined;
    case QuestionType.trueFalse:
      return Icons.rule_outlined;
    case QuestionType.essay:
      return Icons.notes_outlined;
  }
}

class TeacherExamEditorScreen extends StatefulWidget {
  const TeacherExamEditorScreen({super.key, this.examId});
  final String? examId;

  @override
  State<TeacherExamEditorScreen> createState() =>
      _TeacherExamEditorScreenState();
}

class _TeacherExamEditorScreenState extends State<TeacherExamEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  String? _subjectId;
  String? _classId;
  DateTime _startAt = DateTime.now();
  DateTime _endAt = DateTime.now().add(const Duration(days: 1));
  final List<ExamQuestion> _questions = [];
  bool _initialized = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _hydrate(DataProvider data) {
    if (_initialized) return;
    if (widget.examId == null) {
      _initialized = true;
      return;
    }
    final ex = data.examById(widget.examId!);
    if (ex != null) {
      _titleCtrl.text = ex.title;
      _descCtrl.text = ex.description;
      _durationCtrl.text = ex.durationMinutes.toString();
      _subjectId = ex.subjectId;
      _classId = ex.classId;
      _startAt = ex.startAt;
      _endAt = ex.endAt;
      _questions
        ..clear()
        ..addAll(ex.questions);
    }
    _initialized = true;
  }

  Future<void> _downloadTemplate() async {
    try {
      await downloadCsvTemplate(kCsvTemplateContent, kCsvTemplateName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh template: $e')),
      );
    }
  }

  Future<void> _uploadQuestions() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;

    final bytes = picked.files.first.bytes;
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membaca file')),
      );
      return;
    }

    final content = utf8.decode(bytes, allowMalformed: true);
    final importResult = parseQuestionsFromCsv(content);

    if (!mounted) return;

    if (!importResult.hasQuestions && importResult.hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(importResult.errors.first)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ImportPreviewDialog(
        result: importResult,
        existingCount: _questions.length,
      ),
    );

    if (confirmed == true && importResult.hasQuestions && mounted) {
      setState(() => _questions.addAll(importResult.questions));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${importResult.questions.length} soal berhasil diimpor'),
        ),
      );
    }
  }

  Future<void> _addOrEditQuestion([ExamQuestion? existing]) async {
    final result = await Navigator.of(context).push<ExamQuestion>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _QuestionEditorPage(existing: existing),
      ),
    );
    if (result != null) {
      setState(() {
        if (existing == null) {
          _questions.add(result);
        } else {
          final idx = _questions.indexWhere((q) => q.id == existing.id);
          if (idx >= 0) _questions[idx] = result;
        }
      });
    }
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return null;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjectId == null || _classId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih mapel dan kelas')));
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu soal')),
      );
      return;
    }
    final user = context.read<AuthProvider>().user!;
    final data = context.read<DataProvider>();
    final exam = Exam(
      id: widget.examId ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      subjectId: _subjectId!,
      classId: _classId!,
      teacherId: user.id,
      durationMinutes: int.tryParse(_durationCtrl.text) ?? 60,
      startAt: _startAt,
      endAt: _endAt,
      questions: _questions,
    );
    await data.upsertExam(exam);
    if (mounted) context.go('/teacher/exams');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);
    return RoleScaffold(
      title: widget.examId == null ? 'Ujian Baru' : 'Edit Ujian',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _subjectId,
              items: data.subjects
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _subjectId = v),
              decoration: const InputDecoration(labelText: 'Mapel'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _classId,
              items: data.classes
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _classId = v),
              decoration: const InputDecoration(labelText: 'Kelas'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationCtrl,
              decoration: const InputDecoration(labelText: 'Durasi (menit)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mulai'),
              subtitle: Text(_startAt.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final dt = await _pickDateTime(_startAt);
                if (dt != null) setState(() => _startAt = dt);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Selesai'),
              subtitle: Text(_endAt.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final dt = await _pickDateTime(_endAt);
                if (dt != null) setState(() => _endAt = dt);
              },
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Soal (${_questions.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _downloadTemplate,
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Template'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: _uploadQuestions,
                  icon: const Icon(Icons.upload_file_outlined, size: 16),
                  label: const Text('Upload CSV'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(width: 6),
                FilledButton.tonalIcon(
                  onPressed: () => _addOrEditQuestion(),
                  icon: const Icon(Icons.add),
                  label: const Text('Soal'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._questions.asMap().entries.map((entry) {
              final q = entry.value;
              final isEssay = q.isEssay;
              final theme = Theme.of(context);
              final badgeColor = isEssay
                  ? Colors.deepPurple
                  : q.isTrueFalse
                  ? Colors.teal
                  : q.isMultipleChoiceComplex
                  ? Colors.orange.shade800
                  : theme.colorScheme.primary;
              return Card(
                child: ListTile(
                  title: Row(
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
                          q.type.label,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.key + 1}. ${q.prompt}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    isEssay
                        ? 'Essay • Dinilai manual • ${q.points} poin${q.sampleAnswer != null ? ' • Ada rubrik' : ''}'
                        : q.isMultipleChoiceComplex
                        ? '${q.options.length} opsi • ${q.correctIndexes.length} jawaban benar • ${q.points} poin'
                        : q.isTrueFalse
                        ? '${q.options.length} pernyataan • ${q.points} poin'
                        : '${q.options.length} opsi • Jawaban benar: ${q.correctIndex + 1} • ${q.points} poin',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditQuestion(q),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(
                          () => _questions.removeWhere((x) => x.id == q.id),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({
    required this.result,
    required this.existingCount,
  });

  final CsvImportResult result;
  final int existingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Preview Import Soal'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.hasErrors) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            size: 16, color: theme.colorScheme.error),
                        const SizedBox(width: 4),
                        Text(
                          '${result.errors.length} peringatan',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...result.errors.take(3).map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text('• $e',
                                style: theme.textTheme.bodySmall),
                          ),
                        ),
                    if (result.errors.length > 3)
                      Text(
                        '... dan ${result.errors.length - 3} peringatan lainnya',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (result.hasQuestions) ...[
              Text(
                '${result.questions.length} soal akan ditambahkan'
                '${existingCount > 0 ? ' ke $existingCount soal yang sudah ada' : ''}.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: result.questions.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1),
                  itemBuilder: (_, i) => _QuestionPreviewTile(
                    index: i,
                    question: result.questions[i],
                  ),
                ),
              ),
            ] else
              Text(
                'Tidak ada soal yang berhasil dibaca dari file.',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        if (result.hasQuestions)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Tambahkan ${result.questions.length} Soal'),
          ),
      ],
    );
  }
}

class _QuestionPreviewTile extends StatelessWidget {
  const _QuestionPreviewTile({required this.index, required this.question});

  final int index;
  final ExamQuestion question;

  Color _typeColor(BuildContext context) {
    return switch (question.type) {
      QuestionType.multipleChoice =>
        Theme.of(context).colorScheme.primary,
      QuestionType.multipleChoiceComplex => Colors.orange.shade800,
      QuestionType.trueFalse => Colors.teal,
      QuestionType.essay => Colors.deepPurple,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _typeColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              question.type.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              question.prompt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            '${question.points}p',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionEditorPage extends StatefulWidget {
  const _QuestionEditorPage({this.existing});
  final ExamQuestion? existing;

  @override
  State<_QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<_QuestionEditorPage> {
  final _promptCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '10');
  final _sampleCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [];
  int _correctIndex = 0;
  final Set<int> _correctIndexes = {};
  final List<bool> _trueFalseAnswers = [];
  QuestionType _type = QuestionType.multipleChoice;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _promptCtrl.text = e.prompt;
      _pointsCtrl.text = e.points.toString();
      _type = e.type;
      _sampleCtrl.text = e.sampleAnswer ?? '';
      for (final opt in e.options) {
        _optionCtrls.add(TextEditingController(text: opt));
      }
      _correctIndex = e.correctIndex;
      _correctIndexes.addAll(e.correctIndexes);
      _trueFalseAnswers.addAll(e.trueFalseAnswers);
    } else {
      _optionCtrls.addAll(List.generate(4, (_) => TextEditingController()));
      _trueFalseAnswers.addAll(List.filled(4, true));
    }
    while (_trueFalseAnswers.length < _optionCtrls.length) {
      _trueFalseAnswers.add(true);
    }
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _pointsCtrl.dispose();
    _sampleCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveQuestion() {
    if (_promptCtrl.text.trim().isEmpty) {
      _showMessage('Pertanyaan wajib diisi');
      return;
    }
    final id = widget.existing?.id ?? const Uuid().v4();
    final points = int.tryParse(_pointsCtrl.text) ?? 10;

    if (_type == QuestionType.multipleChoice ||
        _type == QuestionType.multipleChoiceComplex) {
      final options = _optionCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (options.length < 2) {
        _showMessage('Soal pilihan ganda butuh minimal 2 opsi');
        return;
      }
      if (_type == QuestionType.multipleChoiceComplex &&
          _correctIndexes.isEmpty) {
        _showMessage('Centang minimal satu jawaban benar');
        return;
      }
      final correct = _correctIndex.clamp(0, options.length - 1);
      Navigator.pop(
        context,
        ExamQuestion(
          id: id,
          type: _type,
          prompt: _promptCtrl.text.trim(),
          options: options,
          correctIndex: correct,
          correctIndexes:
              _correctIndexes
                  .where((i) => i >= 0 && i < options.length)
                  .toList()
                ..sort(),
          points: points,
        ),
      );
    } else if (_type == QuestionType.trueFalse) {
      final entries = <String>[];
      final keys = <bool>[];
      for (var i = 0; i < _optionCtrls.length; i++) {
        final text = _optionCtrls[i].text.trim();
        if (text.isEmpty) continue;
        entries.add(text);
        keys.add(_trueFalseAnswers[i]);
      }
      if (entries.isEmpty) {
        _showMessage('Tambahkan minimal satu pernyataan');
        return;
      }
      Navigator.pop(
        context,
        ExamQuestion(
          id: id,
          type: QuestionType.trueFalse,
          prompt: _promptCtrl.text.trim(),
          options: entries,
          trueFalseAnswers: keys,
          points: points,
        ),
      );
    } else {
      Navigator.pop(
        context,
        ExamQuestion(
          id: id,
          type: QuestionType.essay,
          prompt: _promptCtrl.text.trim(),
          sampleAnswer: _sampleCtrl.text.trim().isEmpty
              ? null
              : _sampleCtrl.text.trim(),
          points: points,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Soal Baru' : 'Edit Soal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveQuestion,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Simpan'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<QuestionType>(
                initialValue: _type,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Jenis Soal'),
                items: QuestionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_questionTypeIcon(type), size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(type.label)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type != null) setState(() => _type = type);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptCtrl,
                decoration: const InputDecoration(labelText: 'Pertanyaan'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pointsCtrl,
                decoration: const InputDecoration(labelText: 'Poin'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              if (_type == QuestionType.multipleChoice ||
                  _type == QuestionType.multipleChoiceComplex) ...[
                Text(
                  _type == QuestionType.multipleChoice
                      ? 'Pilihan jawaban (pilih radio untuk jawaban benar)'
                      : 'Pilihan jawaban (centang semua jawaban benar)',
                ),
                const SizedBox(height: 8),
                ..._optionCtrls.asMap().entries.map(
                  (e) => Row(
                    children: [
                      if (_type == QuestionType.multipleChoice)
                        Radio<int>(
                          value: e.key,
                          groupValue: _correctIndex,
                          onChanged: (v) => setState(() => _correctIndex = v!),
                        )
                      else
                        Checkbox(
                          value: _correctIndexes.contains(e.key),
                          onChanged: (v) => setState(() {
                            if (v ?? false) {
                              _correctIndexes.add(e.key);
                            } else {
                              _correctIndexes.remove(e.key);
                            }
                          }),
                        ),
                      Expanded(
                        child: TextField(
                          controller: e.value,
                          decoration: InputDecoration(
                            labelText: 'Opsi ${e.key + 1}',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _optionCtrls.length > 2
                            ? () => setState(() {
                                final removedIndex = e.key;
                                final shiftedCorrectIndexes = _correctIndexes
                                    .where((i) => i != removedIndex)
                                    .map((i) => i > removedIndex ? i - 1 : i)
                                    .where((i) => i >= 0)
                                    .toSet();
                                _optionCtrls.removeAt(e.key);
                                _correctIndexes
                                  ..clear()
                                  ..addAll(
                                    shiftedCorrectIndexes.where(
                                      (i) => i < _optionCtrls.length,
                                    ),
                                  );
                                if (_trueFalseAnswers.length > e.key) {
                                  _trueFalseAnswers.removeAt(e.key);
                                }
                                if (_correctIndex == removedIndex) {
                                  _correctIndex = 0;
                                } else if (_correctIndex > removedIndex) {
                                  _correctIndex--;
                                } else if (_correctIndex >=
                                    _optionCtrls.length) {
                                  _correctIndex = 0;
                                }
                              })
                            : null,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _optionCtrls.add(TextEditingController());
                    _trueFalseAnswers.add(true);
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah opsi'),
                ),
              ] else if (_type == QuestionType.trueFalse) ...[
                const Text('Pernyataan dan kunci benar/salah'),
                const SizedBox(height: 8),
                ..._optionCtrls.asMap().entries.map(
                  (e) => Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: e.value,
                          decoration: InputDecoration(
                            labelText: 'Pernyataan ${e.key + 1}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Benar')),
                          ButtonSegment(value: false, label: Text('Salah')),
                        ],
                        selected: {_trueFalseAnswers[e.key]},
                        onSelectionChanged: (s) =>
                            setState(() => _trueFalseAnswers[e.key] = s.first),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _optionCtrls.length > 1
                            ? () => setState(() {
                                _optionCtrls.removeAt(e.key);
                                _trueFalseAnswers.removeAt(e.key);
                              })
                            : null,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _optionCtrls.add(TextEditingController());
                    _trueFalseAnswers.add(true);
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah pernyataan'),
                ),
              ] else ...[
                TextField(
                  controller: _sampleCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Contoh / Kunci Jawaban (rubrik)',
                    alignLabelWithHint: true,
                    helperText:
                        'Disimpan sebagai rubrik. Tidak ditampilkan ke siswa, dipakai guru saat menilai.',
                    helperMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Soal essay dinilai manual oleh guru di halaman submisi.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _saveQuestion,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Soal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
