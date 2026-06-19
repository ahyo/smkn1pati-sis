import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/academic_year.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/role_scaffold.dart';

class AdminAcademicYearScreen extends StatelessWidget {
  const AdminAcademicYearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final years = dp.academicYears;

    return RoleScaffold(
      title: 'Tahun Ajaran',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Tahun Ajaran',
            subtitle:
                'Kelola pergantian tahun ajaran, kenaikan kelas, dan kelulusan.',
            action: FilledButton.icon(
              onPressed: () => _showYearEditor(context, null),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tahun Ajaran Baru'),
            ),
          ),
          if (years.isEmpty)
            const Expanded(
              child: EmptyState(
                icon: Icons.calendar_today,
                title: 'Belum ada tahun ajaran',
                message:
                    'Tambahkan tahun ajaran untuk mulai mengelola kenaikan kelas.',
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: years.length,
                itemBuilder: (context, i) => _YearCard(year: years[i]),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared editor dialog (add or edit)
// ──────────────────────────────────────────────────────────────────────────────

Future<void> _showYearEditor(
    BuildContext context, AcademicYear? existing) async {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  DateTime startDate =
      existing?.startDate ?? DateTime(DateTime.now().year, 7, 14);
  DateTime endDate =
      existing?.endDate ?? DateTime(DateTime.now().year + 1, 6, 30);
  final formKey = GlobalKey<FormState>();
  final dp = context.read<DataProvider>();
  final auth = context.read<AuthProvider>();
  final messenger = ScaffoldMessenger.of(context);

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDlgState) => AlertDialog(
        title: Text(
            existing == null ? 'Tambah Tahun Ajaran' : 'Edit Tahun Ajaran'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama (mis. 2026/2027)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Mulai',
                      date: startDate,
                      onPick: (d) => setDlgState(() => startDate = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Selesai',
                      date: endDate,
                      onPick: (d) => setDlgState(() => endDate = d),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final id = existing?.id ?? 'ay_${const Uuid().v4()}';
              await dp.upsertAcademicYear(AcademicYear(
                id: id,
                name: nameCtrl.text.trim(),
                startDate: startDate,
                endDate: endDate,
                status: existing?.status ?? AcademicYearStatus.inactive,
                createdAt: existing?.createdAt ?? DateTime.now(),
                createdByAdminId:
                    existing?.createdByAdminId ?? auth.user?.id,
                promotionRunAt: existing?.promotionRunAt,
                promotionRunByAdminId: existing?.promotionRunByAdminId,
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(SnackBar(
                  content: Text(existing == null
                      ? 'Tahun ajaran ditambahkan'
                      : 'Tahun ajaran diperbarui')));
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// Year Card
// ──────────────────────────────────────────────────────────────────────────────

class _YearCard extends StatelessWidget {
  const _YearCard({required this.year});
  final AcademicYear year;

  Color _statusColor(AcademicYearStatus s) {
    switch (s) {
      case AcademicYearStatus.active:
        return Colors.green.shade700;
      case AcademicYearStatus.inactive:
        return Colors.grey.shade600;
      case AcademicYearStatus.archived:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = year.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tahun Ajaran ${year.name}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_fmtDate(year.startDate)} – ${_fmtDate(year.endDate)}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _statusColor(year.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor(year.status)
                            .withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    year.status.label,
                    style: TextStyle(
                        color: _statusColor(year.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (year.promotionDone) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle,
                      size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Kenaikan kelas dijalankan ${_fmtDate(year.promotionRunAt!)}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.green.shade700),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (year.status == AcademicYearStatus.inactive)
                  OutlinedButton.icon(
                    onPressed: () => _setActive(context),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Aktifkan'),
                  ),
                if (year.status == AcademicYearStatus.active &&
                    !year.promotionDone)
                  FilledButton.icon(
                    onPressed: () => context
                        .push('/admin/academic-years/${year.id}/promote'),
                    icon: const Icon(Icons.upgrade, size: 16),
                    label: const Text('Kenaikan Kelas & Kelulusan'),
                  ),
                if (year.status == AcademicYearStatus.active)
                  OutlinedButton.icon(
                    onPressed: () => _archive(context),
                    icon: const Icon(Icons.archive_outlined, size: 16),
                    label: const Text('Arsipkan'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _showYearEditor(context, year),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
                if (year.status != AcademicYearStatus.active)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red)),
                    onPressed: () => _delete(context),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setActive(BuildContext context) async {
    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    for (final y in dp.academicYears) {
      if (y.id != year.id && y.isActive) {
        await dp.upsertAcademicYear(
            y.copyWith(status: AcademicYearStatus.inactive));
      }
    }
    await dp
        .upsertAcademicYear(year.copyWith(status: AcademicYearStatus.active));
    messenger.showSnackBar(
        const SnackBar(content: Text('Tahun ajaran diaktifkan')));
  }

  Future<void> _archive(BuildContext context) async {
    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arsipkan Tahun Ajaran'),
        content: Text('Arsipkan tahun ajaran ${year.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Arsipkan')),
        ],
      ),
    );
    if (ok != true) return;
    await dp.upsertAcademicYear(
        year.copyWith(status: AcademicYearStatus.archived));
    messenger.showSnackBar(
        const SnackBar(content: Text('Tahun ajaran diarsipkan')));
  }

  Future<void> _delete(BuildContext context) async {
    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tahun Ajaran'),
        content: Text('Hapus tahun ajaran ${year.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    await dp.deleteAcademicYear(year.id);
    messenger
        .showSnackBar(const SnackBar(content: Text('Tahun ajaran dihapus')));
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Date field helper
// ──────────────────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField(
      {required this.label, required this.date, required this.onPick});
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 16),
          isDense: true,
        ),
        child: Text(_fmtDate(date), style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
