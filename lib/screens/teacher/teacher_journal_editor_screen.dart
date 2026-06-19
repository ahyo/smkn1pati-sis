import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/teaching_journal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/role_scaffold.dart';

class TeacherJournalEditorScreen extends StatefulWidget {
  const TeacherJournalEditorScreen({super.key, this.journalId});
  final String? journalId;

  @override
  State<TeacherJournalEditorScreen> createState() =>
      _TeacherJournalEditorScreenState();
}

class _TeacherJournalEditorScreenState
    extends State<TeacherJournalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topic = TextEditingController();
  final _activities = TextEditingController();
  final _notes = TextEditingController();
  final _attendance = TextEditingController(text: '0');
  String? _classId;
  String? _subjectId;
  DateTime _date = DateTime.now();
  bool _initialized = false;

  @override
  void dispose() {
    _topic.dispose();
    _activities.dispose();
    _notes.dispose();
    _attendance.dispose();
    super.dispose();
  }

  void _hydrate(DataProvider data) {
    if (_initialized) return;
    if (widget.journalId == null) {
      _initialized = true;
      return;
    }
    final j = data.teachingJournals
        .where((j) => j.id == widget.journalId)
        .firstOrNull;
    if (j != null) {
      _topic.text = j.topic;
      _activities.text = j.activities;
      _notes.text = j.notes ?? '';
      _attendance.text = j.attendanceCount.toString();
      _classId = j.classId;
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
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null || _subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kelas dan mapel')));
      return;
    }
    final user = context.read<AuthProvider>().user!;
    final data = context.read<DataProvider>();
    final cls = data.classById(_classId!);
    final attendance = int.tryParse(_attendance.text) ?? 0;
    final journal = TeachingJournal(
      id: widget.journalId ?? const Uuid().v4(),
      teacherId: user.id,
      classId: _classId!,
      subjectId: _subjectId!,
      date: _date,
      topic: _topic.text.trim(),
      activities: _activities.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      attendanceCount: attendance,
      totalStudents: cls?.studentIds.length ?? 0,
    );
    await data.upsertTeachingJournal(journal);
    if (mounted) context.go('/teacher/journals');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);
    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

    return RoleScaffold(
      title: widget.journalId == null ? 'Jurnal Baru' : 'Edit Jurnal',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal'),
              subtitle: Text(df.format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _classId,
              items: data.classes
                  .map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => _classId = v),
              decoration: const InputDecoration(labelText: 'Kelas'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _subjectId,
              items: data.subjects
                  .map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _subjectId = v),
              decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _topic,
              decoration: const InputDecoration(labelText: 'Topik / Materi'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _activities,
              decoration: const InputDecoration(
                labelText: 'Kegiatan Pembelajaran',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Catatan / Refleksi (opsional)',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _attendance,
              decoration: InputDecoration(
                labelText: 'Jumlah Hadir',
                helperText: _classId == null
                    ? 'Pilih kelas dulu'
                    : 'Total siswa kelas: ${data.classById(_classId!)?.studentIds.length ?? 0}',
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
