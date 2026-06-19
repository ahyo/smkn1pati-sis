import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/enrollment_status.dart';
import '../../models/enrollment_type.dart';
import '../../models/student_enrollment.dart';
import '../../providers/data_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class AdminEnrollmentsScreen extends StatefulWidget {
  const AdminEnrollmentsScreen({super.key});

  @override
  State<AdminEnrollmentsScreen> createState() => _AdminEnrollmentsScreenState();
}

class _AdminEnrollmentsScreenState extends State<AdminEnrollmentsScreen> {
  EnrollmentStatus? _statusFilter;
  EnrollmentType? _typeFilter;

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

  IconData _statusIcon(EnrollmentStatus s) {
    switch (s) {
      case EnrollmentStatus.pending:
        return Icons.hourglass_empty_rounded;
      case EnrollmentStatus.approved:
        return Icons.check_circle_outline;
      case EnrollmentStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  bool _matches(StudentEnrollment e) {
    if (_statusFilter != null && e.status != _statusFilter) return false;
    if (_typeFilter != null && e.type != _typeFilter) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final all = [...data.enrollments]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final filtered = all.where(_matches).toList();

    final pendingCount =
        all.where((e) => e.status == EnrollmentStatus.pending).length;

    final scheme = Theme.of(context).colorScheme;
    final hasFilter = _statusFilter != null || _typeFilter != null;

    return RoleScaffold(
      title: 'Pendaftaran Siswa',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Pendaftaran Siswa',
            subtitle: pendingCount > 0
                ? '$pendingCount pendaftaran menunggu persetujuan'
                : '${all.length} total pendaftaran',
          ),

          // Ringkasan status
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Row(
              children: [
                for (final s in EnrollmentStatus.values) ...[
                  Expanded(
                    child: _StatusCard(
                      label: s.label,
                      count: all.where((e) => e.status == s).length,
                      color: _statusColor(s),
                      icon: _statusIcon(s),
                      selected: _statusFilter == s,
                      onTap: () => setState(() =>
                          _statusFilter = _statusFilter == s ? null : s),
                    ),
                  ),
                  if (s != EnrollmentStatus.values.last)
                    const SizedBox(width: 10),
                ],
              ],
            ),
          ),

          // Filter tipe
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Row(
              children: [
                Icon(Icons.filter_list,
                    size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('Tipe:',
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 13)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _typeFilter == null,
                  onSelected: (_) => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 6),
                for (final t in EnrollmentType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(t.label),
                      selected: _typeFilter == t,
                      onSelected: (_) => setState(
                          () => _typeFilter = _typeFilter == t ? null : t),
                    ),
                  ),
                if (hasFilter) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() {_statusFilter = null; _typeFilter = null;}),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reset'),
                  ),
                ],
              ],
            ),
          ),

          // Daftar
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: hasFilter
                        ? Icons.search_off
                        : Icons.assignment_outlined,
                    title: hasFilter
                        ? 'Tidak ada hasil'
                        : 'Belum ada pendaftaran',
                    message: hasFilter
                        ? 'Coba ubah filter.'
                        : 'Formulir pendaftaran siswa baru belum ada.',
                    action: hasFilter
                        ? OutlinedButton.icon(
                            onPressed: () => setState(
                                () {_statusFilter = null; _typeFilter = null;}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Filter'),
                          )
                        : null,
                  )
                : PaginatedListView<StudentEnrollment>(
                    items: filtered,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemBuilder: (_, e, i) => _EnrollmentCard(
                      enrollment: e,
                      statusColor: _statusColor(e.status),
                      statusIcon: _statusIcon(e.status),
                      onTap: () =>
                          context.go('/admin/enrollments/${e.id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({
    required this.enrollment,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
  });

  final StudentEnrollment enrollment;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = enrollment;
    final createdStr =
        '${e.createdAt.day.toString().padLeft(2, '0')}/${e.createdAt.month.toString().padLeft(2, '0')}/${e.createdAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: statusColor.withValues(alpha: 0.12),
                child: Text(
                  e.fullName.isEmpty ? '?' : e.fullName[0].toUpperCase(),
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        _TypeBadge(type: e.type),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${e.previousSchoolName} · ${e.previousSchoolCity}',
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(statusIcon, size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          e.status.label,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today_outlined,
                            size: 12,
                            color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          createdStr,
                          style: TextStyle(
                              color: scheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final EnrollmentType type;

  @override
  Widget build(BuildContext context) {
    final isTransfer = type == EnrollmentType.transfer;
    final color = isTransfer ? Colors.deepPurple : Colors.teal.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
