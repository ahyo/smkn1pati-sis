import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/audit_log.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  UserRole? _roleFilter;
  String? _classFilter; // hanya berlaku saat filter siswa

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _roleColor(UserRole role, ColorScheme scheme) {
    switch (role) {
      case UserRole.admin:
        return scheme.tertiary;
      case UserRole.teacher:
        return scheme.primary;
      case UserRole.student:
        return Colors.green.shade700;
      case UserRole.parent:
        return Colors.deepPurple;
    }
  }

  bool _matches(AppUser u) {
    if (_roleFilter != null && u.role != _roleFilter) return false;
    if (_roleFilter == UserRole.student &&
        _classFilter != null &&
        u.classId != _classFilter) {
      return false;
    }
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.identityNumber?.toLowerCase().contains(q) ?? false) ||
        (u.phone?.toLowerCase().contains(q) ?? false);
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _searchCtrl.clear();
      _roleFilter = null;
      _classFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final scheme = Theme.of(context).colorScheme;
    final all = [...data.users];

    final filtered = all.where(_matches).toList()
      ..sort((a, b) {
        final byRole = a.role.index.compareTo(b.role.index);
        if (byRole != 0) return byRole;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final counts = <UserRole, int>{
      for (final r in UserRole.values) r: 0,
    };
    for (final u in all) {
      counts[u.role] = (counts[u.role] ?? 0) + 1;
    }

    final hasActiveFilter =
        _query.isNotEmpty || _roleFilter != null || _classFilter != null;

    return RoleScaffold(
      title: 'Pengguna',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Pengguna',
            subtitle: hasActiveFilter
                ? '${filtered.length} dari ${all.length} pengguna'
                : '${all.length} pengguna terdaftar',
            action: FilledButton.icon(
              onPressed: () => context.go('/admin/users/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pengguna'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 720;
                      final searchField = TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText:
                              'Cari nama, email, NIS/NIP, atau nomor HP...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                        ),
                      );
                      final resetBtn = OutlinedButton.icon(
                        onPressed: hasActiveFilter ? _resetFilters : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: searchField),
                            const SizedBox(width: 12),
                            resetBtn,
                          ],
                        );
                      }
                      return Column(
                        children: [
                          searchField,
                          const SizedBox(height: 12),
                          Align(
                              alignment: Alignment.centerRight,
                              child: resetBtn),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RoleChoiceChip(
                          label: 'Semua',
                          count: all.length,
                          selected: _roleFilter == null,
                          color: scheme.onSurfaceVariant,
                          onTap: () => setState(() {
                            _roleFilter = null;
                            _classFilter = null;
                          }),
                        ),
                        for (final r in UserRole.values)
                          _RoleChoiceChip(
                            label: r.label,
                            count: counts[r] ?? 0,
                            selected: _roleFilter == r,
                            color: _roleColor(r, scheme),
                            onTap: () => setState(() {
                              _roleFilter = r;
                              if (r != UserRole.student) _classFilter = null;
                            }),
                          ),
                      ],
                    ),
                    if (_roleFilter == UserRole.student &&
                        data.classes.isNotEmpty) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.class_outlined,
                              size: 18,
                              color: scheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text('Kelas:',
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                ChoiceChip(
                                  label: const Text('Semua kelas'),
                                  selected: _classFilter == null,
                                  onSelected: (_) =>
                                      setState(() => _classFilter = null),
                                ),
                                for (final c in data.classes)
                                  ChoiceChip(
                                    label: Text(c.name),
                                    selected: _classFilter == c.id,
                                    onSelected: (_) => setState(
                                        () => _classFilter = c.id),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ResponsiveView(
              desktop: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SingleChildScrollView(
                  child: AppTable<AppUser>(
                    items: filtered,
                    onRowTap: (u) => context.go('/admin/users/${u.id}'),
                    columns: [
                      AppTableColumn(
                        label: 'Nama',
                        build: (u) => Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: _roleColor(u.role, scheme)
                                  .withValues(alpha: 0.15),
                              child: Text(
                                u.name.isEmpty ? '?' : u.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: _roleColor(u.role, scheme),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(u.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      AppTableColumn(
                        label: 'Email',
                        build: (u) => Text(u.email),
                      ),
                      AppTableColumn(
                        label: 'Peran',
                        build: (u) => _RoleBadge(
                            role: u.role, color: _roleColor(u.role, scheme)),
                      ),
                      AppTableColumn(
                        label: 'Kelas / Detail',
                        build: (u) => Text(_detailFor(u, data)),
                      ),
                    ],
                    actions: [
                      AppTableAction(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: (ctx, u) =>
                            ctx.go('/admin/users/${u.id}'),
                      ),
                      AppTableAction(
                        icon: Icons.delete_outline,
                        tooltip: 'Hapus',
                        onPressed: (ctx, u) => _confirmDelete(ctx, u),
                      ),
                    ],
                    emptyIcon: hasActiveFilter
                        ? Icons.search_off
                        : Icons.people_outline,
                    emptyTitle: hasActiveFilter
                        ? 'Tidak ada hasil'
                        : 'Belum ada pengguna',
                    emptyMessage: hasActiveFilter
                        ? 'Coba ubah kata kunci atau reset filter.'
                        : 'Mulai dengan menambahkan guru, siswa, atau orang tua.',
                    emptyAction: hasActiveFilter
                        ? OutlinedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Filter'),
                          )
                        : FilledButton.icon(
                            onPressed: () => context.go('/admin/users/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Pengguna'),
                          ),
                  ),
                ),
              ),
              mobile: filtered.isEmpty
                  ? EmptyState(
                      icon: hasActiveFilter
                          ? Icons.search_off
                          : Icons.people_outline,
                      title: hasActiveFilter
                          ? 'Tidak ada hasil'
                          : 'Belum ada pengguna',
                      message: hasActiveFilter
                          ? 'Coba kata kunci lain atau reset filter.'
                          : 'Mulai dengan menambahkan pengguna baru.',
                      action: hasActiveFilter
                          ? OutlinedButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filter'),
                            )
                          : FilledButton.icon(
                              onPressed: () => context.go('/admin/users/new'),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Pengguna'),
                            ),
                    )
                  : PaginatedListView<AppUser>(
                      items: filtered,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemBuilder: (_, u, i) {
                        return Card(
                          child: ListTile(
                            onTap: () => context.go('/admin/users/${u.id}'),
                            leading: CircleAvatar(
                              backgroundColor: _roleColor(u.role, scheme)
                                  .withValues(alpha: 0.15),
                              child: Text(
                                u.name.isEmpty ? '?' : u.name[0].toUpperCase(),
                                style: TextStyle(
                                    color: _roleColor(u.role, scheme),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            title: Text('${i + 1}. ${u.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${u.email}\n${u.role.label} • ${_detailFor(u, data)}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(context, u),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: MediaQuery.of(context).size.width < 900
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/admin/users/new'),
              icon: const Icon(Icons.add),
              label: const Text('Pengguna'),
            )
          : null,
    );
  }

  String _detailFor(AppUser u, DataProvider data) {
    switch (u.role) {
      case UserRole.student:
        final cls = u.classId == null ? null : data.classById(u.classId!);
        return cls?.name ?? '-';
      case UserRole.parent:
        if (u.childrenIds.isEmpty) return '-';
        return '${u.childrenIds.length} anak';
      case UserRole.teacher:
        if (u.subjectIds.isEmpty) return '-';
        final subjects = u.subjectIds
            .map((id) => data.subjectById(id)?.name)
            .whereType<String>()
            .join(', ');
        return subjects.isEmpty ? '-' : subjects;
      case UserRole.admin:
        return '-';
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppUser u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus pengguna?'),
        content: Text('Pengguna ${u.name} akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final data = context.read<DataProvider>();
      final actor = context.read<AuthProvider>().user;
      await data.deleteUser(u.id);
      if (actor != null) {
        await data.recordAudit(
          actor: actor,
          action: AuditAction.userDelete,
          targetType: 'user',
          targetId: u.id,
          targetLabel: '${u.name} (${u.role.label})',
        );
      }
    }
  }
}

class _RoleChoiceChip extends StatelessWidget {
  const _RoleChoiceChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? color : theme.colorScheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check, size: 14, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : theme.colorScheme.onSurface,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: (selected ? color : theme.colorScheme.onSurfaceVariant)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected
                        ? color
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.color});
  final UserRole role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
