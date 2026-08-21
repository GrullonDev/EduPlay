// Project imports:
import 'package:edu_play/features/payments/domain/entities/payment_checkout.dart';

abstract class RecurrenteRepository {
  /// Creates a Recurrente checkout link for [orderId] via the
  /// `createRecurrenteCheckout` Cloud Function. [amount] is a decimal value
  /// (e.g. `49.90`); the function converts it to cents.
  Future<PaymentCheckout> createCheckout({
    required double amount,
    required String orderId,
    required String userEmail,
    required String itemName,
    String currency = 'GTQ',
    Map<String, dynamic> metadata = const {},
  });
}
