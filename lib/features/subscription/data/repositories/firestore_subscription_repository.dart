import 'package:edu_play/features/subscription/data/datasources/subscription_datasource.dart';
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';

class FirestoreSubscriptionRepository implements SubscriptionRepository {
  const FirestoreSubscriptionRepository({required this.datasource});

  final SubscriptionDatasource datasource;

  @override
  Future<Subscription> getSubscription() {
    return datasource.getSubscription();
  }

  @override
  Future<Subscription> getSubscriptionForUser(String uid) {
    return datasource.getSubscriptionForUser(uid);
  }

  @override
  Stream<Subscription> watchSubscription() {
    return datasource.watchSubscription();
  }

  @override
  Future<void> initSubscription(String uid) {
    return datasource.initSubscription(uid);
  }

  @override
  Future<void> incrementSessionCount() {
    return datasource.incrementSessionCount();
  }

  @override
  Future<bool> canAddChild(int currentChildCount) async {
    final sub = await getSubscription();
    if (sub.isPro) return true;
    return currentChildCount < Subscription.freeChildLimit;
  }

  @override
  Future<bool> canCreateSession() async {
    final sub = await getSubscription();
    if (sub.isPro) return true;

    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    if (sub.monthYear != currentMonth) return true;

    return sub.sessionsThisMonth < Subscription.freeSessionLimit;
  }
}
