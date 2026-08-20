// Project imports:
import 'package:edu_play/features/payments/domain/entities/payment_checkout.dart';
import 'package:edu_play/features/payments/domain/repositories/recurrente_repository.dart';

class CreateRecurrenteCheckoutUseCase {
  const CreateRecurrenteCheckoutUseCase(this._repository);

  final RecurrenteRepository _repository;

  Future<PaymentCheckout> call({
    required double amount,
    required String orderId,
    required String userEmail,
    required String itemName,
    String currency = 'GTQ',
    Map<String, dynamic> metadata = const {},
  }) {
    return _repository.createCheckout(
      amount: amount,
      orderId: orderId,
      userEmail: userEmail,
      itemName: itemName,
      currency: currency,
      metadata: metadata,
    );
  }
}
