import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/study_journal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/role_scaffold.dart';

class StudentJournalEditorScreen extends StatefulWidget {
  const StudentJournalEditorScreen({super.key, this.journalId});
  final String? journalId;

  @override
  State<StudentJournalEditorScreen> createState() =>
      _StudentJournalEditorScreenState();
}

class _StudentJournalEditorScreenState
    extends State<StudentJournalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topic = TextEditingController();
  final _summary = TextEditingController();
  final _duration = TextEditingController(text: '30');
  String? _subjectId;
  DateTime _date = DateTime.now();
  bool _initialized = false;

  @override
  void dispose() {
    _topic.dispose();
    _summary.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _hydrate(DataProvider data) {
    if (_initialized) return;
    if (widget.journalId == null) {
      _initialized = true;
      return;
    }
    final j =
        data.studyJournals.where((j) => j.id == widget.journalId).firstOrNull;
    if (j != null) {
      _topic.text = j.topic;
      _summary.text = j.summary;
      _duration.text = j.durationMinutes.toString();
      _subjectId = j.subjectId;
      _date = j.date;
    }
    _initialized = true;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user!;
    final data = context.read<DataProvider>();
    final journal = StudyJournal(
      id: widget.journalId ?? const Uuid().v4(),
      studentId: user.id,
      subjectId: _subjectId,
      date: _date,
      topic: _topic.text.trim(),
      summary: _summary.text.trim(),
      durationMinutes: int.tryParse(_duration.text) ?? 0,
    );
    await data.upsertStudyJournal(journal);
    if (mounted) context.go('/student/journals');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);
    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

    return RoleScaffold(
      title: widget.journalId == null ? 'Catat Belajar' : 'Edit Jurnal',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal belajar'),
              subtitle: Text(df.format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _subjectId,
              items: [
                const DropdownMenuItem(value: null, child: Text('Umum')),
                ...data.subjects.map((s) =>
                    DropdownMenuItem(value: s.id, child: Text(s.name))),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
              decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _topic,
              decoration:
                  const InputDecoration(labelText: 'Apa yang dipelajari?'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _summary,
              decoration: const InputDecoration(
                labelText: 'Ringkasan / Catatan',
                alignLabelWithHint: true,
                helperText:
                    'Tuliskan apa yang sudah kamu pahami dan apa yang belum',
              ),
              maxLines: 6,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _duration,
              decoration: const InputDecoration(
                labelText: 'Durasi belajar (menit)',
              ),
              keyboardType: TextInputType.number,
            ),
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
