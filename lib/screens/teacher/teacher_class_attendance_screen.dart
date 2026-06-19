import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_status.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class _ClassSession {
  final String classId;
  final DateTime date;
  final int total;
  final int hadir;
  final int izin;
  final int sakit;
  final int alpa;
  final int terlambat;

  const _ClassSession({
    required this.classId,
    required this.date,
    required this.total,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpa,
    required this.terlambat,
  });
}

class TeacherClassAttendanceScreen extends StatelessWidget {
  const TeacherClassAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

    // Build session list across all classes (most recent first).
    final Map<String, _ClassSession> sessions = {};
    for (final a in data.studentAttendance) {
      final key = '${a.classId}|${a.dateKeyStr}';
      final prev = sessions[key];
      if (prev == null) {
        sessions[key] = _ClassSession(
          classId: a.classId,
          date: DateTime(a.date.year, a.date.month, a.date.day),
          total: 1,
          hadir: a.status == AttendanceStatus.hadir ? 1 : 0,
          izin: a.status == AttendanceStatus.izin ? 1 : 0,
          sakit: a.status == AttendanceStatus.sakit ? 1 : 0,
          alpa: a.status == AttendanceStatus.alpa ? 1 : 0,
          terlambat: a.status == AttendanceStatus.terlambat ? 1 : 0,
        );
      } else {
        sessions[key] = _ClassSession(
          classId: prev.classId,
          date: prev.date,
          total: prev.total + 1,
          hadir: prev.hadir + (a.status == AttendanceStatus.hadir ? 1 : 0),
          izin: prev.izin + (a.status == AttendanceStatus.izin ? 1 : 0),
          sakit: prev.sakit + (a.status == AttendanceStatus.sakit ? 1 : 0),
          alpa: prev.alpa + (a.status == AttendanceStatus.alpa ? 1 : 0),
          terlambat:
              prev.terlambat + (a.status == AttendanceStatus.terlambat ? 1 : 0),
        );
      }
    }
    final list = sessions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    String dateKey(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    void editSession(String classId, DateTime date) {
      context.go('/teacher/class-attendance/edit?classId=$classId&date=${dateKey(date)}');
    }

    return RoleScaffold(
      title: 'Presensi Siswa',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Presensi Siswa',
            subtitle: '${list.length} sesi presensi tercatat',
            action: FilledButton.icon(
              onPressed: () =>
                  context.go('/teacher/class-attendance/edit'),
              icon: const Icon(Icons.add),
              label: const Text('Ambil Presensi'),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<_ClassSession>(
                    items: list,
                    onRowTap: (s) => editSession(s.classId, s.date),
                    columns: [
                      AppTableColumn(
                        label: 'Tanggal',
                        build: (s) => Text(df.format(s.date)),
                      ),
                      AppTableColumn(
                        label: 'Kelas',
                        build: (s) =>
                            Text(data.classById(s.classId)?.name ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Hadir',
                        numeric: true,
                        build: (s) => _Pill(
                            text: '${s.hadir}/${s.total}',
                            color: AttendanceStatus.hadir.color),
                      ),
                      AppTableColumn(
                        label: 'Terlambat',
                        numeric: true,
                        build: (s) => Text('${s.terlambat}'),
                      ),
                      AppTableColumn(
                        label: 'Izin',
                        numeric: true,
                        build: (s) => Text('${s.izin}'),
                      ),
                      AppTableColumn(
                        label: 'Sakit',
                        numeric: true,
                        build: (s) => Text('${s.sakit}'),
                      ),
                      AppTableColumn(
                        label: 'Alpa',
                        numeric: true,
                        build: (s) => Text('${s.alpa}'),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, s) => editSession(s.classId, s.date),
                      ),
                    ],
                    emptyIcon: Icons.fact_check_outlined,
                    emptyTitle: 'Belum ada sesi presensi',
                    emptyMessage:
                        'Ambil presensi pertama untuk salah satu kelas Anda.',
                    emptyAction: FilledButton.icon(
                      onPressed: () =>
                          context.go('/teacher/class-attendance/edit'),
                      icon: const Icon(Icons.add),
                      label: const Text('Ambil Presensi'),
                    ),
                  ),
                ),
              ),
              mobile: list.isEmpty
                  ? EmptyState(
                      icon: Icons.fact_check_outlined,
                      title: 'Belum ada sesi presensi',
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.go('/teacher/class-attendance/edit'),
                        icon: const Icon(Icons.add),
                        label: const Text('Ambil Presensi'),
                      ),
                    )
                  : PaginatedListView<_ClassSession>(
                      items: list,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, s, i) {
                        return Card(
                          child: ListTile(
                            onTap: () => editSession(s.classId, s.date),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Text('${s.date.day}'),
                            ),
                            title: Text(
                                '${i + 1}. ${data.classById(s.classId)?.name ?? '-'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${df.format(s.date)}\nH:${s.hadir} • T:${s.terlambat} • I:${s.izin} • S:${s.sakit} • A:${s.alpa}'),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: MediaQuery.of(context).size.width < 900
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/teacher/class-attendance/edit'),
              icon: const Icon(Icons.add),
              label: const Text('Presensi'),
            )
          : null,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
