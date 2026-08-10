import 'package:edu_play/features/subscription/data/datasources/checkout_datasource.dart';
import 'package:edu_play/features/subscription/domain/repositories/checkout_repository.dart';

class FirebaseCheckoutRepository implements CheckoutRepository {
  const FirebaseCheckoutRepository({required this.datasource});

  final CheckoutDatasource datasource;

  @override
  Future<String> createCheckoutSessionUrl() {
    return datasource.createCheckoutSessionUrl();
  }
}
