import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/dashboard.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/role_scaffold.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final data = context.watch<DataProvider>();
    final children = user.childrenIds
        .map((id) => data.userById(id))
        .whereType<AppUser>()
        .toList();

    return RoleScaffold(
      title: 'Dashboard',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        children: [
          DashboardHero(
            name: user.name,
            roleLabel: 'Orang Tua',
            subtitle: 'Pantau perkembangan belajar anak Anda.',
          ),
          if (children.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: EmptyState(
                icon: Icons.family_restroom,
                title: 'Belum ada anak ditautkan',
                message:
                    'Hubungi admin sekolah untuk menautkan akun anak Anda.',
              ),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 22, 24, 14),
              child: SectionLabel(title: 'Anak Anda'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: children.map((c) {
                  final cls =
                      c.classId == null ? null : data.classById(c.classId!);
                  final subs = data.submissionsByStudent(c.id);
                  final journals = data.studyJournalsByStudent(c.id);
                  final avg = subs.isEmpty
                      ? null
                      : (subs.map((s) => s.percentage).reduce((a, b) => a + b) /
                              subs.length)
                          .round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ChildCard(
                      name: c.name,
                      className: cls?.name ?? '-',
                      exams: subs.length,
                      journals: journals.length,
                      avg: avg,
                      onTap: () => context.go('/parent/children/${c.id}'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.name,
    required this.className,
    required this.exams,
    required this.journals,
    required this.avg,
    required this.onTap,
  });

  final String name;
  final String className;
  final int exams;
  final int journals;
  final int? avg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary,
                      Color.lerp(scheme.primary, scheme.secondary, 0.7)!,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Kelas $className',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatChip(
                            icon: Icons.assessment_outlined,
                            label: '$exams ujian'),
                        if (avg != null)
                          _StatChip(
                              icon: Icons.trending_up,
                              label: 'Rata-rata $avg%'),
                        _StatChip(
                            icon: Icons.book_outlined,
                            label: '$journals jurnal'),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
