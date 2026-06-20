import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/attendance_status.dart';
import '../../models/student_attendance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';
import '../../widgets/status_chip.dart';

/// Halaman presensi anak untuk orang tua.
///
/// Alur: pilih anak → daftar mata pelajaran dengan rekap (hadir/izin/sakit/alfa)
/// → klik mapel untuk melihat detail presensi per pertemuan.
class ParentAttendanceScreen extends StatefulWidget {
  const ParentAttendanceScreen({super.key, this.initialChildId});

  final String? initialChildId;

  @override
  State<ParentAttendanceScreen> createState() => _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState extends State<ParentAttendanceScreen> {
  String? _selectedChildId;
  String? _openSubjectId; // null = tampilkan daftar mapel
  bool _openSubjectIsNull = false; // untuk mapel "Umum" (subjectId == null)

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.initialChildId;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final children = user.childrenIds
        .map((id) => data.userById(id))
        .whereType<AppUser>()
        .toList();

    if (children.isEmpty) {
      return const RoleScaffold(
        title: 'Presensi Anak',
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: EmptyState(
            icon: Icons.family_restroom,
            title: 'Belum ada anak ditautkan',
            message: 'Hubungi admin sekolah untuk menautkan akun anak Anda.',
          ),
        ),
      );
    }

    final child = children.firstWhere(
      (c) => c.id == _selectedChildId,
      orElse: () => children.first,
    );
    final cls = child.classId == null ? null : data.classById(child.classId!);
    final history = data.studentAttendanceForStudent(child.id);

    // Kelompokkan per mata pelajaran.
    final groups = <String, List<StudentAttendance>>{};
    final nullGroup = <StudentAttendance>[];
    for (final a in history) {
      if (a.subjectId == null) {
        nullGroup.add(a);
      } else {
        groups.putIfAbsent(a.subjectId!, () => []).add(a);
      }
    }
    final subjectEntries = groups.entries.toList()
      ..sort((a, b) => (data.subjectById(a.key)?.name ?? '')
          .compareTo(data.subjectById(b.key)?.name ?? ''));

    final showingDetail = _openSubjectId != null || _openSubjectIsNull;
    final detailItems = _openSubjectIsNull
        ? nullGroup
        : (groups[_openSubjectId] ?? const <StudentAttendance>[]);
    final detailSubjectName = _openSubjectIsNull
        ? 'Umum / Harian'
        : (data.subjectById(_openSubjectId ?? '')?.name ?? 'Mata Pelajaran');

    return RoleScaffold(
      title: 'Presensi Anak',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: showingDetail
                ? '$detailSubjectName • ${child.name}'
                : 'Presensi ${child.name}',
            subtitle: showingDetail
                ? 'Detail presensi per pertemuan'
                : 'Kelas ${cls?.name ?? '-'} • Pilih mata pelajaran untuk melihat detail',
          ),
          if (children.length > 1 && !showingDetail)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in children)
                    ChoiceChip(
                      label: Text(c.name),
                      selected: c.id == child.id,
                      onSelected: (_) => setState(() {
                        _selectedChildId = c.id;
                        _openSubjectId = null;
                        _openSubjectIsNull = false;
                      }),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: showingDetail
                ? _DetailView(
                    items: detailItems,
                    onBack: () => setState(() {
                      _openSubjectId = null;
                      _openSubjectIsNull = false;
                    }),
                  )
                : _SubjectListView(
                    history: history,
                    subjectEntries: subjectEntries,
                    nullGroup: nullGroup,
                    onOpen: (subjectId, isNull) => setState(() {
                      _openSubjectId = subjectId;
                      _openSubjectIsNull = isNull;
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Hitung rekap status dari sekumpulan presensi.
Map<AttendanceStatus, int> _countStatuses(List<StudentAttendance> items) {
  final counts = <AttendanceStatus, int>{
    for (final s in AttendanceStatus.values) s: 0,
  };
  for (final a in items) {
    counts[a.status] = (counts[a.status] ?? 0) + 1;
  }
  return counts;
}

int _percentHadir(Map<AttendanceStatus, int> counts, int total) => total == 0
    ? 0
    : (((counts[AttendanceStatus.hadir] ?? 0) +
                (counts[AttendanceStatus.terlambat] ?? 0)) /
            total *
            100)
        .round();

class _SubjectListView extends StatelessWidget {
  const _SubjectListView({
    required this.history,
    required this.subjectEntries,
    required this.nullGroup,
    required this.onOpen,
  });

  final List<StudentAttendance> history;
  final List<MapEntry<String, List<StudentAttendance>>> subjectEntries;
  final List<StudentAttendance> nullGroup;
  final void Function(String? subjectId, bool isNull) onOpen;

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_outlined,
        title: 'Belum ada presensi',
        message: 'Presensi akan muncul saat guru mencatatnya.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        for (final e in subjectEntries)
          _SubjectCard(
            name: data.subjectById(e.key)?.name ?? 'Mata Pelajaran',
            code: data.subjectById(e.key)?.code,
            items: e.value,
            onTap: () => onOpen(e.key, false),
          ),
        if (nullGroup.isNotEmpty)
          _SubjectCard(
            name: 'Umum / Harian',
            code: null,
            items: nullGroup,
            onTap: () => onOpen(null, true),
          ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.name,
    required this.code,
    required this.items,
    required this.onTap,
  });

  final String name;
  final String? code;
  final List<StudentAttendance> items;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final counts = _countStatuses(items);
    final total = items.length;
    final percent = _percentHadir(counts, total);
    final alfa = counts[AttendanceStatus.alpa] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: scheme.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(Icons.menu_book_outlined,
                          color: scheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            '$total pertemuan • Kehadiran $percent%'
                            '${alfa > 0 ? ' • $alfa alfa' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in AttendanceStatus.values)
                      _MiniCount(status: s, count: counts[s] ?? 0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCount extends StatelessWidget {
  const _MiniCount({required this.status, required this.count});
  final AttendanceStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final muted = count == 0;
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: muted ? 0.04 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: color.withValues(alpha: muted ? 0.12 : 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: TextStyle(
                  color: muted ? Theme.of(context).colorScheme.onSurfaceVariant
                      : color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
          const SizedBox(width: 5),
          Text(status.label,
              style: TextStyle(
                  color: muted
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.items, required this.onBack});

  final List<StudentAttendance> items;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final counts = _countStatuses(items);
    final total = items.length;
    final percent = _percentHadir(counts, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Semua mata pelajaran'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
          child: Text('Total $total pertemuan • Kehadiran $percent%',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final s in AttendanceStatus.values)
                _MiniCount(status: s, count: counts[s] ?? 0),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ResponsiveView(
            desktop: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SingleChildScrollView(
                child: AppTable<StudentAttendance>(
                  items: items,
                  columns: [
                    AppTableColumn(
                      label: 'Tanggal',
                      build: (a) => Text(df.format(a.date)),
                    ),
                    AppTableColumn(
                      label: 'Status',
                      build: (a) => AttendanceStatusChip(status: a.status),
                    ),
                    AppTableColumn(
                      label: 'Dicatat oleh',
                      build: (a) => Text(
                          data.userById(a.recordedByTeacherId ?? '')?.name ??
                              '-'),
                    ),
                  ],
                  emptyIcon: Icons.event_available_outlined,
                  emptyTitle: 'Belum ada presensi',
                ),
              ),
            ),
            mobile: items.isEmpty
                ? const EmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'Belum ada presensi',
                  )
                : PaginatedListView<StudentAttendance>(
                    items: items,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemBuilder: (_, a, i) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                a.status.color.withValues(alpha: 0.15),
                            child: Text(a.status.short,
                                style: TextStyle(
                                    color: a.status.color,
                                    fontWeight: FontWeight.w700)),
                          ),
                          title: Text(df.format(a.date),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'Dicatat oleh ${data.userById(a.recordedByTeacherId ?? '')?.name ?? '-'}'),
                          trailing: AttendanceStatusChip(status: a.status),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
