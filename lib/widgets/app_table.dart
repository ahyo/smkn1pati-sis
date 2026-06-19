import 'package:flutter/material.dart';

import 'empty_state.dart';

class AppTableColumn<T> {
  const AppTableColumn({
    required this.label,
    required this.build,
    this.numeric = false,
  });

  final String label;
  final Widget Function(T) build;
  final bool numeric;
}

class AppTableAction<T> {
  const AppTableAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final void Function(BuildContext, T) onPressed;
  final Color? color;
}

const List<int> _kDefaultPageSizes = [10, 25, 50, 100];

/// Card-wrapped DataTable with numbering column + built-in pagination.
class AppTable<T> extends StatefulWidget {
  const AppTable({
    super.key,
    required this.items,
    required this.columns,
    this.actions,
    this.onRowTap,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Belum ada data',
    this.emptyMessage,
    this.emptyAction,
    this.initialPageSize = 10,
    this.pageSizeOptions = _kDefaultPageSizes,
    this.showRowNumbers = true,
  });

  final List<T> items;
  final List<AppTableColumn<T>> columns;
  final List<AppTableAction<T>>? actions;
  final void Function(T)? onRowTap;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptyMessage;
  final Widget? emptyAction;
  final int initialPageSize;
  final List<int> pageSizeOptions;
  final bool showRowNumbers;

  @override
  State<AppTable<T>> createState() => _AppTableState<T>();
}

class _AppTableState<T> extends State<AppTable<T>> {
  late int _pageSize = widget.initialPageSize;
  int _currentPage = 0;

  int get _maxPage =>
      widget.items.isEmpty ? 0 : (widget.items.length - 1) ~/ _pageSize;

  @override
  void didUpdateWidget(covariant AppTable<T> old) {
    super.didUpdateWidget(old);
    // Items may have shrunk; clamp current page.
    if (_currentPage > _maxPage) {
      _currentPage = _maxPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Card(
        child: SizedBox(
          height: 320,
          child: EmptyState(
            icon: widget.emptyIcon,
            title: widget.emptyTitle,
            message: widget.emptyMessage,
            action: widget.emptyAction,
          ),
        ),
      );
    }

    final total = widget.items.length;
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, total);
    final pageItems = widget.items.sublist(start, end);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.85),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowHeight: 48,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 64,
                    columns: [
                      if (widget.showRowNumbers)
                        const DataColumn(label: Text('No.'), numeric: true),
                      ...widget.columns.map(
                        (c) => DataColumn(
                          label: Text(c.label),
                          numeric: c.numeric,
                        ),
                      ),
                      if (widget.actions != null && widget.actions!.isNotEmpty)
                        const DataColumn(label: SizedBox(width: 1)),
                    ],
                    rows: pageItems.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return DataRow(
                        onSelectChanged: widget.onRowTap == null
                            ? null
                            : (_) => widget.onRowTap!(item),
                        cells: [
                          if (widget.showRowNumbers)
                            DataCell(
                              Text(
                                '${start + i + 1}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ...widget.columns.map((c) => DataCell(c.build(item))),
                          if (widget.actions != null &&
                              widget.actions!.isNotEmpty)
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.actions!
                                    .map(
                                      (a) => IconButton(
                                        icon: Icon(a.icon, size: 18),
                                        tooltip: a.tooltip,
                                        color: a.color,
                                        onPressed: () =>
                                            a.onPressed(context, item),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _PaginationBar(
            total: total,
            startIndex: start,
            endIndex: end,
            pageSize: _pageSize,
            pageSizeOptions: widget.pageSizeOptions,
            currentPage: _currentPage,
            maxPage: _maxPage,
            onPageSizeChange: (s) => setState(() {
              _pageSize = s;
              _currentPage = 0;
            }),
            onFirst: () => setState(() => _currentPage = 0),
            onPrev: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            onNext: _currentPage < _maxPage
                ? () => setState(() => _currentPage++)
                : null,
            onLast: () => setState(() => _currentPage = _maxPage),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.total,
    required this.startIndex,
    required this.endIndex,
    required this.pageSize,
    required this.pageSizeOptions,
    required this.currentPage,
    required this.maxPage,
    required this.onPageSizeChange,
    required this.onFirst,
    required this.onPrev,
    required this.onNext,
    required this.onLast,
  });

  final int total;
  final int startIndex;
  final int endIndex;
  final int pageSize;
  final List<int> pageSizeOptions;
  final int currentPage;
  final int maxPage;
  final ValueChanged<int> onPageSizeChange;
  final VoidCallback onFirst;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tampilkan', style: TextStyle(color: muted, fontSize: 13)),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: pageSize,
                  isDense: true,
                  borderRadius: BorderRadius.circular(8),
                  items: pageSizeOptions
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                      .toList(),
                  onChanged: (v) => v == null ? null : onPageSizeChange(v),
                ),
              ),
              const SizedBox(width: 6),
              Text('per halaman', style: TextStyle(color: muted, fontSize: 13)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${startIndex + 1}–$endIndex dari $total',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Halaman pertama',
                onPressed: currentPage == 0 ? null : onFirst,
                icon: const Icon(Icons.first_page, size: 20),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                ),
              ),
              IconButton(
                tooltip: 'Sebelumnya',
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left, size: 20),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${currentPage + 1} / ${maxPage + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Berikutnya',
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right, size: 20),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                ),
              ),
              IconButton(
                tooltip: 'Halaman terakhir',
                onPressed: currentPage == maxPage ? null : onLast,
                icon: const Icon(Icons.last_page, size: 20),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Layout helper: shows [desktop] when the screen width is >= [breakpoint],
/// otherwise [mobile].
class ResponsiveView extends StatelessWidget {
  const ResponsiveView({
    super.key,
    required this.mobile,
    required this.desktop,
    this.breakpoint = 900,
  });

  final Widget mobile;
  final Widget desktop;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpoint ? desktop : mobile;
  }
}
