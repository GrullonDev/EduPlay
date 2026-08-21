// Project imports:
import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';

abstract class ParentDashboardRepository {
  Future<ParentQuickControls> getQuickControls();

  /// Reads the quick controls for a specific parent [uid], regardless of
  /// which account is currently signed in. Used by a child's own dashboard
  /// (signed in as the parent on a shared device) to check whether *their*
  /// parent requires purchase approval — mirrors
  /// `SubscriptionRepository.getSubscriptionForUser`.
  Future<ParentQuickControls> getQuickControlsForUser(String uid);

  Future<void> saveQuickControls(ParentQuickControls controls);
}
