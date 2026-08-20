// Project imports:
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Compatibility facade for subscription use cases.
///
/// Firebase access lives in `data/datasources`; new code should depend on
/// [SubscriptionRepository] directly through dependency injection.
class SubscriptionService {
  static SubscriptionRepository get _repository => sl<SubscriptionRepository>();

  static Future<Subscription> getSubscription() {
    return _repository.getSubscription();
  }

  static Stream<Subscription> watchSubscription() {
    return _repository.watchSubscription();
  }

  static Future<void> initSubscription(String uid) {
    return _repository.initSubscription(uid);
  }

  static Future<void> incrementSessionCount() {
    return _repository.incrementSessionCount();
  }

  static Future<bool> canAddChild(int currentChildCount) {
    return _repository.canAddChild(currentChildCount);
  }

  static Future<bool> canCreateSession() {
    return _repository.canCreateSession();
  }
}
