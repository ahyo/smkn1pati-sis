import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/academic_year.dart';
import '../../models/school_class.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class AdminClassPromotionScreen extends StatefulWidget {
  const AdminClassPromotionScreen({super.key, required this.academicYearId});
  final String academicYearId;

  @override
  State<AdminClassPromotionScreen> createState() =>
      _AdminClassPromotionScreenState();
}

class _AdminClassPromotionScreenState
    extends State<AdminClassPromotionScreen> {
  // srcClassId → dstClassId (null = graduate)
  final Map<String, String?> _mapping = {};
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initMapping());
  }

  void _initMapping() {
    final dp = context.read<DataProvider>();
    final classes = dp.classes;

    // Automatically set grade 12 → null (graduate)
    for (final c in classes) {
      if (c.gradeLevel == '12') {
        _mapping[c.id] = null;
      }
    }
    setState(() {});
  }

  bool get _allMapped {
    final dp = context.read<DataProvider>();
    for (final c in dp.classes) {
      if (c.gradeLevel == '12') continue; // always null = graduate, already set
      if (!_mapping.containsKey(c.id)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final year = dp.academicYears
        .where((y) => y.id == widget.academicYearId)
        .firstOrNull;

    if (year == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kenaikan Kelas & Kelulusan')),
        body: const Center(child: Text('Tahun ajaran tidak ditemukan.')),
      );
    }

    final classes = dp.classes;
    final grade10 = classes.where((c) => c.gradeLevel == '10').toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final grade11 = classes.where((c) => c.gradeLevel == '11').toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final grade12 = classes.where((c) => c.gradeLevel == '12').toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final destFor10 = classes.where((c) => c.gradeLevel == '11').toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final destFor11 = classes.where((c) => c.gradeLevel == '12').toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final totalAffected = classes.fold<int>(
        0, (sum, c) => sum + c.studentIds.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kenaikan Kelas – ${year.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pilih kelas tujuan untuk setiap kelas. '
                    'Kelas XII secara otomatis akan dinyatakan lulus. '
                    'Total siswa terdampak: $totalAffected orang.',
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (grade10.isNotEmpty) ...[
                  _sectionHeader('Kelas X → Naik ke Kelas XI'),
                  ...grade10.map((c) => _MappingRow(
                        srcClass: c,
                        destinations: destFor10,
                        selectedDstId: _mapping[c.id],
                        onChanged: (dstId) =>
                            setState(() => _mapping[c.id] = dstId),
                      )),
                  const SizedBox(height: 8),
                ],
                if (grade11.isNotEmpty) ...[
                  _sectionHeader('Kelas XI → Naik ke Kelas XII'),
                  ...grade11.map((c) => _MappingRow(
                        srcClass: c,
                        destinations: destFor11,
                        selectedDstId: _mapping[c.id],
                        onChanged: (dstId) =>
                            setState(() => _mapping[c.id] = dstId),
                      )),
                  const SizedBox(height: 8),
                ],
                if (grade12.isNotEmpty) ...[
                  _sectionHeader('Kelas XII → Lulus'),
                  ...grade12.map((c) => _GraduateRow(srcClass: c)),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: (_allMapped && !_running) ? () => _confirm(year) : null,
            icon: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.upgrade),
            label: const Text('Jalankan Kenaikan Kelas & Kelulusan'),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _confirm(AcademicYear year) async {
    final dp = context.read<DataProvider>();
    final auth = context.read<AuthProvider>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final classes = dp.classes;
        final lines = <String>[];
        for (final entry in _mapping.entries) {
          final src = classes.where((c) => c.id == entry.key).firstOrNull;
          if (src == null) continue;
          final count = src.studentIds.length;
          if (entry.value == null) {
            lines.add('• ${src.name} ($count siswa) → Lulus');
          } else {
            final dst =
                classes.where((c) => c.id == entry.value).firstOrNull;
            lines.add('• ${src.name} ($count siswa) → ${dst?.name ?? '-'}');
          }
        }
        return AlertDialog(
          title: const Text('Konfirmasi Kenaikan Kelas'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Proses ini tidak dapat dibatalkan. '
                  'Semua siswa akan dipindahkan sesuai pemetaan berikut:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                ...lines.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(l, style: const TextStyle(fontSize: 13)),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Jalankan'),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    setState(() => _running = true);
    try {
      await dp.runClassPromotion(
        mapping: _mapping,
        academicYearId: year.id,
        adminId: auth.user?.id ?? '',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kenaikan kelas & kelulusan berhasil dijalankan'),
          backgroundColor: Colors.green,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Row for a class that needs a destination mapping
// ──────────────────────────────────────────────────────────────────────────────

class _MappingRow extends StatelessWidget {
  const _MappingRow({
    required this.srcClass,
    required this.destinations,
    required this.selectedDstId,
    required this.onChanged,
  });

  final SchoolClass srcClass;
  final List<SchoolClass> destinations;
  final String? selectedDstId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final studentCount = srcClass.studentIds.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Source class
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    srcClass.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '$studentCount siswa',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            // Destination dropdown
            Expanded(
              child: destinations.isEmpty
                  ? Text(
                      'Tidak ada kelas tujuan',
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 13),
                    )
                  : InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        isDense: true,
                      ),
                      child: DropdownButton<String>(
                      value: selectedDstId,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: const Text('Pilih kelas tujuan'),
                      items: destinations
                          .map((d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              ))
                          .toList(),
                      onChanged: onChanged,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Row for a grade-12 class (always graduates)
// ──────────────────────────────────────────────────────────────────────────────

class _GraduateRow extends StatelessWidget {
  const _GraduateRow({required this.srcClass});
  final SchoolClass srcClass;

  @override
  Widget build(BuildContext context) {
    final studentCount = srcClass.studentIds.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    srcClass.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '$studentCount siswa',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'Lulus',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
