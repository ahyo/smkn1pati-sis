import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/audit_log.dart';
import '../../models/subject.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class AdminSubjectEditorScreen extends StatefulWidget {
  const AdminSubjectEditorScreen({super.key, this.subjectId});
  final String? subjectId;

  @override
  State<AdminSubjectEditorScreen> createState() =>
      _AdminSubjectEditorScreenState();
}

class _AdminSubjectEditorScreenState extends State<AdminSubjectEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _desc = TextEditingController();
  Subject? _existing;
  bool _hydrated = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _hydrate(DataProvider data) {
    if (_hydrated) return;
    if (widget.subjectId != null) {
      final s = data.subjectById(widget.subjectId!);
      if (s != null) {
        _existing = s;
        _name.text = s.name;
        _code.text = s.code;
        _desc.text = s.description ?? '';
      }
    }
    _hydrated = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final isNew = _existing == null;
    final subject = Subject(
      id: _existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      code: _code.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    final data = context.read<DataProvider>();
    final actor = context.read<AuthProvider>().user;
    await data.upsertSubject(subject);
    if (actor != null) {
      await data.recordAudit(
        actor: actor,
        action:
            isNew ? AuditAction.subjectCreate : AuditAction.subjectUpdate,
        targetType: 'subject',
        targetId: subject.id,
        targetLabel: subject.name,
      );
    }
    if (mounted) context.go('/admin/subjects');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);

    return RoleScaffold(
      title: _existing == null ? 'Tambah Mapel' : 'Edit Mapel',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              PageHeader(
                title: _existing == null
                    ? 'Tambah Mata Pelajaran'
                    : 'Edit ${_existing!.name}',
                subtitle:
                    'Mata pelajaran dipakai oleh guru saat membuat materi & ujian.',
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _name,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Mata Pelajaran *',
                                  prefixIcon: Icon(Icons.menu_book_outlined),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _code,
                                decoration: const InputDecoration(
                                  labelText: 'Kode',
                                ),
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _desc,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  context.go('/admin/subjects'),
                              child: const Text('Batal'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(_existing == null
                                  ? 'Simpan'
                                  : 'Simpan Perubahan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
