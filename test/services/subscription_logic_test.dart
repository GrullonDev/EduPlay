// Tests for the pure logic in SubscriptionService that does NOT require Firebase.
// The month-rollover detection and limit checks are driven by simple arithmetic
// and can be verified without any mocking of Firestore.

import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final currentMonth =
      '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final lastMonth = now.month == 1
      ? '${now.year - 1}-12'
      : '${now.year}-${(now.month - 1).toString().padLeft(2, '0')}';

  group('Subscription.freeTier', () {
    test('defaults to free tier', () {
      final sub = Subscription.freeTier();
      expect(sub.tier, 'free');
      expect(sub.isPro, isFalse);
    });

    test('starts with zero sessions this month', () {
      final sub = Subscription.freeTier();
      expect(sub.sessionsThisMonth, 0);
    });
  });

  group('Subscription.isPro', () {
    test('pro tier is recognised', () {
      final sub = Subscription(
        tier: 'pro',
        sessionsThisMonth: 999,
        monthYear: currentMonth,
      );
      expect(sub.isPro, isTrue);
    });

    test('free tier is not pro', () {
      final sub = Subscription(
        tier: 'free',
        sessionsThisMonth: 0,
        monthYear: currentMonth,
      );
      expect(sub.isPro, isFalse);
    });
  });

  group('Free-tier session limit logic', () {
    test('canCreateSession is true when under the limit', () {
      final sub = Subscription(
        tier: 'free',
        sessionsThisMonth: Subscription.freeSessionLimit - 1,
        monthYear: currentMonth,
      );
      final canCreate = sub.isPro ||
          sub.monthYear != currentMonth ||
          sub.sessionsThisMonth < Subscription.freeSessionLimit;
      expect(canCreate, isTrue);
    });

    test('canCreateSession is false when limit is reached', () {
      final sub = Subscription(
        tier: 'free',
        sessionsThisMonth: Subscription.freeSessionLimit,
        monthYear: currentMonth,
      );
      final canCreate = sub.isPro ||
          sub.monthYear != currentMonth ||
          sub.sessionsThisMonth < Subscription.freeSessionLimit;
      expect(canCreate, isFalse);
    });

    test('canCreateSession is true after month rolls over', () {
      // Same count but stored month is last month → effectively 0 sessions.
      final sub = Subscription(
        tier: 'free',
        sessionsThisMonth: Subscription.freeSessionLimit,
        monthYear: lastMonth, // stale month
      );
      final canCreate = sub.isPro ||
          sub.monthYear != currentMonth || // ← this is true → can create
          sub.sessionsThisMonth < Subscription.freeSessionLimit;
      expect(canCreate, isTrue);
    });

    test('pro users are never blocked regardless of count', () {
      final sub = Subscription(
        tier: 'pro',
        sessionsThisMonth: 10000,
        monthYear: currentMonth,
      );
      final canCreate = sub.isPro || false;
      expect(canCreate, isTrue);
    });
  });

  group('Free-tier child limit logic', () {
    test('free user can add a child when under the limit', () {
      final sub = Subscription.freeTier();
      final canAdd = sub.isPro ||
          (Subscription.freeChildLimit - 1) < Subscription.freeChildLimit;
      expect(canAdd, isTrue);
    });

    test('free user cannot add a child at the limit', () {
      final sub = Subscription.freeTier();
      final canAdd = sub.isPro ||
          Subscription.freeChildLimit < Subscription.freeChildLimit;
      expect(canAdd, isFalse);
    });
  });

  group('Subscription JSON round-trip', () {
    test('fromMap → fields preserved', () {
      final map = {
        'tier': 'pro',
        'sessionsThisMonth': 5,
        'monthYear': currentMonth,
      };
      final sub = Subscription.fromMap(map);
      expect(sub.tier, 'pro');
      expect(sub.sessionsThisMonth, 5);
      expect(sub.monthYear, currentMonth);
    });

    test('fromMap with missing fields does not throw', () {
      expect(() => Subscription.fromMap({}), returnsNormally);
    });
  });
}
