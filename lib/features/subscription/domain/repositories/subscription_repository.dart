import 'package:edu_play/features/subscription/models/subscription.dart';

abstract class SubscriptionRepository {
  Future<Subscription> getSubscription();

  Future<Subscription> getSubscriptionForUser(String uid);

  Stream<Subscription> watchSubscription();

  Future<void> initSubscription(String uid);

  Future<void> incrementSessionCount();

  Future<bool> canAddChild(int currentChildCount);

  Future<bool> canCreateSession();
}
