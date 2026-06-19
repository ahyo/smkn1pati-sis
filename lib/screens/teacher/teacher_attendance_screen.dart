import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/attendance_status.dart';
import '../../models/teacher_attendance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';
import '../../widgets/status_chip.dart';

class TeacherAttendanceScreen extends StatelessWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final history = data.teacherAttendanceForTeacher(user.id);
    final today = data.teacherAttendanceOnDate(user.id, DateTime.now());

    final df = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final tf = DateFormat('HH:mm');

    Future<void> markToday(AttendanceStatus status) async {
      final now = DateTime.now();
      final dateOnly = DateTime(now.year, now.month, now.day);
      final att = TeacherAttendance(
        id: today?.id ?? const Uuid().v4(),
        teacherId: user.id,
        date: dateOnly,
        status: status,
        checkInTime:
            status == AttendanceStatus.hadir || status == AttendanceStatus.terlambat
                ? now
                : null,
      );
      await data.upsertTeacherAttendance(att);
    }

    return RoleScaffold(
      title: 'Presensi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Presensi Saya',
            subtitle: 'Catat kehadiran Anda hari ini & lihat riwayat presensi',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(df.format(DateTime.now()),
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        if (today != null) AttendanceStatusChip(status: today.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (today == null)
                      Text(
                          'Anda belum mencatat presensi hari ini. Pilih status di bawah.',
                          style: Theme.of(context).textTheme.bodyMedium)
                    else
                      Text(
                        today.checkInTime != null
                            ? 'Sudah dicatat • Check-in pukul ${tf.format(today.checkInTime!)}'
                            : 'Sudah dicatat',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AttendanceStatus.values.map((s) {
                        final selected = today?.status == s;
                        return OutlinedButton.icon(
                          icon: Icon(
                            selected ? Icons.check : _iconFor(s),
                            size: 16,
                            color: s.color,
                          ),
                          label: Text(s.label),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: s.color,
                            side: BorderSide(
                              color: selected
                                  ? s.color
                                  : s.color.withValues(alpha: 0.4),
                              width: selected ? 1.5 : 1,
                            ),
                            backgroundColor: selected
                                ? s.color.withValues(alpha: 0.08)
                                : null,
                          ),
                          onPressed: () => markToday(s),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text('Riwayat Presensi',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<TeacherAttendance>(
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
                        label: 'Check-in',
                        build: (a) => Text(a.checkInTime == null
                            ? '-'
                            : tf.format(a.checkInTime!)),
                      ),
                      AppTableColumn(
                        label: 'Catatan',
                        build: (a) => Text(a.note ?? '-',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, a) => ctx
                            .read<DataProvider>()
                            .deleteTeacherAttendance(a.id),
                      ),
                    ],
                    emptyIcon: Icons.event_available_outlined,
                    emptyTitle: 'Belum ada riwayat presensi',
                  ),
                ),
              ),
              mobile: history.isEmpty
                  ? const EmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'Belum ada riwayat presensi',
                    )
                  : PaginatedListView<TeacherAttendance>(
                      items: history,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, a, i) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  a.status.color.withValues(alpha: 0.15),
                              child: Text(
                                a.status.short,
                                style: TextStyle(
                                  color: a.status.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: Text('${i + 1}. ${df.format(a.date)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(a.checkInTime == null
                                ? a.status.label
                                : '${a.status.label} • ${tf.format(a.checkInTime!)}'),
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

  IconData _iconFor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.hadir:
        return Icons.check_circle_outline;
      case AttendanceStatus.terlambat:
        return Icons.access_time;
      case AttendanceStatus.izin:
        return Icons.event_busy;
      case AttendanceStatus.sakit:
        return Icons.healing;
      case AttendanceStatus.alpa:
        return Icons.cancel_outlined;
    }
  }
}
