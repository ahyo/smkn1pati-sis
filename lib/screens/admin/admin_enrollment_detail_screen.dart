import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_user.dart';
import '../../models/audit_log.dart';
import '../../models/enrollment_status.dart';
import '../../models/enrollment_type.dart';
import '../../models/student_enrollment.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class AdminEnrollmentDetailScreen extends StatefulWidget {
  const AdminEnrollmentDetailScreen({super.key, required this.enrollmentId});
  final String enrollmentId;

  @override
  State<AdminEnrollmentDetailScreen> createState() =>
      _AdminEnrollmentDetailScreenState();
}

class _AdminEnrollmentDetailScreenState
    extends State<AdminEnrollmentDetailScreen> {
  final _noteCtrl = TextEditingController();
  String? _selectedClassId;
  bool _busy = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(EnrollmentStatus s) {
    switch (s) {
      case EnrollmentStatus.pending:
        return Colors.orange.shade700;
      case EnrollmentStatus.approved:
        return Colors.green.shade700;
      case EnrollmentStatus.rejected:
        return Colors.red.shade700;
    }
  }

  Future<void> _approve(
      BuildContext context, StudentEnrollment e, DataProvider data) async {
    if (_busy) return;
    // Capture context-dependent objects before first await.
    final actor = context.read<AuthProvider>().user;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (_noteCtrl.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Isi catatan persetujuan terlebih dahulu.')),
      );
      return;
    }

    setState(() => _busy = true);

    final userId = const Uuid().v4();
    final newUser = AppUser(
      id: userId,
      email: e.email,
      name: e.fullName,
      role: UserRole.student,
      phone: e.phone,
      address: e.address,
      gender: e.gender,
      dateOfBirth: e.dateOfBirth,
      classId: _selectedClassId,
      createdAt: DateTime.now(),
    );
    await data.upsertUser(newUser);

    final updated = e.copyWith(
      status: EnrollmentStatus.approved,
      reviewedAt: DateTime.now(),
      reviewedByAdminId: actor?.id,
      reviewNote: _noteCtrl.text.trim(),
      requestedClassId: _selectedClassId,
      approvedUserId: userId,
    );
    await data.upsertEnrollment(updated);

    if (actor != null) {
      await data.recordAudit(
        actor: actor,
        action: AuditAction.userCreate,
        targetType: 'enrollment',
        targetId: e.id,
        targetLabel: '${e.fullName} (${e.type.label})',
        note: 'Pendaftaran disetujui, akun siswa dibuat.',
      );
    }

    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(
      const SnackBar(
          content: Text('Pendaftaran disetujui. Akun siswa telah dibuat.')),
    );
    router.go('/admin/enrollments');
  }

  Future<void> _reject(
      BuildContext context, StudentEnrollment e, DataProvider data) async {
    if (_busy) return;
    // Capture context-dependent objects before first await.
    final actor = context.read<AuthProvider>().user;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (_noteCtrl.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Isi alasan penolakan terlebih dahulu.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak pendaftaran?'),
        content: Text(
            'Pendaftaran atas nama "${e.fullName}" akan ditolak. Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    final updated = e.copyWith(
      status: EnrollmentStatus.rejected,
      reviewedAt: DateTime.now(),
      reviewedByAdminId: actor?.id,
      reviewNote: _noteCtrl.text.trim(),
    );
    await data.upsertEnrollment(updated);

    if (actor != null) {
      await data.recordAudit(
        actor: actor,
        action: AuditAction.userDelete,
        targetType: 'enrollment',
        targetId: e.id,
        targetLabel: '${e.fullName} (${e.type.label})',
        note: 'Pendaftaran ditolak: ${_noteCtrl.text.trim()}',
      );
    }

    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(const SnackBar(content: Text('Pendaftaran ditolak.')));
    router.go('/admin/enrollments');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final e = data.enrollmentById(widget.enrollmentId);

    if (e == null) {
      return RoleScaffold(
        title: 'Tidak Ditemukan',
        body: const Center(child: Text('Data pendaftaran tidak ditemukan.')),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final isPending = e.status == EnrollmentStatus.pending;
    final statusColor = _statusColor(e.status);

    return RoleScaffold(
      title: 'Detail Pendaftaran',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PageHeader(
                title: e.fullName,
                subtitle:
                    '${e.type.label} · Diterima ${_formatDate(e.createdAt)}',
              ),
              const SizedBox(height: 8),

              // Badge status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIconFor(e.status),
                            color: statusColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          e.status.label,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: (e.type == EnrollmentType.transfer
                              ? Colors.deepPurple
                              : Colors.teal.shade700)
                          .withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.type.label,
                      style: TextStyle(
                        color: e.type == EnrollmentType.transfer
                            ? Colors.deepPurple
                            : Colors.teal.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Data diri
              _InfoCard(
                title: 'Data Diri',
                children: [
                  _InfoRow(label: 'Nama', value: e.fullName),
                  _InfoRow(label: 'Email', value: e.email),
                  if (e.phone != null) _InfoRow(label: 'HP', value: e.phone!),
                  if (e.gender != null)
                    _InfoRow(label: 'Jenis Kelamin', value: e.gender!),
                  if (e.dateOfBirth != null)
                    _InfoRow(
                        label: 'Tanggal Lahir',
                        value: _formatDate(e.dateOfBirth!)),
                  if (e.address != null)
                    _InfoRow(label: 'Alamat', value: e.address!),
                ],
              ),
              const SizedBox(height: 12),

              // Asal sekolah
              _InfoCard(
                title: 'Asal Sekolah',
                children: [
                  _InfoRow(label: 'Nama Sekolah', value: e.previousSchoolName),
                  _InfoRow(label: 'Kota', value: e.previousSchoolCity),
                  _InfoRow(label: 'Jenjang', value: e.previousSchoolType),
                  if (e.previousGradeLevel != null)
                    _InfoRow(
                        label: 'Kelas Terakhir',
                        value: 'Kelas ${e.previousGradeLevel}'),
                  if (e.transferReason != null)
                    _InfoRow(
                        label: 'Alasan Pindah', value: e.transferReason!),
                ],
              ),
              const SizedBox(height: 12),

              // Hasil review (jika sudah diproses)
              if (!isPending) ...[
                _InfoCard(
                  title: 'Hasil Tinjauan',
                  children: [
                    _InfoRow(
                        label: 'Tanggal Tinjauan',
                        value: e.reviewedAt != null
                            ? _formatDate(e.reviewedAt!)
                            : '-'),
                    if (e.reviewNote != null)
                      _InfoRow(label: 'Catatan', value: e.reviewNote!),
                    if (e.status == EnrollmentStatus.approved &&
                        e.requestedClassId != null)
                      _InfoRow(
                          label: 'Kelas Ditetapkan',
                          value: data.classById(e.requestedClassId!)?.name ??
                              e.requestedClassId!),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Panel aksi (hanya jika masih pending)
              if (isPending) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'TINDAKAN ADMIN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          value: _selectedClassId,
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('— Belum ditetapkan —')),
                            ...data.classes.map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedClassId = v),
                          decoration: const InputDecoration(
                            labelText: 'Tempatkan di kelas',
                            prefixIcon: Icon(Icons.class_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _noteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Catatan admin *',
                            prefixIcon: Icon(Icons.notes_outlined),
                            alignLabelWithHint: true,
                            helperText:
                                'Wajib diisi sebelum menyetujui atau menolak.',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _busy
                                    ? null
                                    : () => _reject(context, e, data),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Tolak'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: scheme.error,
                                  side: BorderSide(color: scheme.error),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _busy
                                    ? null
                                    : () => _approve(context, e, data),
                                icon: _busy
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.check_circle_outline),
                                label: const Text('Setujui & Buat Akun'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              OutlinedButton.icon(
                onPressed: () => context.go('/admin/enrollments'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar Pendaftaran'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIconFor(EnrollmentStatus s) {
    switch (s) {
      case EnrollmentStatus.pending:
        return Icons.hourglass_empty_rounded;
      case EnrollmentStatus.approved:
        return Icons.check_circle_outline;
      case EnrollmentStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
