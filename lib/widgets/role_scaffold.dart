import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'app_navigation.dart';

/// Breakpoint at which the app switches to a desktop/web layout
/// with a persistent sidebar.
const double kSidebarBreakpoint = 900;

class RoleScaffold extends StatelessWidget {
  const RoleScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= kSidebarBreakpoint;
    return isWide ? _buildWide(context) : _buildNarrow(context);
  }

  Widget _buildWide(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();
    final items = navItemsFor(user.role);
    final loc = GoRouterState.of(context).matchedLocation;
    final activeIdx = activeNavIndex(items, loc);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _Sidebar(items: items, activeIndex: activeIdx),
            Expanded(
              child: Column(
                children: [
                  _TopBar(title: title, actions: actions),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildNarrow(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final items = user == null ? const <NavItem>[] : navItemsFor(user.role);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [...?actions, const _ProfileMenu()],
      ),
      drawer: items.isEmpty ? null : _MobileDrawer(items: items),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(28, 10, 20, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...?actions,
          const SizedBox(width: 8),
          const _ProfileMenu(),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.items, required this.activeIndex});

  final List<NavItem> items;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;
    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sekolah LMS',
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.role.label ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final selected = i == activeIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Material(
                    color: selected
                        ? theme.colorScheme.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () => context.go(item.path),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Material(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary
                        .withValues(alpha: 0.14),
                    foregroundColor: theme.colorScheme.secondary,
                    child: Text(user.name.isEmpty ? '?' : user.name[0]),
                  ),
                  title: Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    user.email,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    tooltip: 'Keluar',
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.items});
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final loc = GoRouterState.of(context).matchedLocation;
    final activeIdx = activeNavIndex(items, loc);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sekolah LMS',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          user?.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    selected: i == activeIdx,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(item.path);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return PopupMenuButton<String>(
      tooltip: user?.name ?? 'Akun',
      icon: CircleAvatar(
        radius: 17,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.12),
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          (user?.name.isNotEmpty ?? false) ? user!.name[0] : '?',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      onSelected: (v) async {
        if (v == 'logout') {
          await context.read<AuthProvider>().signOut();
          if (context.mounted) context.go('/login');
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                user?.role.label ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(leading: Icon(Icons.logout), title: Text('Keluar')),
        ),
      ],
    );
  }
}
