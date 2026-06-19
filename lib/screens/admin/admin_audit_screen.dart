import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/audit_log.dart';
import '../../providers/data_provider.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/paginated_list_view.dart';
import '../../widgets/role_scaffold.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _categoryFilter;
  AuditAction? _actionFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(AuditLog l) {
    if (_categoryFilter != null && l.action.category != _categoryFilter) {
      return false;
    }
    if (_actionFilter != null && l.action != _actionFilter) return false;
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return (l.actorName?.toLowerCase().contains(q) ?? false) ||
        (l.actorEmail?.toLowerCase().contains(q) ?? false) ||
        (l.targetLabel?.toLowerCase().contains(q) ?? false) ||
        (l.deviceLabel?.toLowerCase().contains(q) ?? false) ||
        (l.note?.toLowerCase().contains(q) ?? false) ||
        l.action.label.toLowerCase().contains(q);
  }

  void _reset() {
    setState(() {
      _query = '';
      _searchCtrl.clear();
      _categoryFilter = null;
      _actionFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final scheme = Theme.of(context).colorScheme;
    final all = [...data.auditLogs]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final filtered = all.where(_matches).toList();
    final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    final categoryCounts = <String, int>{};
    for (final l in all) {
      categoryCounts[l.action.category] =
          (categoryCounts[l.action.category] ?? 0) + 1;
    }
    final categories = ['Akun', 'Pengguna', 'Kelas', 'Mapel'];

    final hasActiveFilter = _query.isNotEmpty ||
        _categoryFilter != null ||
        _actionFilter != null;

    return RoleScaffold(
      title: 'Audit Trail',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Audit Trail',
            subtitle: hasActiveFilter
                ? '${filtered.length} dari ${all.length} aktivitas'
                : '${all.length} aktivitas tercatat',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(builder: (context, c) {
                      final wide = c.maxWidth >= 720;
                      final search = TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Cari nama, email, perangkat, target...',
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
                      final reset = OutlinedButton.icon(
                        onPressed: hasActiveFilter ? _reset : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      );
                      if (wide) {
                        return Row(
                          children: [
                            Expanded(child: search),
                            const SizedBox(width: 12),
                            reset,
                          ],
                        );
                      }
                      return Column(
                        children: [
                          search,
                          const SizedBox(height: 12),
                          Align(
                              alignment: Alignment.centerRight, child: reset),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('Semua (${all.length})'),
                          selected: _categoryFilter == null,
                          onSelected: (_) => setState(() {
                            _categoryFilter = null;
                            _actionFilter = null;
                          }),
                        ),
                        for (final c in categories)
                          ChoiceChip(
                            label: Text('$c (${categoryCounts[c] ?? 0})'),
                            selected: _categoryFilter == c,
                            onSelected: (_) => setState(() {
                              _categoryFilter = c;
                              if (_actionFilter != null &&
                                  _actionFilter!.category != c) {
                                _actionFilter = null;
                              }
                            }),
                          ),
                      ],
                    ),
                    if (_categoryFilter != null) ...[
                      const Divider(height: 24),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('Semua aksi'),
                            selected: _actionFilter == null,
                            onSelected: (_) =>
                                setState(() => _actionFilter = null),
                          ),
                          for (final a in AuditAction.values
                              .where((a) => a.category == _categoryFilter))
                            ChoiceChip(
                              label: Text(a.label),
                              avatar: Icon(a.icon,
                                  size: 14, color: a.color(scheme)),
                              selected: _actionFilter == a,
                              onSelected: (_) =>
                                  setState(() => _actionFilter = a),
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
                  child: AppTable<AuditLog>(
                    items: filtered,
                    columns: [
                      AppTableColumn(
                        label: 'Waktu',
                        build: (l) => Text(df.format(l.timestamp)),
                      ),
                      AppTableColumn(
                        label: 'Aksi',
                        build: (l) => _ActionChip(action: l.action),
                      ),
                      AppTableColumn(
                        label: 'Pengguna',
                        build: (l) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l.actorName ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            if (l.actorEmail != null)
                              Text(l.actorEmail!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      AppTableColumn(
                        label: 'Peran',
                        build: (l) => Text(l.actorRole ?? '-'),
                      ),
                      AppTableColumn(
                        label: 'Target',
                        build: (l) => Text(l.targetLabel ?? '-',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      AppTableColumn(
                        label: 'Perangkat',
                        build: (l) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.devices,
                                size: 14, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(l.deviceLabel ?? '-',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      AppTableColumn(
                        label: 'Catatan',
                        build: (l) => Text(l.note ?? '-',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    emptyIcon: hasActiveFilter
                        ? Icons.search_off
                        : Icons.history,
                    emptyTitle: hasActiveFilter
                        ? 'Tidak ada hasil'
                        : 'Belum ada aktivitas',
                    emptyMessage: hasActiveFilter
                        ? 'Coba ubah filter atau kata kunci.'
                        : 'Aktivitas pengguna akan muncul di sini.',
                    emptyAction: hasActiveFilter
                        ? OutlinedButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Filter'),
                          )
                        : null,
                  ),
                ),
              ),
              mobile: filtered.isEmpty
                  ? EmptyState(
                      icon: hasActiveFilter
                          ? Icons.search_off
                          : Icons.history,
                      title: hasActiveFilter
                          ? 'Tidak ada hasil'
                          : 'Belum ada aktivitas',
                      action: hasActiveFilter
                          ? OutlinedButton.icon(
                              onPressed: _reset,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filter'),
                            )
                          : null,
                    )
                  : PaginatedListView<AuditLog>(
                      items: filtered,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemBuilder: (_, l, i) {
                        final c = l.action.color(scheme);
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: c.withValues(alpha: 0.15),
                              child: Icon(l.action.icon, color: c, size: 18),
                            ),
                            title: Text(
                              '${i + 1}. ${l.actorName ?? l.actorEmail ?? 'Tanpa nama'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${l.action.label}${l.targetLabel != null ? ' • ${l.targetLabel}' : ''}'),
                                Text(
                                    '${df.format(l.timestamp)} • ${l.deviceLabel ?? '-'}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: scheme.onSurfaceVariant)),
                                if (l.note != null && l.note!.isNotEmpty)
                                  Text(l.note!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: scheme.error)),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action});
  final AuditAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = action.color(scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(action.label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
