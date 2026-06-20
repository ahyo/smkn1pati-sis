import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_status.dart';
import '../../providers/data_provider.dart';
import '../../widgets/role_scaffold.dart';
import '../../widgets/status_chip.dart';

class ParentChildDetailScreen extends StatelessWidget {
  const ParentChildDetailScreen({super.key, required this.childId});
  final String childId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final child = data.userById(childId);
    if (child == null) {
      return const RoleScaffold(
          title: 'Anak', body: Center(child: Text('Tidak ditemukan')));
    }
    final cls = child.classId == null ? null : data.classById(child.classId!);
    final materials =
        cls == null ? const [] : data.materialsForClass(cls.id);
    final exams = cls == null ? const [] : data.examsForClass(cls.id);
    final subs = data.submissionsByStudent(child.id);
    final teachingJournals = cls == null
        ? const []
        : data.teachingJournalsForClass(cls.id).take(5).toList();
    final studyJournals = data.studyJournalsByStudent(child.id).take(5).toList();
    final attendance = data.studentAttendanceForStudent(child.id);
    final attCounts = <AttendanceStatus, int>{
      for (final s in AttendanceStatus.values) s: 0,
    };
    for (final a in attendance) {
      attCounts[a.status] = (attCounts[a.status] ?? 0) + 1;
    }
    final df = DateFormat('dd MMM yyyy', 'id_ID');

    return RoleScaffold(
      title: child.name,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Kelas: ${cls?.name ?? '-'}'),
                  Text('Email: ${child.email}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Presensi (${attendance.length} hari)',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (attendance.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      context.go('/parent/attendance?child=${child.id}'),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Lihat semua'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (attendance.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Belum ada catatan presensi'),
            )
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in AttendanceStatus.values)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.08),
                      border:
                          Border.all(color: s.color.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${s.label}: ${attCounts[s] ?? 0}',
                        style: TextStyle(
                            color: s.color, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...attendance.take(5).map((a) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: a.status.color.withValues(alpha: 0.15),
                      child: Text(a.status.short,
                          style: TextStyle(
                              color: a.status.color,
                              fontWeight: FontWeight.w700)),
                    ),
                    title: Text(df.format(a.date)),
                    subtitle: Text(data.classById(a.classId)?.name ?? '-'),
                    trailing: AttendanceStatusChip(status: a.status),
                  ),
                )),
          ],
          const SizedBox(height: 16),
          Text('Hasil Ujian (${subs.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (subs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Belum ada ujian dikerjakan'),
            )
          else
            ...subs.map((s) {
              final exam = data.examById(s.examId);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.assessment),
                  title: Text(exam?.title ?? 'Ujian'),
                  subtitle: Text(df.format(s.submittedAt)),
                  trailing: Text('${s.score}/${s.totalPoints}'),
                ),
              );
            }),
          const SizedBox(height: 16),
          Text('Materi Kelas (${materials.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...materials.map((m) {
            final subject = data.subjectById(m.subjectId);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(m.title),
                subtitle: Text(subject?.name ?? '-'),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('Ujian Kelas (${exams.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...exams.map((e) {
            final subject = data.subjectById(e.subjectId);
            final done = subs.any((s) => s.examId == e.id);
            return Card(
              child: ListTile(
                leading: Icon(
                    done ? Icons.check_circle : Icons.quiz,
                    color: done ? Colors.green : null),
                title: Text(e.title),
                subtitle: Text(subject?.name ?? '-'),
                trailing:
                    Text(done ? 'Selesai' : 'Belum'),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('Jurnal Mengajar Guru (5 terakhir)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (teachingJournals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Belum ada jurnal mengajar'),
            )
          else
            ...teachingJournals.map((j) {
              final subject = data.subjectById(j.subjectId);
              final teacher = data.userById(j.teacherId);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text(j.topic),
                  subtitle: Text(
                      '${df.format(j.date)} • ${subject?.name ?? '-'} • ${teacher?.name ?? '-'}\nHadir: ${j.attendanceCount}/${j.totalStudents}'),
                  isThreeLine: true,
                ),
              );
            }),
          const SizedBox(height: 16),
          Text('Jurnal Belajar Anak (5 terakhir)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (studyJournals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Anak belum mencatat jurnal belajar'),
            )
          else
            ...studyJournals.map((j) {
              final subject = j.subjectId == null
                  ? null
                  : data.subjectById(j.subjectId!);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: Text(j.topic),
                  subtitle: Text(
                      '${df.format(j.date)} • ${subject?.name ?? 'Umum'} • ${j.durationMinutes} menit\n${j.summary}'),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }
}
