import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'auth_shared.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(auth.errorMessage ?? 'Email atau kata sandi salah')),
      );
    }
  }

  void _quickLogin(String email) {
    _emailCtrl.text = email;
    _passCtrl.text = 'password';
    _submit();
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
                AuthTopBar(onBack: () => context.go('/')),
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
                                      title: 'Selamat Datang\nKembali',
                                      subtitle:
                                          'Masuk untuk mengakses materi, ujian, presensi, dan seluruh fitur platform pembelajaran SMK N 1 Pati.',
                                      bullets: const [
                                        (Icons.quiz_outlined,
                                            'Ujian Online Otomatis'),
                                        (Icons.menu_book_outlined,
                                            'Materi Digital Lengkap'),
                                        (Icons.fact_check_outlined,
                                            'Presensi Real-time'),
                                        (Icons.family_restroom_outlined,
                                            'Portal Orang Tua'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 52),
                                  SizedBox(
                                    width: 420,
                                    child: _LoginCard(
                                      formKey: _formKey,
                                      emailCtrl: _emailCtrl,
                                      passCtrl: _passCtrl,
                                      obscure: _obscure,
                                      busy: auth.busy,
                                      onToggleObscure: () => setState(
                                          () => _obscure = !_obscure),
                                      onSubmit: _submit,
                                      onQuickLogin: _quickLogin,
                                    ),
                                  ),
                                ],
                              )
                            : _LoginCard(
                                formKey: _formKey,
                                emailCtrl: _emailCtrl,
                                passCtrl: _passCtrl,
                                obscure: _obscure,
                                busy: auth.busy,
                                onToggleObscure: () =>
                                    setState(() => _obscure = !_obscure),
                                onSubmit: _submit,
                                onQuickLogin: _quickLogin,
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

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.busy,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onQuickLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool busy;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final void Function(String) onQuickLogin;

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
                    child: Icon(Icons.login_outlined,
                        color: scheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Masuk',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(
                        'ke akun Anda',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

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
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 14),

              // ── Password ────────────────────────────────────────────
              TextFormField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
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
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              // ── Tombol Masuk ────────────────────────────────────────
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
                    : const Text('Masuk',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),

              const SizedBox(height: 10),

              // ── Link ke Register ────────────────────────────────────
              TextButton(
                onPressed:
                    busy ? null : () => GoRouter.of(context).push('/register'),
                child: Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Belum punya akun? '),
                    TextSpan(
                      text: 'Daftar sekarang',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary),
                    ),
                  ]),
                ),
              ),

              // ── Pendaftaran Siswa ───────────────────────────────────
              OutlinedButton.icon(
                onPressed:
                    busy ? null : () => GoRouter.of(context).push('/enroll'),
                icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                label: const Text('Daftar Siswa Baru / Pindahan'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const Divider(height: 36),

              // ── Demo Accounts ───────────────────────────────────────
              Text(
                'Akun Demo  ·  password: password',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DemoChip(
                      label: 'Admin',
                      email: 'admin@sekolah.id',
                      onTap: onQuickLogin),
                  _DemoChip(
                      label: 'Guru',
                      email: 'guru@sekolah.id',
                      onTap: onQuickLogin),
                  _DemoChip(
                      label: 'Siswa',
                      email: 'siswa@sekolah.id',
                      onTap: onQuickLogin),
                  _DemoChip(
                      label: 'Orang Tua',
                      email: 'ortu@sekolah.id',
                      onTap: onQuickLogin),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip(
      {required this.label,
      required this.email,
      required this.onTap});
  final String label;
  final String email;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.person_outline, size: 14),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      onPressed: () => onTap(email),
    );
  }
}
