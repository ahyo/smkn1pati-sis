import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A `ListView.separated` that initially shows [initialBatch] items and grows
/// by [loadStep] when the user scrolls near the bottom — basic infinite-
/// scroll/load-more for in-memory data.
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.initialBatch = 15,
    this.loadStep = 15,
    this.loadTriggerOffset = 240,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int absoluteIndex)
      itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final int initialBatch;
  final int loadStep;
  final double loadTriggerOffset;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late int _shown;
  final ScrollController _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _shown = math.min(widget.initialBatch, widget.items.length);
    _ctrl.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant PaginatedListView<T> old) {
    super.didUpdateWidget(old);
    // List grew (or arrived after first build) — show at least the initial
    // batch.
    if (_shown < widget.initialBatch &&
        widget.items.length > old.items.length) {
      _shown = math.min(widget.initialBatch, widget.items.length);
    }
    // List shrunk past current window.
    if (_shown > widget.items.length) {
      _shown = widget.items.length;
    }
  }

  @override
  void dispose() {
    _ctrl
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_shown >= widget.items.length) return;
    if (!_ctrl.hasClients) return;
    final pos = _ctrl.position;
    if (pos.pixels >= pos.maxScrollExtent - widget.loadTriggerOffset) {
      setState(() {
        _shown = math.min(_shown + widget.loadStep, widget.items.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _shown < widget.items.length;
    final separator =
        widget.separatorBuilder ?? (_, _) => const SizedBox(height: 8);

    return ListView.separated(
      controller: _ctrl,
      padding: widget.padding,
      itemCount: _shown + (hasMore ? 1 : 0),
      separatorBuilder: separator,
      itemBuilder: (context, idx) {
        if (idx >= _shown) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Memuat data berikutnya...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        }
        return widget.itemBuilder(context, widget.items[idx], idx);
      },
    );
  }
}
