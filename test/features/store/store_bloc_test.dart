// Covers the three purchase-gating behaviors the store relies on:
//   1. StoreBloc's general filter/gating logic (pure, no async settling needed)
//   2. Guest purchases: exactly 3 allowed, the 4th is blocked
//   3. PRO-only stickers: blocked for a free student, allowed for a PRO one
//
// firestore.rules' server-side price/PRO validation is NOT exercised here —
// fake_cloud_firestore has no rules engine. That needs the Firebase
// emulator's rules-unit-testing tool (Node-based), out of scope for this
// Dart suite; see the PR notes for how to check it manually.

import 'package:edu_play/features/store/bloc/store_bloc.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support.dart';

StoreItem _item(String id) => allStoreItems.firstWhere((i) => i.id == id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await sl.reset();
  });

  group('StoreBloc filtering and gating (pure logic)', () {
    late StudentDashboardBloc dashboardBloc;
    late StoreBloc storeBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      registerTestFakes();
      dashboardBloc = StudentDashboardBloc(age: 8, isGuest: true);
      await settle(dashboardBloc);
      storeBloc = StoreBloc(dashboardBloc: dashboardBloc);
    });

    tearDown(() {
      storeBloc.dispose();
      dashboardBloc.dispose();
    });

    test('filterItems narrows by category', () {
      final colorsOnly =
          storeBloc.filterItems(allStoreItems)..retainWhere((_) => true);
      storeBloc.setFilter(StoreFilter.avatarColor);
      final filtered = storeBloc.filterItems(allStoreItems);
      expect(filtered, isNotEmpty);
      expect(filtered.every((i) => i.category == StoreCategory.avatarColor), isTrue);
      expect(colorsOnly.length, greaterThanOrEqualTo(filtered.length));
    });

    test('filterItems(pro) returns only PRO-only items', () {
      storeBloc.setFilter(StoreFilter.pro);
      final filtered = storeBloc.filterItems(allStoreItems);
      expect(filtered, isNotEmpty);
      expect(filtered.every((i) => i.isProOnly), isTrue);
    });

    test('isLevelLocked reflects the student level vs item.minLevel', () {
      final leveledItem = _item('avatar_color_gold'); // minLevel: 3
      expect(dashboardBloc.level, 1); // 0 points → level 1
      expect(storeBloc.isLevelLocked(leveledItem), isTrue);
    });

    test('canPurchase is false for an item already owned', () async {
      SharedPreferences.setMockInitialValues({'edu_play_guest_points': 1000});
      final bloc2 = StudentDashboardBloc(age: 8, isGuest: true);
      await settle(bloc2);
      final store2 = StoreBloc(dashboardBloc: bloc2);
      final ruby = _item('avatar_color_ruby');

      expect(store2.canPurchase(ruby), isTrue);
      await store2.purchase(ruby);
      expect(store2.canPurchase(ruby), isFalse);

      store2.dispose();
      bloc2.dispose();
    });
  });

  group('Guest purchase limit', () {
    test('allows exactly 3 purchases, then blocks the 4th', () async {
      SharedPreferences.setMockInitialValues({'edu_play_guest_points': 1000});
      registerTestFakes();
      final dashboardBloc = StudentDashboardBloc(age: 8, isGuest: true);
      await settle(dashboardBloc);
      final storeBloc = StoreBloc(dashboardBloc: dashboardBloc);

      final ruby = _item('avatar_color_ruby');
      final emerald = _item('avatar_color_emerald');
      final sapphire = _item('avatar_color_sapphire');
      final amber = _item('avatar_color_amber');

      expect(await storeBloc.purchase(ruby), PurchaseOutcome.success);
      expect(dashboardBloc.guestPurchasesRemaining, 2);

      expect(await storeBloc.purchase(emerald), PurchaseOutcome.success);
      expect(dashboardBloc.guestPurchasesRemaining, 1);

      expect(await storeBloc.purchase(sapphire), PurchaseOutcome.success);
      expect(dashboardBloc.guestPurchasesRemaining, 0);
      expect(dashboardBloc.hasGuestPurchasesRemaining, isFalse);
      expect(storeBloc.guestLimitReached, isTrue);

      // The 4th purchase must be rejected even though the guest can afford it.
      final outcome = await storeBloc.purchase(amber);
      expect(outcome, PurchaseOutcome.failed);
      expect(dashboardBloc.ownedItemIds.contains(amber.id), isFalse);
      expect(dashboardBloc.ownedItemIds.length, 3);

      storeBloc.dispose();
      dashboardBloc.dispose();
    });
  });

  group('PRO-only sticker gating', () {
    test('a free (non-PRO) registered student cannot buy a PRO sticker',
        () async {
      SharedPreferences.setMockInitialValues({'student_id': 'free_student'});
      final firestore = registerTestFakes(isProSubscriber: false);
      await firestore.collection('students').doc('free_student').set({
        'name': 'Ana',
        'age': 8,
        'points': 500,
        'streak': 0,
      });

      final dashboardBloc = StudentDashboardBloc(age: 8, username: 'Ana');
      await settle(dashboardBloc);
      final storeBloc = StoreBloc(dashboardBloc: dashboardBloc);
      final sticker = _item('unicorn');

      expect(dashboardBloc.isProSubscriber, isFalse);
      expect(storeBloc.canAccess(sticker), isFalse);

      final outcome = await storeBloc.purchase(sticker);

      expect(outcome, PurchaseOutcome.failed);
      expect(storeBloc.lastError, contains('PRO'));
      expect(dashboardBloc.ownedItemIds.contains('unicorn'), isFalse);

      storeBloc.dispose();
      dashboardBloc.dispose();
    });

    test('a PRO subscriber can buy a PRO-only sticker', () async {
      SharedPreferences.setMockInitialValues({'student_id': 'pro_student'});
      final firestore = registerTestFakes(isProSubscriber: true);
      await firestore.collection('students').doc('pro_student').set({
        'name': 'Leo',
        'age': 9,
        'points': 500,
        'streak': 0,
      });

      final dashboardBloc = StudentDashboardBloc(age: 9, username: 'Leo');
      await settle(dashboardBloc);
      final storeBloc = StoreBloc(dashboardBloc: dashboardBloc);
      final sticker = _item('unicorn'); // cost 150

      expect(dashboardBloc.isProSubscriber, isTrue);
      expect(storeBloc.canAccess(sticker), isTrue);

      final outcome = await storeBloc.purchase(sticker);

      expect(outcome, PurchaseOutcome.success);
      expect(dashboardBloc.ownedItemIds.contains('unicorn'), isTrue);
      expect(dashboardBloc.points, 500 - sticker.cost);

      storeBloc.dispose();
      dashboardBloc.dispose();
    });
  });
}
