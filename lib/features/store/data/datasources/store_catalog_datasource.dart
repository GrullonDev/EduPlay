// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:edu_play/features/store/models/store_item.dart';

abstract class StoreCatalogDatasource {
  Future<List<StoreItem>> getCatalog();
  Future<void> upsertItem(StoreItem item);
  Future<void> deleteItem(String itemId);
}

/// Firestore-backed catalog, collection `storeCatalog/{itemId}`. Also the
/// document shape `firestore.rules` reads from (`cost`, `isProOnly`) to
/// validate purchases server-side — see `isValidPurchaseWrite()` there.
class FirestoreStoreCatalogDatasource implements StoreCatalogDatasource {
  FirestoreStoreCatalogDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _catalog =>
      _firestore.collection('storeCatalog');

  @override
  Future<List<StoreItem>> getCatalog() async {
    try {
      final snapshot = await _catalog.get();
      // Not seeded yet (or an admin deleted every item) — fall back to the
      // static defaults rather than writing to Firestore from whichever
      // client happens to load the store first. `storeCatalog` writes
      // require an admin role (see firestore.rules), so a normal
      // guest/student client could never seed it anyway; it would just
      // fail permission-denied and leave the catalog empty. Seeding is a
      // deliberate admin action — either "Restaurar valores por defecto"
      // in AdminStoreCatalogPage, or the scripts/seed_store_catalog.js
      // migration script (Firebase Admin SDK, bypasses rules entirely).
      if (snapshot.docs.isEmpty) return allStoreItems;
      return snapshot.docs.map((d) => StoreItem.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('FirestoreStoreCatalogDatasource.getCatalog error: $e');
      rethrow;
    }
  }

  @override
  Future<void> upsertItem(StoreItem item) async {
    try {
      await _catalog.doc(item.id).set(item.toJson());
    } catch (e) {
      debugPrint('FirestoreStoreCatalogDatasource.upsertItem error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      await _catalog.doc(itemId).delete();
    } catch (e) {
      debugPrint('FirestoreStoreCatalogDatasource.deleteItem error: $e');
      rethrow;
    }
  }
}
