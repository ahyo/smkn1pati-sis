import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final data = context.watch<DataProvider>();
    if (user == null) {
      return const RoleScaffold(
        title: 'Profil',
        body: Center(child: Text('Tidak ada sesi pengguna')),
      );
    }
    final df = DateFormat('dd MMMM yyyy', 'id_ID');
    final theme = Theme.of(context);

    String fmtDate(DateTime? d) => d == null ? '-' : df.format(d);
    String orDash(String? s) => (s == null || s.isEmpty) ? '-' : s;

    final cls = user.classId == null ? null : data.classById(user.classId!);
    final subjectNames = user.subjectIds
        .map((id) => data.subjectById(id)?.name)
        .whereType<String>()
        .toList();
    final children = user.childrenIds
        .map((id) => data.userById(id))
        .whereType<AppUser>()
        .toList();

    return RoleScaffold(
      title: 'Profil',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              PageHeader(
                title: 'Profil Saya',
                subtitle: 'Lihat dan kelola informasi akun Anda',
                action: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/profile/change-password'),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Ubah Sandi'),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/profile/edit'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profil'),
                    ),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        child: Text(
                          user.name.isEmpty
                              ? '?'
                              : user.name[0].toUpperCase(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(user.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(user.role.label,
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ),
                            const SizedBox(height: 8),
                            Text(user.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                            if (user.bio != null && user.bio!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(user.bio!,
                                  style: theme.textTheme.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Identitas',
                rows: [
                  _Row('${user.role.identityLabel}',
                      orDash(user.identityNumber)),
                  _Row('Jenis Kelamin', orDash(user.gender)),
                  _Row('Tanggal Lahir', fmtDate(user.dateOfBirth)),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Kontak',
                rows: [
                  _Row('Email', user.email),
                  _Row('Nomor HP', orDash(user.phone)),
                  _Row('Alamat Rumah', orDash(user.address)),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: _roleContextTitle(user.role),
                rows: _roleContextRows(
                  user: user,
                  cls: cls?.name,
                  subjectNames: subjectNames,
                  childrenNames: children.map((c) => c.name).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Akun',
                rows: [
                  _Row('Bergabung sejak', df.format(user.createdAt)),
                  _Row('ID Pengguna', user.id),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _roleContextTitle(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Hak Akses';
      case UserRole.teacher:
        return 'Mengajar';
      case UserRole.student:
        return 'Akademik';
      case UserRole.parent:
        return 'Anak';
    }
  }

  List<_Row> _roleContextRows({
    required AppUser user,
    String? cls,
    required List<String> subjectNames,
    required List<String> childrenNames,
  }) {
    switch (user.role) {
      case UserRole.admin:
        return const [
          _Row('Peran', 'Administrator sistem'),
          _Row('Akses',
              'Manajemen pengguna, kelas, mapel, nilai, dan pengaturan'),
        ];
      case UserRole.teacher:
        return [
          _Row(
              'Mata Pelajaran',
              subjectNames.isEmpty
                  ? '-'
                  : subjectNames.join(', ')),
        ];
      case UserRole.student:
        return [
          _Row('Kelas', cls ?? '-'),
        ];
      case UserRole.parent:
        return [
          _Row(
              'Anak',
              childrenNames.isEmpty
                  ? '-'
                  : childrenNames.join(', ')),
        ];
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 12),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(rows[i].label,
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(rows[i].value,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
}
