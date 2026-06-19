import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final history = data.studentAttendanceForStudent(user.id);
    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

    final counts = <AttendanceStatus, int>{
      for (final s in AttendanceStatus.values) s: 0,
    };
    for (final a in history) {
      counts[a.status] = (counts[a.status] ?? 0) + 1;
    }
    final total = history.length;
    final percentHadir = total == 0
        ? 0
        : (((counts[AttendanceStatus.hadir] ?? 0) +
                    (counts[AttendanceStatus.terlambat] ?? 0)) /
                total *
                100)
            .round();

    return RoleScaffold(
      title: 'Presensi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Presensi Saya',
            subtitle: total == 0
                ? 'Belum ada catatan presensi'
                : '$total hari tercatat • Kehadiran $percentHadir%',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final s in AttendanceStatus.values)
                  _CountChip(status: s, count: counts[s] ?? 0),
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
                    items: history,
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
                        label: 'Kelas',
                        build: (a) =>
                            Text(data.classById(a.classId)?.name ?? '-'),
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
                    emptyMessage:
                        'Presensi akan muncul saat guru mencatatnya.',
                  ),
                ),
              ),
              mobile: history.isEmpty
                  ? const EmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'Belum ada presensi',
                    )
                  : PaginatedListView<StudentAttendance>(
                      items: history,
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
                            title: Text('${i + 1}. ${df.format(a.date)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${data.classById(a.classId)?.name ?? '-'} • Dicatat oleh ${data.userById(a.recordedByTeacherId ?? '')?.name ?? '-'}'),
                            trailing: AttendanceStatusChip(status: a.status),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.status, required this.count});
  final AttendanceStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.08),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: status.color),
          ),
          const SizedBox(width: 8),
          Text('$count',
              style: TextStyle(
                  color: status.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const SizedBox(width: 6),
          Text(status.label,
              style: TextStyle(
                  color: status.color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
