import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/dashboard.dart';
import '../../widgets/role_scaffold.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final myMaterials = data.materialsByTeacher(user.id);
    final myExams = data.examsByTeacher(user.id);
    final myJournals = data.teachingJournalsByTeacher(user.id);
    final pendingSubs = myExams
        .map((e) => data.submissionsForExam(e.id).length)
        .fold<int>(0, (a, b) => a + b);

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
            roleLabel: 'Guru',
            subtitle: 'Selamat mengajar hari ini. Semoga lancar!',
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
                  value: '${myMaterials.length}',
                  icon: Icons.menu_book_outlined,
                  color: const Color(0xFF3046A5),
                  onTap: () => context.go('/teacher/materials'),
                ),
                MetricCard(
                  label: 'Ujian',
                  value: '${myExams.length}',
                  icon: Icons.quiz_outlined,
                  color: const Color(0xFF3949AB),
                  onTap: () => context.go('/teacher/exams'),
                ),
                MetricCard(
                  label: 'Submisi',
                  value: '$pendingSubs',
                  icon: Icons.assessment_outlined,
                  color: const Color(0xFF2E7D32),
                  onTap: () => context.go('/teacher/exams'),
                ),
                MetricCard(
                  label: 'Jurnal Mengajar',
                  value: '${myJournals.length}',
                  icon: Icons.event_note_outlined,
                  color: const Color(0xFFE65100),
                  onTap: () => context.go('/teacher/journals'),
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
                  icon: Icons.event_available_outlined,
                  title: 'Presensi Saya',
                  color: const Color(0xFF0F8B8D),
                  onTap: () => context.go('/teacher/attendance'),
                ),
                QuickActionTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Ambil Presensi Siswa',
                  color: const Color(0xFF2E7D32),
                  onTap: () => context.go('/teacher/class-attendance/edit'),
                ),
                QuickActionTile(
                  icon: Icons.note_add_outlined,
                  title: 'Buat Materi',
                  color: const Color(0xFF3046A5),
                  onTap: () => context.go('/teacher/materials/new'),
                ),
                QuickActionTile(
                  icon: Icons.event_note_outlined,
                  title: 'Tulis Jurnal',
                  color: const Color(0xFFE65100),
                  onTap: () => context.go('/teacher/journals/new'),
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
