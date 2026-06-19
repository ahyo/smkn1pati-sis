import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
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
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          PageHeader(
            title: 'Halo, ${user.name}',
            subtitle: 'Pantau perkembangan anak Anda',
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
          else
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
                      : (subs
                                  .map((s) => s.percentage)
                                  .reduce((a, b) => a + b) /
                              subs.length)
                          .round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: InkWell(
                        onTap: () => context.go('/parent/children/${c.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  c.name.isEmpty ? '?' : c.name[0],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kelas ${cls?.name ?? '-'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 16,
                                      children: [
                                        _MiniStat(
                                            icon: Icons.assessment_outlined,
                                            label:
                                                '${subs.length} ujian'),
                                        if (avg != null)
                                          _MiniStat(
                                              icon: Icons.trending_up,
                                              label: 'Rata-rata $avg%'),
                                        _MiniStat(
                                            icon: Icons.book_outlined,
                                            label:
                                                '${journals.length} jurnal'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}
