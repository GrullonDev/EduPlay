// Project imports:
import 'package:edu_play/features/store/models/store_item.dart';

abstract class StoreCatalogRepository {
  /// All catalog items. Backed by Firestore so an admin can edit the
  /// catalog without an app release; falls back to the static
  /// `allStoreItems` seed list if Firestore is empty or unreachable.
  Future<List<StoreItem>> getCatalog();

  Future<void> upsertItem(StoreItem item);

  Future<void> deleteItem(String itemId);
}
