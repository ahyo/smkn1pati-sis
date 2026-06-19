import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import 'auth_shared.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole _role = UserRole.student;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final profile = AppUser(
      id: const Uuid().v4(),
      email: _emailCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      role: _role,
      createdAt: DateTime.now(),
    );
    final ok = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      name: _nameCtrl.text.trim(),
      profile: profile,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Gagal mendaftar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const AuthGradientBg(),
          SafeArea(
            child: Column(
              children: [
                AuthTopBar(onBack: () => context.go('/login')),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 840;
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          wide ? 60 : 20,
                          wide ? 40 : 16,
                          wide ? 60 : 20,
                          40,
                        ),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: AuthInfoPanel(
                                      tag: 'Sistem Manajemen Pembelajaran',
                                      title: 'Bergabunglah\nBersama Kami',
                                      subtitle:
                                          'Buat akun untuk mengakses seluruh fitur platform pembelajaran digital SMK N 1 Pati.',
                                      bullets: const [
                                        (Icons.person_add_outlined,
                                            'Daftar sebagai Guru atau Siswa'),
                                        (Icons.menu_book_outlined,
                                            'Akses Materi & Ujian'),
                                        (Icons.notifications_outlined,
                                            'Notifikasi Kegiatan Sekolah'),
                                        (Icons.security_outlined,
                                            'Akses Aman Berbasis Peran'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 52),
                                  SizedBox(
                                    width: 420,
                                    child: _RegisterCard(
                                      formKey: _formKey,
                                      nameCtrl: _nameCtrl,
                                      emailCtrl: _emailCtrl,
                                      passCtrl: _passCtrl,
                                      role: _role,
                                      obscure: _obscure,
                                      busy: auth.busy,
                                      onRoleChanged: (r) =>
                                          setState(() => _role = r),
                                      onToggleObscure: () =>
                                          setState(() => _obscure = !_obscure),
                                      onSubmit: _submit,
                                    ),
                                  ),
                                ],
                              )
                            : _RegisterCard(
                                formKey: _formKey,
                                nameCtrl: _nameCtrl,
                                emailCtrl: _emailCtrl,
                                passCtrl: _passCtrl,
                                role: _role,
                                obscure: _obscure,
                                busy: auth.busy,
                                onRoleChanged: (r) =>
                                    setState(() => _role = r),
                                onToggleObscure: () =>
                                    setState(() => _obscure = !_obscure),
                                onSubmit: _submit,
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.role,
    required this.obscure,
    required this.busy,
    required this.onRoleChanged,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final UserRole role;
  final bool obscure;
  final bool busy;
  final void Function(UserRole) onRoleChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 20,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.person_add_outlined,
                        color: scheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buat Akun',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(
                        'Daftar untuk mulai belajar',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Nama Lengkap ────────────────────────────────────────
              TextFormField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 14),

              // ── Email ───────────────────────────────────────────────
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'contoh@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ── Kata Sandi ──────────────────────────────────────────
              TextFormField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: onToggleObscure,
                    tooltip: obscure ? 'Tampilkan' : 'Sembunyikan',
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Minimal 6 karakter'
                    : null,
              ),

              const SizedBox(height: 14),

              // ── Role ────────────────────────────────────────────────
              DropdownButtonFormField<UserRole>(
                initialValue: role,
                decoration: InputDecoration(
                  labelText: 'Daftar sebagai',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                ),
                items: UserRole.values
                    .where((r) => r != UserRole.admin)
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Row(
                            children: [
                              Icon(_roleIcon(r),
                                  size: 16, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text(r.label),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onRoleChanged(v);
                },
              ),

              const SizedBox(height: 24),

              // ── Tombol Daftar ───────────────────────────────────────
              FilledButton(
                onPressed: busy ? null : onSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Buat Akun',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),

              const SizedBox(height: 12),

              // ── Link ke Login ───────────────────────────────────────
              TextButton(
                onPressed:
                    busy ? null : () => GoRouter.of(context).go('/login'),
                child: Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Sudah punya akun? '),
                    TextSpan(
                      text: 'Masuk di sini',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary),
                    ),
                  ]),
                ),
              ),

              // ── Info ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 15, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Akun baru perlu diverifikasi oleh admin sekolah sebelum dapat mengakses semua fitur.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimaryContainer, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _roleIcon(UserRole r) => switch (r) {
        UserRole.student => Icons.school_outlined,
        UserRole.teacher => Icons.person_outlined,
        UserRole.parent => Icons.family_restroom_outlined,
        UserRole.admin => Icons.admin_panel_settings_outlined,
      };
}
