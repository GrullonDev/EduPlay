import 'package:edu_play/features/store/data/datasources/store_catalog_datasource.dart';
import 'package:edu_play/features/store/domain/repositories/store_catalog_repository.dart';
import 'package:edu_play/features/store/models/store_item.dart';

class FirestoreStoreCatalogRepository implements StoreCatalogRepository {
  FirestoreStoreCatalogRepository({required StoreCatalogDatasource datasource})
      : _datasource = datasource;

  final StoreCatalogDatasource _datasource;

  @override
  Future<List<StoreItem>> getCatalog() => _datasource.getCatalog();

  @override
  Future<void> upsertItem(StoreItem item) => _datasource.upsertItem(item);

  @override
  Future<void> deleteItem(String itemId) => _datasource.deleteItem(itemId);
}
