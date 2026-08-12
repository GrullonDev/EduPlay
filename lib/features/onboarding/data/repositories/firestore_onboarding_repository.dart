import 'package:edu_play/features/onboarding/data/datasources/onboarding_datasource.dart';
import 'package:edu_play/features/onboarding/domain/repositories/onboarding_repository.dart';

class FirestoreOnboardingRepository implements OnboardingRepository {
  const FirestoreOnboardingRepository({required this.datasource});

  final OnboardingDatasource datasource;

  @override
  Future<bool> shouldShowForCurrentParent() {
    return datasource.shouldShowForCurrentParent();
  }

  @override
  Future<void> markCurrentParentComplete() {
    return datasource.markCurrentParentComplete();
  }
}
