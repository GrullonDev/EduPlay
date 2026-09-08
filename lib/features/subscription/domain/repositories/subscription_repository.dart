// Project imports:
import 'package:edu_play/features/subscription/models/subscription.dart';

abstract class SubscriptionRepository {
  Future<Subscription> getSubscription();

  Future<Subscription> getSubscriptionForUser(String uid);

  Stream<Subscription> watchSubscription();

  Future<void> initSubscription(String uid);

  Future<void> incrementSessionCount();

  Future<bool> canAddChild(int currentChildCount);

  Future<bool> canCreateSession();

  /// Downgrades the caller's own subscription from 'pro' back to 'free' via
  /// the `cancelRecurrenteSubscription` Cloud Function. The client can never
  /// write `tier` itself (blocked in firestore.rules), so this always goes
  /// through the backend.
  Future<void> cancelSubscription();
}
