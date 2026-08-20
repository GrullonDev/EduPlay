// Project imports:
import 'package:edu_play/features/payments/data/datasources/recurrente_datasource.dart';
import 'package:edu_play/features/payments/domain/entities/payment_checkout.dart';
import 'package:edu_play/features/payments/domain/repositories/recurrente_repository.dart';

class RecurrenteRepositoryImpl implements RecurrenteRepository {
  const RecurrenteRepositoryImpl({required this.datasource});

  final RecurrenteDatasource datasource;

  @override
  Future<PaymentCheckout> createCheckout({
    required double amount,
    required String orderId,
    required String userEmail,
    required String itemName,
    String currency = 'GTQ',
    Map<String, dynamic> metadata = const {},
  }) {
    return datasource.createCheckout(
      amount: amount,
      orderId: orderId,
      userEmail: userEmail,
      itemName: itemName,
      currency: currency,
      metadata: metadata,
    );
  }
}
