import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/learning_material.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/role_scaffold.dart';

class TeacherMaterialEditorScreen extends StatefulWidget {
  const TeacherMaterialEditorScreen({super.key, this.materialId});
  final String? materialId;

  @override
  State<TeacherMaterialEditorScreen> createState() =>
      _TeacherMaterialEditorScreenState();
}

class _TeacherMaterialEditorScreenState
    extends State<TeacherMaterialEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String? _subjectId;
  String? _classId;
  bool _initialized = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _hydrate(DataProvider data) {
    if (_initialized) return;
    if (widget.materialId == null) {
      _initialized = true;
      return;
    }
    final existing = data.materials.firstWhere(
      (m) => m.id == widget.materialId,
      orElse: () => LearningMaterial(
        id: '',
        title: '',
        content: '',
        subjectId: '',
        classId: '',
        teacherId: '',
        createdAt: DateTime.now(),
      ),
    );
    if (existing.id.isNotEmpty) {
      _titleCtrl.text = existing.title;
      _contentCtrl.text = existing.content;
      _subjectId = existing.subjectId;
      _classId = existing.classId;
    }
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjectId == null || _classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mapel dan kelas')),
      );
      return;
    }
    final user = context.read<AuthProvider>().user!;
    final data = context.read<DataProvider>();
    final id = widget.materialId ?? const Uuid().v4();
    final existing = widget.materialId == null
        ? null
        : data.materials.where((m) => m.id == widget.materialId).firstOrNull;
    final material = LearningMaterial(
      id: id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      subjectId: _subjectId!,
      classId: _classId!,
      teacherId: user.id,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await data.upsertMaterial(material);
    if (mounted) context.go('/teacher/materials');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);
    return RoleScaffold(
      title: widget.materialId == null ? 'Materi Baru' : 'Edit Materi',
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
            TextFormField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: 'Isi Materi',
                alignLabelWithHint: true,
              ),
              maxLines: 12,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib' : null,
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
