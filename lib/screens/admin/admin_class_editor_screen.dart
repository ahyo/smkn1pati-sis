import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_user.dart';
import '../../models/audit_log.dart';
import '../../models/school_class.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class AdminClassEditorScreen extends StatefulWidget {
  const AdminClassEditorScreen({super.key, this.classId});
  final String? classId;

  @override
  State<AdminClassEditorScreen> createState() => _AdminClassEditorScreenState();
}

class _AdminClassEditorScreenState extends State<AdminClassEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _grade = TextEditingController();
  String? _teacherId;
  Set<String> _studentIds = {};
  SchoolClass? _existing;
  bool _hydrated = false;

  @override
  void dispose() {
    _name.dispose();
    _grade.dispose();
    super.dispose();
  }

  void _hydrate(DataProvider data) {
    if (_hydrated) return;
    if (widget.classId != null) {
      final c = data.classById(widget.classId!);
      if (c != null) {
        _existing = c;
        _name.text = c.name;
        _grade.text = c.gradeLevel;
        _teacherId = c.homeroomTeacherId;
        _studentIds = {...c.studentIds};
      }
    }
    _hydrated = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final isNew = _existing == null;
    final id = _existing?.id ?? const Uuid().v4();
    final cls = SchoolClass(
      id: id,
      name: _name.text.trim(),
      gradeLevel: _grade.text.trim(),
      homeroomTeacherId: _teacherId,
      studentIds: _studentIds.toList(),
    );
    final dp = context.read<DataProvider>();
    final actor = context.read<AuthProvider>().user;
    await dp.upsertClass(cls);
    if (actor != null) {
      await dp.recordAudit(
        actor: actor,
        action: isNew ? AuditAction.classCreate : AuditAction.classUpdate,
        targetType: 'class',
        targetId: id,
        targetLabel: cls.name,
      );
    }

    // Sync student.classId with the new roster.
    for (final s in dp.users.where((u) => u.role == UserRole.student)) {
      final shouldBe = _studentIds.contains(s.id) ? id : null;
      if (s.classId == shouldBe) continue;
      // Don't yank a student out of *another* class here; only reflect this
      // class's roster changes.
      if (shouldBe == null && s.classId != id) continue;
      await dp.upsertUser(AppUser(
        id: s.id,
        email: s.email,
        name: s.name,
        role: s.role,
        classId: shouldBe,
        childrenIds: s.childrenIds,
        subjectIds: s.subjectIds,
        createdAt: s.createdAt,
      ));
    }
    if (mounted) context.go('/admin/classes');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);
    final teachers =
        data.users.where((u) => u.role == UserRole.teacher).toList();
    final students =
        data.users.where((u) => u.role == UserRole.student).toList();

    return RoleScaffold(
      title: _existing == null ? 'Tambah Kelas' : 'Edit Kelas',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              PageHeader(
                title: _existing == null
                    ? 'Tambah Kelas'
                    : 'Edit Kelas ${_existing!.name}',
                subtitle: 'Atur nama, tingkat, wali kelas, dan roster siswa.',
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
                              flex: 2,
                              child: TextFormField(
                                controller: _name,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Kelas (mis. 7A) *',
                                  prefixIcon: Icon(Icons.class_outlined),
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
                                controller: _grade,
                                decoration: const InputDecoration(
                                  labelText: 'Tingkat',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          initialValue: _teacherId,
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Belum dipilih')),
                            ...teachers.map((t) => DropdownMenuItem(
                                value: t.id, child: Text(t.name))),
                          ],
                          onChanged: (v) => setState(() => _teacherId = v),
                          decoration: const InputDecoration(
                            labelText: 'Wali Kelas',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Text('Siswa di kelas',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('${_studentIds.length} dipilih',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (students.isEmpty)
                          Text('Belum ada siswa.',
                              style: Theme.of(context).textTheme.bodySmall)
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: students.map((s) {
                              final sel = _studentIds.contains(s.id);
                              return FilterChip(
                                label: Text(s.name),
                                selected: sel,
                                onSelected: (v) => setState(() {
                                  if (v) {
                                    _studentIds.add(s.id);
                                  } else {
                                    _studentIds.remove(s.id);
                                  }
                                }),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/admin/classes'),
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
