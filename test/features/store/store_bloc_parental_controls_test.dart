// Covers two parent-configured controls that gate StoreBloc.purchase for a
// *registered* (non-guest) student:
//   1. "Requires approval" — a purchase is held as a pending request instead
//      of completing immediately, until a parent approves it.
//   2. Spend limit (daily/weekly) — a purchase that would push the buyer's
//      spend within the window over the configured cap is blocked.
//
// Both read from ParentQuickControls via the fake ParentDashboardRepository
// in test_support.dart, and both exercise the real StudentRepository +
// fake_cloud_firestore transaction/points logic — not a reimplementation.

import 'package:edu_play/data/datasources/student_datasource.dart'
    show PurchaseResult;

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';
import 'package:edu_play/features/store/bloc/store_bloc.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'test_support.dart';

StoreItem _item(String id) => allStoreItems.firstWhere((i) => i.id == id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await sl.reset();
  });

  group('Parental approval required', () {
    test(
        'a purchase is held pending instead of completing, then the parent '
        'approving it grants the item and spends the points', () async {
      SharedPreferences.setMockInitialValues({'student_id': 'kid_approval'});
      final firestore = registerTestFakes(
        parentControls: const ParentQuickControls(requirePurchaseApproval: true),
      );
      await firestore.collection('students').doc('kid_approval').set({
        'name': 'Mia',
        'age': 8,
        'points': 200,
        'streak': 0,
      });

      final dashboardBloc = StudentDashboardBloc(age: 8, username: 'Mia');
      await settle(dashboardBloc);
      final storeBloc = StoreBloc(dashboardBloc: dashboardBloc);
      final item = _item('avatar_color_ruby'); // cost 40

      expect(dashboardBloc.requiresPurchaseApproval, isTrue);

      final outcome = await storeBloc.purchase(item);

      expect(outcome, PurchaseOutcome.pendingApproval);
      expect(dashboardBloc.pendingPurchaseItemIds, contains(item.id));
      expect(dashboardBloc.ownedItemIds.contains(item.id), isFalse);
      expect(dashboardBloc.points, 200); // untouched until approved

      // Parent-side action (mirrors ParentPurchaseApprovalsCard._approve).
      final result = await sl<StudentRepository>().approvePendingPurchase(
        studentId: 'kid_approval',
        itemId: item.id,
        itemName: item.name,
      );
      expect(result, PurchaseResult.success);

      await dashboardBloc.refresh();
      expect(dashboardBloc.ownedItemIds.contains(item.id), isTrue);
      expect(dashboardBloc.pendingPurchaseItemIds.contains(item.id), isFalse);
      expect(dashboardBloc.points, 200 - item.cost);

      storeBloc.dispose();
      dashboardBloc.dispose();
    });

    test('rejecting a pending request clears it without spending points',
        () async {
      SharedPreferences.setMockInitialValues({'student_id': 'kid_reject'});
      final firestore = registerTestFakes(
        parentControls: const ParentQuickControls(requirePurchaseApproval: true),
      );
      await firestore.collection('students').doc('kid_reject').set({
        'name': 'Leo',
        'age': 8,
        'points': 200,
        'streak': 0,
      });

      final dashboardBloc = StudentDashboardBloc(age: 8, username: 'Leo');
      await settle(dashboardBloc);
      final storeBloc = StoreBloc(dashboardBloc: dashboardBloc);
      final item = _item('avatar_color_emerald');

      await storeBloc.purchase(item);
      expect(dashboardBloc.pendingPurchaseItemIds, contains(item.id));

      await sl<StudentRepository>()
          .rejectPendingPurchase(studentId: 'kid_reject', itemId: item.id);
      await dashboardBloc.refresh();

      expect(dashboardBloc.pendingPurchaseItemIds.contains(item.id), isFalse);
      expect(dashboardBloc.ownedItemIds.contains(item.id), isFalse);
      expect(dashboardBloc.points, 200);

      storeBloc.dispose();
      dashboardBloc.dispose();
    });
  });

  group('Parent-configured spend limit', () {
    test('a purchase within the remaining window budget succeeds', () async {
      SharedPreferences.setMockInitialValues({'student_id': 'kid_spend_ok'});
      final firestore = registerTestFakes(
        parentControls: const ParentQuickControls(
          spendLimitEnabled: true,
          spendLimitAmount: 50,
          spendLimitPeriod: SpendLimitPeriod.daily,
        ),
      );
      await firestore.collection('students').doc('kid_spend_ok').set({
        'name': 'Nico',
        'age': 8,
        'points': 1000,
        'streak': 0,
      });

      final dashboardBloc = StudentDashboardBloc(age: 8, username: 'Nico');
      await settle(dashboardBloc);
      final storeBloc = StoreBloc(dashboardBloc: dashboardBloc);
      final item = _item('avatar_color_ruby'); // cost 40, under the 50 cap

      expect(dashboardBloc.spendLimitEnabled, isTrue);
      expect(storeBloc.wouldExceedSpendLimit(item), isFalse);

      final outcome = await storeBloc.purchase(item);

      expect(outcome, PurchaseOutcome.success);
      expect(dashboardBloc.spentInWindow, 40);

      storeBloc.dispose();
      dashboardBloc.dispose();
    });

    test(
        'a purchase that would push spend within the window over the limit '
        'is blocked, even though the student can afford it', () async {
      SharedPreferences.setMockInitialValues({'student_id': 'kid_spend_over'});
      final firestore = registerTestFakes(
        parentControls: const ParentQuickControls(
          spendLimitEnabled: true,
          spendLimitAmount: 50,
          spendLimitPeriod: SpendLimitPeriod.daily,
        ),
      );
      await firestore.collection('students').doc('kid_spend_over').set({
        'name': 'Ona',
        'age': 8,
        'points': 1000,
        'streak': 0,
      });

      final dashboardBloc = StudentDashboardBloc(age: 8, username: 'Ona');
      await settle(dashboardBloc);
      final storeBloc = StoreBloc(dashboardBloc: dashboardBloc);
      final ruby = _item('avatar_color_ruby'); // cost 40
      final emerald = _item('avatar_color_emerald'); // cost 40 → 80 total

      expect(await storeBloc.purchase(ruby), PurchaseOutcome.success);
      await dashboardBloc.refresh();
      expect(dashboardBloc.spentInWindow, 40);

      expect(storeBloc.wouldExceedSpendLimit(emerald), isTrue);
      final outcome = await storeBloc.purchase(emerald);

      expect(outcome, PurchaseOutcome.failed);
      expect(storeBloc.lastError, contains('límite'));
      expect(dashboardBloc.ownedItemIds.contains(emerald.id), isFalse);
      // Only the first purchase's cost was ever deducted.
      expect(dashboardBloc.points, 1000 - ruby.cost);

      storeBloc.dispose();
      dashboardBloc.dispose();
    });
  });
}
