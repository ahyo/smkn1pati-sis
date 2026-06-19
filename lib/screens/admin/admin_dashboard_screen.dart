import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/enrollment_status.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
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

    final cross = MediaQuery.of(context).size.width > 1100
        ? 4
        : MediaQuery.of(context).size.width > 700
        ? 2
        : 1;

    return RoleScaffold(
      title: 'Dashboard',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          PageHeader(
            title: 'Selamat datang, ${user?.name ?? 'Admin'}',
            subtitle:
                'Ringkasan data sekolah Anda. Klik kartu untuk membuka detail.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount: cross,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: [
                _StatCard(
                  label: 'Guru',
                  value: '$teachers',
                  icon: Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => context.go('/admin/users'),
                ),
                _StatCard(
                  label: 'Siswa',
                  value: '$students',
                  icon: Icons.groups_outlined,
                  color: Colors.green.shade700,
                  onTap: () => context.go('/admin/users'),
                ),
                _StatCard(
                  label: 'Orang Tua',
                  value: '$parents',
                  icon: Icons.family_restroom_outlined,
                  color: Colors.deepPurple,
                  onTap: () => context.go('/admin/users'),
                ),
                _StatCard(
                  label: 'Kelas Aktif',
                  value: '${data.classes.length}',
                  icon: Icons.class_outlined,
                  color: Colors.orange.shade700,
                  onTap: () => context.go('/admin/classes'),
                ),
                _StatCard(
                  label: 'Pendaftaran Masuk',
                  value: '$pendingEnrollments',
                  icon: Icons.assignment_ind_outlined,
                  color: Colors.teal.shade700,
                  badge: pendingEnrollments > 0 ? '$pendingEnrollments baru' : null,
                  onTap: () => context.go('/admin/enrollments'),
                ),
                _StatCard(
                  label: 'Konfirmasi Bayar',
                  value: '$pendingPayments',
                  icon: Icons.payments_outlined,
                  color: Colors.amber.shade800,
                  badge: pendingPayments > 0 ? '$pendingPayments menunggu' : null,
                  onTap: () => context.go('/admin/payments'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1100
                  ? 3
                  : MediaQuery.of(context).size.width > 700
                  ? 2
                  : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: [
                _StatCard(
                  label: 'Mata Pelajaran',
                  value: '${data.subjects.length}',
                  icon: Icons.menu_book_outlined,
                  color: Theme.of(context).colorScheme.tertiary,
                  onTap: () => context.go('/admin/subjects'),
                ),
                _StatCard(
                  label: 'Materi',
                  value: '${data.materials.length}',
                  icon: Icons.article_outlined,
                  color: Colors.teal.shade700,
                ),
                _StatCard(
                  label: 'Ujian',
                  value: '${data.exams.length}',
                  icon: Icons.quiz_outlined,
                  color: Colors.indigo.shade700,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
