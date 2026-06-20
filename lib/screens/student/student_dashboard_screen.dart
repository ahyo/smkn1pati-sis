import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/dashboard.dart';
import '../../widgets/role_scaffold.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final cls = user.classId == null ? null : data.classById(user.classId!);
    final materials = cls == null ? const [] : data.materialsForClass(cls.id);
    final exams = cls == null ? const [] : data.examsForClass(cls.id);
    final mySubs = data.submissionsByStudent(user.id);
    final pendingExams =
        exams.where((e) => !mySubs.any((s) => s.examId == e.id)).toList();
    final myJournals = data.studyJournalsByStudent(user.id);
    final avg = mySubs.isEmpty
        ? 0
        : (mySubs.map((s) => s.percentage).reduce((a, b) => a + b) /
                mySubs.length)
            .round();

    final width = MediaQuery.of(context).size.width;
    final cross = width > 1100 ? 4 : width > 700 ? 2 : 1;
    final actionCross = width > 700 ? 4 : 2;

    return RoleScaffold(
      title: 'Dashboard',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        children: [
          DashboardHero(
            name: user.name,
            roleLabel: 'Siswa',
            subtitle: 'Kelas ${cls?.name ?? '-'} • Semangat belajar!',
          ),
          const _Section(title: 'Ringkasan'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 98,
              ),
              children: [
                MetricCard(
                  label: 'Materi',
                  value: '${materials.length}',
                  icon: Icons.menu_book_outlined,
                  color: const Color(0xFF3046A5),
                  onTap: () => context.go('/student/materials'),
                ),
                MetricCard(
                  label: 'Belum Dikerjakan',
                  value: '${pendingExams.length}',
                  icon: Icons.pending_actions_outlined,
                  color: const Color(0xFFE65100),
                  badge: pendingExams.isNotEmpty
                      ? '${pendingExams.length} ujian'
                      : null,
                  onTap: () => context.go('/student/exams'),
                ),
                MetricCard(
                  label: 'Rata-rata Nilai',
                  value: mySubs.isEmpty ? '-' : '$avg%',
                  icon: Icons.assessment_outlined,
                  color: const Color(0xFF2E7D32),
                  onTap: () => context.go('/student/results'),
                ),
                MetricCard(
                  label: 'Catatan Belajar',
                  value: '${myJournals.length}',
                  icon: Icons.book_outlined,
                  color: const Color(0xFF6A1B9A),
                  onTap: () => context.go('/student/journals'),
                ),
              ],
            ),
          ),
          const _Section(title: 'Akses Cepat'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: actionCross,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 124,
              ),
              children: [
                QuickActionTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Baca Materi',
                  color: const Color(0xFF3046A5),
                  onTap: () => context.go('/student/materials'),
                ),
                QuickActionTile(
                  icon: Icons.quiz_outlined,
                  title: 'Kerjakan Ujian',
                  color: const Color(0xFF3949AB),
                  onTap: () => context.go('/student/exams'),
                ),
                QuickActionTile(
                  icon: Icons.book_outlined,
                  title: 'Catat Belajar',
                  color: const Color(0xFF6A1B9A),
                  onTap: () => context.go('/student/journals/new'),
                ),
                QuickActionTile(
                  icon: Icons.event_available_outlined,
                  title: 'Lihat Presensi',
                  color: const Color(0xFF0F8B8D),
                  onTap: () => context.go('/student/attendance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 14),
      child: SectionLabel(title: title),
    );
  }
}
