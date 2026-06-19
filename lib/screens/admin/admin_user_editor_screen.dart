import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_user.dart';
import '../../models/audit_log.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class AdminUserEditorScreen extends StatefulWidget {
  const AdminUserEditorScreen({super.key, this.userId});
  final String? userId;

  @override
  State<AdminUserEditorScreen> createState() => _AdminUserEditorScreenState();
}

class _AdminUserEditorScreenState extends State<AdminUserEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  UserRole _role = UserRole.student;
  String? _classId;
  Set<String> _childrenIds = {};
  Set<String> _subjectIds = {};
  AppUser? _existing;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _hydrate(DataProvider data) {
    if (_hydrated) return;
    if (widget.userId != null) {
      final u = data.userById(widget.userId!);
      if (u != null) {
        _existing = u;
        _name.text = u.name;
        _email.text = u.email;
        _role = u.role;
        _classId = u.classId;
        _childrenIds = {...u.childrenIds};
        _subjectIds = {...u.subjectIds};
      }
    }
    _hydrated = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final isNew = _existing == null;
    final user = AppUser(
      id: _existing?.id ?? const Uuid().v4(),
      email: _email.text.trim(),
      name: _name.text.trim(),
      role: _role,
      classId: _role == UserRole.student ? _classId : null,
      childrenIds:
          _role == UserRole.parent ? _childrenIds.toList() : const [],
      subjectIds:
          _role == UserRole.teacher ? _subjectIds.toList() : const [],
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    final data = context.read<DataProvider>();
    final actor = context.read<AuthProvider>().user;
    await data.upsertUser(user);
    if (actor != null) {
      await data.recordAudit(
        actor: actor,
        action: isNew ? AuditAction.userCreate : AuditAction.userUpdate,
        targetType: 'user',
        targetId: user.id,
        targetLabel: '${user.name} (${user.role.label})',
      );
    }
    if (mounted) context.go('/admin/users');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    _hydrate(data);

    return RoleScaffold(
      title: _existing == null ? 'Tambah Pengguna' : 'Edit Pengguna',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              PageHeader(
                title: _existing == null
                    ? 'Tambah Pengguna'
                    : 'Edit ${_existing!.name}',
                subtitle:
                    'Lengkapi informasi pengguna. Field yang ditandai * wajib diisi.',
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionLabel('Identitas'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Nama lengkap *',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel('Peran'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<UserRole>(
                          initialValue: _role,
                          items: UserRole.values
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r.label),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(
                              () => _role = v ?? UserRole.student),
                          decoration: const InputDecoration(
                            labelText: 'Peran *',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        if (_role == UserRole.student) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String?>(
                            initialValue: _classId,
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('Tanpa kelas')),
                              ...data.classes.map((c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.name))),
                            ],
                            onChanged: (v) => setState(() => _classId = v),
                            decoration: const InputDecoration(
                              labelText: 'Kelas',
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                          ),
                        ],
                        if (_role == UserRole.parent) ...[
                          const SizedBox(height: 24),
                          _SectionLabel('Anak (siswa)'),
                          const SizedBox(height: 8),
                          _ChipPicker(
                            options: data.users
                                .where((u) => u.role == UserRole.student)
                                .map((s) => _ChipOption(s.id, s.name))
                                .toList(),
                            selected: _childrenIds,
                            onChange: (v) =>
                                setState(() => _childrenIds = v),
                          ),
                        ],
                        if (_role == UserRole.teacher) ...[
                          const SizedBox(height: 24),
                          _SectionLabel('Mata pelajaran diampu'),
                          const SizedBox(height: 8),
                          _ChipPicker(
                            options: data.subjects
                                .map((s) => _ChipOption(s.id, s.name))
                                .toList(),
                            selected: _subjectIds,
                            onChange: (v) =>
                                setState(() => _subjectIds = v),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/admin/users'),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ChipOption {
  const _ChipOption(this.id, this.label);
  final String id;
  final String label;
}

class _ChipPicker extends StatelessWidget {
  const _ChipPicker({
    required this.options,
    required this.selected,
    required this.onChange,
  });

  final List<_ChipOption> options;
  final Set<String> selected;
  final void Function(Set<String>) onChange;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text(
        'Tidak ada opsi tersedia',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSel = selected.contains(o.id);
        return FilterChip(
          label: Text(o.label),
          selected: isSel,
          onSelected: (v) {
            final next = {...selected};
            if (v) {
              next.add(o.id);
            } else {
              next.remove(o.id);
            }
            onChange(next);
          },
        );
      }).toList(),
    );
  }
}
