// Tests for FirestoreSubscriptionRepository.cancelSubscription — the
// pro→free downgrade path. The repository is a thin pass-through to the
// datasource (mirroring initSubscription/incrementSessionCount above it),
// so this verifies the delegation and that a datasource failure surfaces
// rather than being swallowed. The actual Cloud Function call lives in
// FirestoreSubscriptionDatasource and is intentionally not exercised here —
// there's no fake/mock for cloud_functions in this project's dev
// dependencies, and the client can't write `tier` itself (blocked in
// firestore.rules), so that call is only meaningfully testable against a
// real or emulated Cloud Function.

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/features/subscription/data/datasources/subscription_datasource.dart';
import 'package:edu_play/features/subscription/data/repositories/firestore_subscription_repository.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';

class _FakeSubscriptionDatasource implements SubscriptionDatasource {
  _FakeSubscriptionDatasource({this.tier = 'pro'});

  String tier;
  int cancelCallCount = 0;
  Object? cancelError;

  @override
  Future<Subscription> getSubscription() async => Subscription(
        tier: tier,
        sessionsThisMonth: 0,
        monthYear: '2026-09',
      );

  @override
  Future<Subscription> getSubscriptionForUser(String uid) => getSubscription();

  @override
  Stream<Subscription> watchSubscription() =>
      Stream.fromFuture(getSubscription());

  @override
  Future<void> initSubscription(String uid) async {}

  @override
  Future<void> incrementSessionCount() async {}

  @override
  Future<void> cancelSubscription() async {
    cancelCallCount++;
    final error = cancelError;
    if (error != null) throw error;
    tier = 'free';
  }
}

void main() {
  group('FirestoreSubscriptionRepository.cancelSubscription', () {
    test('delegates to the datasource exactly once', () async {
      final datasource = _FakeSubscriptionDatasource(tier: 'pro');
      final repository =
          FirestoreSubscriptionRepository(datasource: datasource);

      await repository.cancelSubscription();

      expect(datasource.cancelCallCount, 1);
    });

    test('leaves the caller-visible tier as free after cancelling', () async {
      final datasource = _FakeSubscriptionDatasource(tier: 'pro');
      final repository =
          FirestoreSubscriptionRepository(datasource: datasource);

      await repository.cancelSubscription();
      final sub = await repository.getSubscription();

      expect(sub.tier, 'free');
      expect(sub.isPro, isFalse);
    });

    test('propagates datasource/Cloud Function failures to the caller',
        () async {
      final datasource = _FakeSubscriptionDatasource(tier: 'pro')
        ..cancelError = Exception('cancelRecurrenteSubscription failed');
      final repository =
          FirestoreSubscriptionRepository(datasource: datasource);

      expect(
        () => repository.cancelSubscription(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
