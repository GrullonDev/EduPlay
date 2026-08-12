abstract class OnboardingRepository {
  Future<bool> shouldShowForCurrentParent();
  Future<void> markCurrentParentComplete();
}
