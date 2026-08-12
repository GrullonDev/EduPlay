import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firestore-backed datasource for the student gamification profile
/// (points, streak, level) and per-game score history. This is the data
/// source shared between the student dashboard (own profile) and the
/// teacher dashboard (roster + aggregates), so it works across devices and
/// on the web build where the local sqflite database is unavailable.
class StudentDatasource {
  StudentDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _studentIdKey = 'student_id';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _students =>
      _firestore.collection('students');

  Future<void> setStudentId(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentIdKey, studentId);
  }

  Future<String> getOrCreateStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_studentIdKey);
    if (id == null) {
      id = _firestore.collection('students').doc().id;
      await prefs.setString(_studentIdKey, id);
    }
    return id;
  }

  Future<void> ensureProfile({
    required String studentId,
    required String name,
    required int age,
    String? avatar,
    String? parentUid,
  }) async {
    try {
      final doc = _students.doc(studentId);
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        await doc.set({
          'name': name,
          'age': age,
          'avatar': avatar ?? 'lion',
          'points': 0,
          'streak': 0,
          'lastPlayedDate': null,
          'childProfileId': studentId,
          if (parentUid != null) 'parentUid': parentUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await doc.set({
          'name': name,
          'age': age,
          if (avatar != null) 'avatar': avatar,
          if (parentUid != null) 'parentUid': parentUid,
          'childProfileId': studentId,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('StudentDatasource.ensureProfile error: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfile(String studentId) async {
    try {
      final snapshot = await _students.doc(studentId).get();
      if (!snapshot.exists) return null;
      return {...snapshot.data()!, 'id': snapshot.id};
    } catch (e) {
      debugPrint('StudentDatasource.getProfile error: $e');
      return null;
    }
  }

  Future<void> recordScore({
    required String studentId,
    required String subjectKey,
    required String subjectLabel,
    required String gameTitle,
    required int score,
  }) async {
    try {
      final doc = _students.doc(studentId);
      final now = DateTime.now();
      final today = _dateKey(now);
      final yesterday = _dateKey(now.subtract(const Duration(days: 1)));

      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(doc);
        final data = snapshot.data();
        final lastPlayedDate = data?['lastPlayedDate'] as String?;
        var streak = (data?['streak'] as num?)?.toInt() ?? 0;

        if (lastPlayedDate == today) {
          // Already played today, streak stays the same.
        } else if (lastPlayedDate == yesterday) {
          streak += 1;
        } else {
          streak = 1;
        }

        tx.set(
          doc,
          {
            'points': FieldValue.increment(score),
            'streak': streak,
            'lastPlayedDate': today,
          },
          SetOptions(merge: true),
        );
      });

      await doc.collection('scores').add({
        'studentId': studentId,
        'subjectKey': subjectKey,
        'subjectLabel': subjectLabel,
        'gameTitle': gameTitle,
        'score': score,
        'date': Timestamp.fromDate(now),
      });
    } catch (e) {
      debugPrint('StudentDatasource.recordScore error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _students
          .orderBy('points', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      debugPrint('StudentDatasource.getLeaderboard error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final snapshot =
          await _students.orderBy('points', descending: true).get();
      return snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      debugPrint('StudentDatasource.getAllStudents error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final results = <Map<String, dynamic>>[];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final snapshot =
            await _students.where(FieldPath.documentId, whereIn: chunk).get();
        results.addAll(
          snapshot.docs.map((d) => {...d.data(), 'id': d.id}),
        );
      }
      return results;
    } catch (e) {
      debugPrint('StudentDatasource.getStudentsByIds error: $e');
      return [];
    }
  }

  /// All score entries (across every student) from the last [days] days,
  /// used to build the teacher's weekly progress chart and per-subject
  /// performance breakdown.
  Future<List<Map<String, dynamic>>> getRecentScores({int days = 28}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collectionGroup('scores')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('StudentDatasource.getRecentScores error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentScoresForStudents(
    List<String> studentIds, {
    int days = 28,
  }) async {
    if (studentIds.isEmpty) return [];

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final results = <Map<String, dynamic>>[];

    try {
      for (final studentId in studentIds) {
        final snapshot = await _students
            .doc(studentId)
            .collection('scores')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
            .get();
        results.addAll(
          snapshot.docs.map((d) => {
                ...d.data(),
                'studentId': studentId,
              }),
        );
      }
      return results;
    } catch (e) {
      debugPrint('StudentDatasource.getRecentScoresForStudents error: $e');
      return [];
    }
  }

  String _dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Maps a Firestore/transaction failure to the most specific
  /// [PurchaseResult] the caller can act on, instead of collapsing every
  /// failure into a generic "something went wrong".
  PurchaseResult _resultForError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'unavailable':
        case 'deadline-exceeded':
        case 'cancelled':
        case 'aborted':
          return PurchaseResult.networkError;
        case 'permission-denied':
          return PurchaseResult.permissionDenied;
      }
    }
    return PurchaseResult.error;
  }

  /// Atomically spends [cost] points on [itemId], guarding against
  /// insufficient balance and duplicate purchases. Modeled on [recordScore]'s
  /// transaction, but — unlike the rest of this file — deliberately does not
  /// swallow the outcome: the Tienda UI needs to know *why* a purchase failed.
  ///
  /// Also declares `lastPurchase: {itemId, cost}` — a plain scalar map
  /// firestore.rules can validate against the `storeCatalog` collection and
  /// the buyer's `subscriptions` doc without needing set-diff gymnastics on
  /// `ownedItemIds`. See firestore.rules `isValidPurchaseWrite()`.
  Future<PurchaseResult> purchaseItem({
    required String studentId,
    required String itemId,
    required String itemName,
    required int cost,
  }) async {
    final doc = _students.doc(studentId);
    try {
      return await _firestore.runTransaction((tx) async {
        final data = (await tx.get(doc)).data() ?? <String, dynamic>{};
        final owned = List<String>.from(data['ownedItemIds'] as List? ?? []);
        if (owned.contains(itemId)) return PurchaseResult.alreadyOwned;

        final points = (data['points'] as num?)?.toInt() ?? 0;
        if (points < cost) return PurchaseResult.insufficientPoints;

        final purchasedAt =
            Map<String, dynamic>.from(data['purchasedAt'] as Map? ?? {});
        purchasedAt[itemId] = Timestamp.now();

        // fake_cloud_firestore's runTransaction doesn't honor
        // SetOptions(merge: true): a tx.set() inside a transaction silently
        // replaces the whole document with exactly the map given, dropping
        // every field not mentioned — and separately, even outside a
        // transaction, a plain top-level Map-valued field under merge:true
        // only adds/overwrites keys, it never removes ones missing from the
        // new value. Real Firestore does neither of those things, but since
        // this is the only way the Dart suite can exercise the purchase
        // logic, sidestep both by computing the complete document ourselves
        // from the already-read `data` and writing it as a plain (non-merge)
        // replace — which is unambiguous everywhere.
        tx.set(doc, {
          ...data,
          'points': points - cost,
          'ownedItemIds': [...owned, itemId],
          'purchasedAt': purchasedAt,
          'lastPurchase': {'itemId': itemId, 'cost': cost},
        });
        tx.set(doc.collection('transactions').doc(), {
          'itemId': itemId,
          'itemName': itemName,
          'cost': cost,
          'balanceBefore': points,
          'balanceAfter': points - cost,
          'type': 'purchase',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return PurchaseResult.success;
      });
    } catch (e) {
      debugPrint('StudentDatasource.purchaseItem error: $e');
      return _resultForError(e);
    }
  }

  /// Records a purchase request instead of spending points immediately, for
  /// students whose parent has turned on "requires approval" in the Parent
  /// Quick Controls. Held as a `{itemId: cost}` entry in the `pendingPurchases`
  /// map so [approvePendingPurchase]/[rejectPendingPurchase] can target it by
  /// field path without needing exact array-element equality.
  Future<PurchaseResult> requestPurchase({
    required String studentId,
    required String itemId,
    required int cost,
  }) async {
    final doc = _students.doc(studentId);
    try {
      return await _firestore.runTransaction((tx) async {
        final data = (await tx.get(doc)).data() ?? <String, dynamic>{};
        final owned = List<String>.from(data['ownedItemIds'] as List? ?? []);
        if (owned.contains(itemId)) return PurchaseResult.alreadyOwned;

        final pending =
            Map<String, dynamic>.from(data['pendingPurchases'] as Map? ?? {});
        if (pending.containsKey(itemId)) return PurchaseResult.pendingApproval;

        final points = (data['points'] as num?)?.toInt() ?? 0;
        if (points < cost) return PurchaseResult.insufficientPoints;

        pending[itemId] = cost;
        // See purchaseItem's comment: full replace, not merge, so untouched
        // fields (points, name, ...) survive intact.
        tx.set(doc, {
          ...data,
          'pendingPurchases': pending,
          'lastPurchase': {'itemId': itemId, 'cost': cost},
        });
        return PurchaseResult.pendingApproval;
      });
    } catch (e) {
      debugPrint('StudentDatasource.requestPurchase error: $e');
      return _resultForError(e);
    }
  }

  /// Parent-side action: completes a pending purchase request, spending the
  /// points and granting the item exactly like [purchaseItem] would have.
  Future<PurchaseResult> approvePendingPurchase({
    required String studentId,
    required String itemId,
    required String itemName,
  }) async {
    final doc = _students.doc(studentId);
    try {
      return await _firestore.runTransaction((tx) async {
        final data = (await tx.get(doc)).data() ?? <String, dynamic>{};
        final pending =
            Map<String, dynamic>.from(data['pendingPurchases'] as Map? ?? {});
        final cost = (pending[itemId] as num?)?.toInt();
        if (cost == null) return PurchaseResult.error;

        final owned = List<String>.from(data['ownedItemIds'] as List? ?? []);
        if (owned.contains(itemId)) {
          pending.remove(itemId);
          tx.set(doc, {...data, 'pendingPurchases': pending});
          return PurchaseResult.alreadyOwned;
        }

        final points = (data['points'] as num?)?.toInt() ?? 0;
        if (points < cost) return PurchaseResult.insufficientPoints;

        pending.remove(itemId);
        final purchasedAt =
            Map<String, dynamic>.from(data['purchasedAt'] as Map? ?? {});
        purchasedAt[itemId] = Timestamp.now();

        // See purchaseItem's comment: full replace, not merge.
        tx.set(doc, {
          ...data,
          'points': points - cost,
          'ownedItemIds': [...owned, itemId],
          'pendingPurchases': pending,
          'purchasedAt': purchasedAt,
          'lastPurchase': {'itemId': itemId, 'cost': cost},
        });
        tx.set(doc.collection('transactions').doc(), {
          'itemId': itemId,
          'itemName': itemName,
          'cost': cost,
          'balanceBefore': points,
          'balanceAfter': points - cost,
          'type': 'approvedPurchase',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return PurchaseResult.success;
      });
    } catch (e) {
      debugPrint('StudentDatasource.approvePendingPurchase error: $e');
      return _resultForError(e);
    }
  }

  /// Parent-side action: declines a pending purchase request without
  /// spending any points.
  Future<void> rejectPendingPurchase({
    required String studentId,
    required String itemId,
  }) async {
    final doc = _students.doc(studentId);
    try {
      // Transaction + full replace, not a bare merge write: see
      // purchaseItem's comment on why a plain top-level Map field under
      // merge:true can't reliably remove a key.
      await _firestore.runTransaction((tx) async {
        final data = (await tx.get(doc)).data() ?? <String, dynamic>{};
        final pending =
            Map<String, dynamic>.from(data['pendingPurchases'] as Map? ?? {});
        pending.remove(itemId);
        tx.set(doc, {...data, 'pendingPurchases': pending});
      });
    } catch (e) {
      debugPrint('StudentDatasource.rejectPendingPurchase error: $e');
    }
  }

  /// Equips a purchased avatar color and/or icon. Only the provided fields
  /// are written, so equipping a color doesn't clear an equipped icon.
  Future<void> equipAvatar({
    required String studentId,
    String? colorHex,
    String? iconId,
  }) async {
    try {
      await _students.doc(studentId).set(
        {
          if (colorHex != null) 'equippedAvatarColorHex': colorHex,
          if (iconId != null) 'equippedAvatarIcon': iconId,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('StudentDatasource.equipAvatar error: $e');
    }
  }

  /// Clears the equipped avatar color and/or icon, reverting to the default
  /// avatar rendering (solid navy circle with the student's initial).
  Future<void> unequipAvatar({
    required String studentId,
    bool clearColor = false,
    bool clearIcon = false,
  }) async {
    if (!clearColor && !clearIcon) return;
    try {
      await _students.doc(studentId).update({
        if (clearColor) 'equippedAvatarColorHex': FieldValue.delete(),
        if (clearIcon) 'equippedAvatarIcon': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('StudentDatasource.unequipAvatar error: $e');
    }
  }

  /// Most recent spending-history entries, newest first, for the "Mis
  /// compras" transaction log and for computing spend-limit windows.
  Future<List<Map<String, dynamic>>> getTransactions(
    String studentId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _students
          .doc(studentId)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('StudentDatasource.getTransactions error: $e');
      return [];
    }
  }

  /// One-time merge of a guest's locally-accumulated points into a
  /// freshly-registered Firestore profile (see
  /// `StudentDashboardBloc._maybeSyncGuestPurchases`).
  ///
  /// Deliberately points-only, NOT items: a guest's `ownedItemIds` live
  /// entirely in local SharedPreferences with zero server validation while
  /// in guest mode, so a manipulated guest client could claim ownership of
  /// any item (including a PRO-only sticker) for free. Carrying that into
  /// Firestore on registration — the moment items actually become
  /// consequential (tradeable proof of "you bought this") — would bypass
  /// firestore.rules' PRO/price validation entirely, since a plain points
  /// increment can't also satisfy `isValidOwnedItemsGrowth()`'s "declare and
  /// validate the item being added" shape. Points have no such trust
  /// problem — they're just a number — so only points transfer; any
  /// avatar cosmetics/stickers a guest picked before registering are not
  /// carried over.
  Future<void> syncGuestPoints({
    required String studentId,
    required int points,
  }) async {
    if (points <= 0) return;
    try {
      await _students.doc(studentId).set(
        {'points': FieldValue.increment(points)},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('StudentDatasource.syncGuestPoints error: $e');
    }
  }
}

enum PurchaseResult {
  success,
  alreadyOwned,
  insufficientPoints,
  pendingApproval,
  spendLimitReached,
  levelLocked,
  networkError,
  permissionDenied,
  error,
}
