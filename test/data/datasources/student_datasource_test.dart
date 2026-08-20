// Tests the real Firestore-transaction purchase logic in StudentDatasource
// against fake_cloud_firestore, so these exercise the exact same code path
// production purchases run through — not a reimplementation of it.

// Package imports:
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/data/datasources/student_datasource.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StudentDatasource datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = StudentDatasource(firestore: firestore);
  });

  Future<void> seedStudent(String id, {int points = 0}) {
    return firestore.collection('students').doc(id).set({
      'name': 'Explorador',
      'age': 8,
      'points': points,
      'streak': 0,
    });
  }

  group('purchaseItem', () {
    test('spends points and grants the item on success', () async {
      await seedStudent('s1', points: 100);

      final result = await datasource.purchaseItem(
        studentId: 's1',
        itemId: 'avatar_color_ruby',
        itemName: 'Rubí',
        cost: 40,
      );

      expect(result, PurchaseResult.success);
      final doc = await firestore.collection('students').doc('s1').get();
      expect(doc.data()!['points'], 60);
      expect(doc.data()!['ownedItemIds'], contains('avatar_color_ruby'));
      expect(doc.data()!['purchasedAt'], contains('avatar_color_ruby'));
      expect(doc.data()!['lastPurchase'], {'itemId': 'avatar_color_ruby', 'cost': 40});

      final transactions = await firestore
          .collection('students')
          .doc('s1')
          .collection('transactions')
          .get();
      expect(transactions.docs, hasLength(1));
      expect(transactions.docs.first.data()['balanceBefore'], 100);
      expect(transactions.docs.first.data()['balanceAfter'], 60);
      expect(transactions.docs.first.data()['type'], 'purchase');
    });

    test('rejects a duplicate purchase of the same item', () async {
      await firestore.collection('students').doc('s2').set({
        'name': 'Explorador',
        'age': 8,
        'points': 100,
        'streak': 0,
        'ownedItemIds': ['avatar_color_ruby'],
      });

      final result = await datasource.purchaseItem(
        studentId: 's2',
        itemId: 'avatar_color_ruby',
        itemName: 'Rubí',
        cost: 40,
      );

      expect(result, PurchaseResult.alreadyOwned);
      final doc = await firestore.collection('students').doc('s2').get();
      expect(doc.data()!['points'], 100); // unchanged
    });

    test('rejects a purchase the student cannot afford', () async {
      await seedStudent('s3', points: 10);

      final result = await datasource.purchaseItem(
        studentId: 's3',
        itemId: 'avatar_color_ruby',
        itemName: 'Rubí',
        cost: 40,
      );

      expect(result, PurchaseResult.insufficientPoints);
      final doc = await firestore.collection('students').doc('s3').get();
      expect(doc.data()!['points'], 10); // unchanged
      expect(doc.data()!['ownedItemIds'], isNull);
    });
  });

  group('requestPurchase / approvePendingPurchase / rejectPendingPurchase', () {
    test('a request holds the item without spending points', () async {
      await seedStudent('s4', points: 300);

      final result = await datasource.requestPurchase(
        studentId: 's4',
        itemId: 'dragon',
        cost: 300,
      );

      expect(result, PurchaseResult.pendingApproval);
      final doc = await firestore.collection('students').doc('s4').get();
      expect(doc.data()!['points'], 300); // untouched until approved
      expect(doc.data()!['pendingPurchases'], {'dragon': 300});
      expect(doc.data()!['ownedItemIds'], isNull);
    });

    test('approval spends the points and grants the item', () async {
      await seedStudent('s5', points: 300);
      await datasource.requestPurchase(studentId: 's5', itemId: 'dragon', cost: 300);

      final result = await datasource.approvePendingPurchase(
        studentId: 's5',
        itemId: 'dragon',
        itemName: 'Dragón de Fuego',
      );

      expect(result, PurchaseResult.success);
      final doc = await firestore.collection('students').doc('s5').get();
      expect(doc.data()!['points'], 0);
      expect(doc.data()!['ownedItemIds'], contains('dragon'));
      expect(doc.data()!['pendingPurchases'], isEmpty);

      final transactions = await firestore
          .collection('students')
          .doc('s5')
          .collection('transactions')
          .get();
      expect(transactions.docs.single.data()['type'], 'approvedPurchase');
    });

    test('rejection clears the request without spending points', () async {
      await seedStudent('s6', points: 300);
      await datasource.requestPurchase(studentId: 's6', itemId: 'dragon', cost: 300);

      await datasource.rejectPendingPurchase(studentId: 's6', itemId: 'dragon');

      final doc = await firestore.collection('students').doc('s6').get();
      expect(doc.data()!['points'], 300);
      expect(doc.data()!['pendingPurchases'], isEmpty);
      expect(doc.data()!['ownedItemIds'], isNull);
    });
  });

  group('unequipAvatar', () {
    test('clears only the requested slot', () async {
      await firestore.collection('students').doc('s7').set({
        'name': 'Explorador',
        'age': 8,
        'points': 0,
        'streak': 0,
        'equippedAvatarColorHex': 'E53935',
        'equippedAvatarIcon': 'avatar_icon_star',
      });

      await datasource.unequipAvatar(studentId: 's7', clearColor: true);

      final doc = await firestore.collection('students').doc('s7').get();
      expect(doc.data()!.containsKey('equippedAvatarColorHex'), isFalse);
      expect(doc.data()!['equippedAvatarIcon'], 'avatar_icon_star');
    });
  });

  group('getTransactions', () {
    test('returns entries newest first', () async {
      await seedStudent('s8', points: 1000);
      await datasource.purchaseItem(
        studentId: 's8',
        itemId: 'avatar_color_ruby',
        itemName: 'Rubí',
        cost: 40,
      );
      await datasource.purchaseItem(
        studentId: 's8',
        itemId: 'avatar_icon_star',
        itemName: 'Estrella',
        cost: 60,
      );

      final transactions = await datasource.getTransactions('s8');

      expect(transactions, hasLength(2));
      expect(transactions.first['itemId'], 'avatar_icon_star');
      expect(transactions.last['itemId'], 'avatar_color_ruby');
    });
  });
}
