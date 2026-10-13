import 'package:flutter/widgets.dart';

/// Minimal offset-based infinite scroll: holds the loaded items, fetches the next page once
/// the user scrolls near the bottom. One instance per screen, kept as a State field (not
/// const/shared) since it carries mutable list state across rebuilds.
class PaginatedList<T> {
  PaginatedList({required this.fetchPage, this.pageSize = 50});

  final Future<List<T>> Function(int offset, int limit) fetchPage;
  final int pageSize;

  final List<T> items = [];
  bool hasMore = true;
  bool isLoadingMore = false;

  Future<void> loadFirstPage() async {
    final page = await fetchPage(0, pageSize);
    items
      ..clear()
      ..addAll(page);
    hasMore = page.length == pageSize;
  }

  /// Returns true if it actually fetched something (so the caller knows to rebuild).
  Future<bool> loadMore() async {
    if (isLoadingMore || !hasMore) return false;
    isLoadingMore = true;
    try {
      final page = await fetchPage(items.length, pageSize);
      items.addAll(page);
      hasMore = page.length == pageSize;
      return true;
    } catch (_) {
      // Transient failure: keep what's loaded; the next scroll near the bottom retries.
      return false;
    } finally {
      isLoadingMore = false;
    }
  }

  /// Triggers [loadMore] once the list is scrolled within 300px of the bottom ("hard scroll
  /// past the end"), then calls [onChanged] to rebuild once the new page lands.
  void attachScrollController(ScrollController controller, VoidCallback onChanged) {
    controller.addListener(() {
      if (!hasMore || isLoadingMore) return;
      if (controller.position.pixels < controller.position.maxScrollExtent - 300) return;
      loadMore().then((loaded) {
        if (loaded) onChanged();
      });
    });
  }
}
