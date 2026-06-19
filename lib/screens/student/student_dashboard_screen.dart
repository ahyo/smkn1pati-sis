import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/page_header.dart';
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
    final pendingExams = exams
        .where((e) => !mySubs.any((s) => s.examId == e.id))
        .toList();
    final myJournals = data.studyJournalsByStudent(user.id);
    final avg = mySubs.isEmpty
        ? 0
        : (mySubs.map((s) => s.percentage).reduce((a, b) => a + b) /
                mySubs.length)
            .round();

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
            subtitle: 'Kelas ${cls?.name ?? '-'} • Semangat belajar!',
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
                  value: '${materials.length}',
                  icon: Icons.menu_book_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => context.go('/student/materials'),
                ),
                _StatCard(
                  label: 'Belum Dikerjakan',
                  value: '${pendingExams.length}',
                  icon: Icons.pending_actions_outlined,
                  color: Colors.orange.shade700,
                  onTap: () => context.go('/student/exams'),
                ),
                _StatCard(
                  label: 'Rata-rata Nilai',
                  value: mySubs.isEmpty ? '-' : '$avg%',
                  icon: Icons.assessment_outlined,
                  color: Colors.green.shade700,
                  onTap: () => context.go('/student/results'),
                ),
                _StatCard(
                  label: 'Catatan Belajar',
                  value: '${myJournals.length}',
                  icon: Icons.book_outlined,
                  color: Colors.deepPurple,
                  onTap: () => context.go('/student/journals'),
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
                  icon: Icons.menu_book_outlined,
                  title: 'Baca Materi',
                  onTap: () => context.go('/student/materials'),
                ),
                _ActionTile(
                  icon: Icons.quiz_outlined,
                  title: 'Kerjakan Ujian',
                  onTap: () => context.go('/student/exams'),
                ),
                _ActionTile(
                  icon: Icons.book_outlined,
                  title: 'Catat Belajar',
                  onTap: () => context.go('/student/journals/new'),
                ),
                _ActionTile(
                  icon: Icons.event_available_outlined,
                  title: 'Lihat Presensi',
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
