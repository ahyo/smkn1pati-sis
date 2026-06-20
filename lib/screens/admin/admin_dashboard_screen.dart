import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/enrollment_status.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/dashboard.dart';
import '../../widgets/role_scaffold.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final user = context.watch<AuthProvider>().user;
    final teachers = data.users.where((u) => u.role == UserRole.teacher).length;
    final students = data.users.where((u) => u.role == UserRole.student).length;
    final parents = data.users.where((u) => u.role == UserRole.parent).length;
    final pendingEnrollments = data.enrollments
        .where((e) => e.status == EnrollmentStatus.pending)
        .length;
    final pendingPayments = data.pendingTransactions.length;

    final width = MediaQuery.of(context).size.width;
    final cross = width > 1100 ? 4 : width > 700 ? 2 : 1;

    return RoleScaffold(
      title: 'Dashboard',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        children: [
          DashboardHero(
            name: user?.name ?? 'Admin',
            roleLabel: 'Admin',
            subtitle: 'Ringkasan data sekolah Anda. Klik kartu untuk detail.',
          ),
          const _Section(title: 'Ringkasan Sekolah'),
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
                  label: 'Guru',
                  value: '$teachers',
                  icon: Icons.school_outlined,
                  color: const Color(0xFF3046A5),
                  onTap: () => context.go('/admin/users'),
                ),
                MetricCard(
                  label: 'Siswa',
                  value: '$students',
                  icon: Icons.groups_outlined,
                  color: const Color(0xFF2E7D32),
                  onTap: () => context.go('/admin/users'),
                ),
                MetricCard(
                  label: 'Orang Tua',
                  value: '$parents',
                  icon: Icons.family_restroom_outlined,
                  color: const Color(0xFF6A1B9A),
                  onTap: () => context.go('/admin/users'),
                ),
                MetricCard(
                  label: 'Kelas Aktif',
                  value: '${data.classes.length}',
                  icon: Icons.class_outlined,
                  color: const Color(0xFFE65100),
                  onTap: () => context.go('/admin/classes'),
                ),
                MetricCard(
                  label: 'Pendaftaran Masuk',
                  value: '$pendingEnrollments',
                  icon: Icons.assignment_ind_outlined,
                  color: const Color(0xFF00838F),
                  badge: pendingEnrollments > 0 ? '$pendingEnrollments baru' : null,
                  onTap: () => context.go('/admin/enrollments'),
                ),
                MetricCard(
                  label: 'Konfirmasi Bayar',
                  value: '$pendingPayments',
                  icon: Icons.payments_outlined,
                  color: const Color(0xFFB8860B),
                  badge: pendingPayments > 0 ? '$pendingPayments menunggu' : null,
                  onTap: () => context.go('/admin/payments'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const _Section(title: 'Akademik'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width > 1100 ? 3 : width > 700 ? 2 : 1,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 98,
              ),
              children: [
                MetricCard(
                  label: 'Mata Pelajaran',
                  value: '${data.subjects.length}',
                  icon: Icons.menu_book_outlined,
                  color: const Color(0xFF0F8B8D),
                  onTap: () => context.go('/admin/subjects'),
                ),
                MetricCard(
                  label: 'Materi',
                  value: '${data.materials.length}',
                  icon: Icons.article_outlined,
                  color: const Color(0xFF00897B),
                ),
                MetricCard(
                  label: 'Ujian',
                  value: '${data.exams.length}',
                  icon: Icons.quiz_outlined,
                  color: const Color(0xFF3949AB),
                  onTap: () => context.go('/admin/exams'),
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
