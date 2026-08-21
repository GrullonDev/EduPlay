// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:edu_play/features/store/domain/repositories/store_catalog_repository.dart';
import 'package:edu_play/features/store/models/store_item.dart';

/// Process-wide, synchronously-readable view of the store catalog.
///
/// Every screen that lists store items (Tienda, Mis compras, the parent
/// approvals card, avatar-icon lookups) used to import the static
/// `allStoreItems` list directly. Now that the catalog can live in
/// Firestore (see `StoreCatalogRepository`), those call sites read
/// [items] instead — it starts seeded with the static list so nothing is
/// ever empty/loading, then swaps to the live Firestore catalog once
/// [ensureLoaded] resolves, notifying listeners so `context.watch` widgets
/// refresh automatically.
class StoreCatalogCache extends ChangeNotifier {
  StoreCatalogCache({required StoreCatalogRepository repository})
      : _repository = repository;

  final StoreCatalogRepository _repository;

  List<StoreItem> items = allStoreItems;
  bool isLoaded = false;

  /// True when the last [ensureLoaded]/[refresh] couldn't reach Firestore
  /// (offline, rules rejection, …) and [items] is the static fallback
  /// rather than the live admin-edited catalog. The Tienda shows a small
  /// banner when this is true instead of failing silently.
  bool hasError = false;

  Future<void>? _loading;

  StoreItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Fetches the live catalog at most once per app session (subsequent
  /// calls await the same in-flight/completed future) — cheap to call from
  /// every screen that needs the catalog without re-fetching repeatedly.
  Future<void> ensureLoaded() {
    return _loading ??= _load();
  }

  Future<void> refresh() {
    _loading = null;
    return ensureLoaded();
  }

  Future<void> _load() async {
    try {
      final catalog = await _repository.getCatalog();
      if (catalog.isNotEmpty) items = catalog;
      hasError = false;
    } catch (e) {
      debugPrint('StoreCatalogCache._load error: $e');
      // Keep whatever was already loaded (or the static seed on first
      // failure) so the Tienda still renders — just flag it as stale.
      hasError = true;
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }
}
