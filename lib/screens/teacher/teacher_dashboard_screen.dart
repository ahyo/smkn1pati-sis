import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
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
            title: 'Halo, ${user.name}',
            subtitle: 'Selamat mengajar hari ini',
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
                  label: 'Materi',
                  value: '${myMaterials.length}',
                  icon: Icons.menu_book_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => context.go('/teacher/materials'),
                ),
                _StatCard(
                  label: 'Ujian',
                  value: '${myExams.length}',
                  icon: Icons.quiz_outlined,
                  color: Colors.indigo.shade700,
                  onTap: () => context.go('/teacher/exams'),
                ),
                _StatCard(
                  label: 'Submisi',
                  value: '$pendingSubs',
                  icon: Icons.assessment_outlined,
                  color: Colors.green.shade700,
                  onTap: () => context.go('/teacher/exams'),
                ),
                _StatCard(
                  label: 'Jurnal Mengajar',
                  value: '${myJournals.length}',
                  icon: Icons.event_note_outlined,
                  color: Colors.orange.shade700,
                  onTap: () => context.go('/teacher/journals'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text('Akses Cepat',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount:
                  MediaQuery.of(context).size.width > 700 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _ActionTile(
                  icon: Icons.event_available_outlined,
                  title: 'Presensi Saya',
                  onTap: () => context.go('/teacher/attendance'),
                ),
                _ActionTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Ambil Presensi Siswa',
                  onTap: () => context.go('/teacher/class-attendance/edit'),
                ),
                _ActionTile(
                  icon: Icons.note_add_outlined,
                  title: 'Buat Materi',
                  onTap: () => context.go('/teacher/materials/new'),
                ),
                _ActionTile(
                  icon: Icons.event_note_outlined,
                  title: 'Tulis Jurnal',
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
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
                    Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              Flexible(
                child: Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
