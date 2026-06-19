import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/enrollment_status.dart';
import '../../models/enrollment_type.dart';
import '../../models/student_enrollment.dart';
import '../../providers/data_provider.dart';

class EnrollmentFormScreen extends StatefulWidget {
  const EnrollmentFormScreen({super.key});

  @override
  State<EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends State<EnrollmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  EnrollmentType _type = EnrollmentType.newStudent;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _gender;
  DateTime? _dateOfBirth;

  final _schoolNameCtrl = TextEditingController();
  final _schoolCityCtrl = TextEditingController();
  String _schoolType = 'SMP';
  final _gradeLevelCtrl = TextEditingController();

  final _transferReasonCtrl = TextEditingController();

  bool _submitted = false;
  bool _busy = false;

  static const _schoolTypes = ['SD', 'SMP', 'SMA', 'SMK', 'MTs', 'MA'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _schoolNameCtrl.dispose();
    _schoolCityCtrl.dispose();
    _gradeLevelCtrl.dispose();
    _transferReasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ?? DateTime(now.year - 15, now.month, now.day),
      firstDate: DateTime(now.year - 25),
      lastDate: DateTime(now.year - 10),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final enrollment = StudentEnrollment(
      id: const Uuid().v4(),
      type: _type,
      status: EnrollmentStatus.pending,
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      previousSchoolName: _schoolNameCtrl.text.trim(),
      previousSchoolCity: _schoolCityCtrl.text.trim(),
      previousSchoolType: _schoolType,
      previousGradeLevel: _gradeLevelCtrl.text.trim().isEmpty
          ? null
          : _gradeLevelCtrl.text.trim(),
      transferReason: _type == EnrollmentType.transfer &&
              _transferReasonCtrl.text.trim().isNotEmpty
          ? _transferReasonCtrl.text.trim()
          : null,
      createdAt: DateTime.now(),
    );
    if (mounted) {
      await context.read<DataProvider>().upsertEnrollment(enrollment);
    }
    if (mounted) setState(() {_busy = false; _submitted = true;});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Siswa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: _submitted ? _SuccessView(onBack: () => context.go('/login')) : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: scheme.onPrimary, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Formulir Pendaftaran Siswa',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Isi data dengan lengkap dan benar. Admin akan menghubungi Anda setelah verifikasi.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tipe pendaftaran
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionLabel('Jenis Pendaftaran'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _TypeCard(
                                icon: Icons.arrow_upward_rounded,
                                title: 'Siswa Baru',
                                subtitle: 'Lulusan dari jenjang sebelumnya\n(SD/SMP/SMA)',
                                selected:
                                    _type == EnrollmentType.newStudent,
                                onTap: () => setState(
                                    () => _type = EnrollmentType.newStudent),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TypeCard(
                                icon: Icons.swap_horiz_rounded,
                                title: 'Pindahan',
                                subtitle: 'Transfer dari sekolah lain\npada jenjang yang sama',
                                selected: _type == EnrollmentType.transfer,
                                onTap: () => setState(
                                    () => _type = EnrollmentType.transfer),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Form utama
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Data diri
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionLabel('Data Diri Calon Siswa'),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Lengkap *',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Email *',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _phoneCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nomor HP / WhatsApp',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                value: _gender,
                                items: ['Laki-laki', 'Perempuan']
                                    .map((g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _gender = v),
                                decoration: const InputDecoration(
                                  labelText: 'Jenis Kelamin *',
                                  prefixIcon: Icon(Icons.wc_outlined),
                                ),
                                validator: (v) =>
                                    v == null ? 'Wajib dipilih' : null,
                              ),
                              const SizedBox(height: 14),
                              InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Tanggal Lahir *',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    _dateOfBirth == null
                                        ? 'Pilih tanggal'
                                        : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/'
                                            '${_dateOfBirth!.month.toString().padLeft(2, '0')}/'
                                            '${_dateOfBirth!.year}',
                                    style: TextStyle(
                                      color: _dateOfBirth == null
                                          ? scheme.onSurfaceVariant
                                          : scheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _addressCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Alamat Lengkap',
                                  prefixIcon: Icon(Icons.home_outlined),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Data sekolah asal
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionLabel(
                                _type == EnrollmentType.newStudent
                                    ? 'Asal Sekolah Sebelumnya'
                                    : 'Asal Sekolah (yang ditinggalkan)',
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _schoolNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Sekolah *',
                                  prefixIcon: Icon(Icons.school_outlined),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _schoolCityCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Kota / Kabupaten *',
                                  prefixIcon: Icon(Icons.location_city_outlined),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                value: _schoolType,
                                items: _schoolTypes
                                    .map((t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _schoolType = v ?? 'SMP'),
                                decoration: const InputDecoration(
                                  labelText: 'Jenjang Sekolah *',
                                  prefixIcon: Icon(Icons.layers_outlined),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _gradeLevelCtrl,
                                decoration: InputDecoration(
                                  labelText: _type == EnrollmentType.newStudent
                                      ? 'Kelas Terakhir (mis. 9, 6)'
                                      : 'Kelas Saat Ini (mis. 10, 11)',
                                  prefixIcon: const Icon(Icons.format_list_numbered_outlined),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Alasan pindah (hanya untuk transfer)
                      if (_type == EnrollmentType.transfer) ...[
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SectionLabel('Alasan Pindah'),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _transferReasonCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Alasan kepindahan',
                                    prefixIcon: Icon(Icons.notes_outlined),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 3,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _busy ? null : _submit,
                        icon: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.send_outlined),
                        label: Text(_busy
                            ? 'Mengirim...'
                            : 'Kirim Formulir Pendaftaran'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Kembali ke halaman masuk'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: Colors.green.shade700, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Formulir Berhasil Dikirim!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Terima kasih telah mendaftar. Admin sekolah akan meninjau data Anda dan menghubungi melalui email atau nomor HP yang didaftarkan.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Halaman Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? scheme.primary : scheme.onSurface,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
