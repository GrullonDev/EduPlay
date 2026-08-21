// Flutter imports:
import 'package:flutter/foundation.dart' show kDebugMode;

// Package imports:
import 'package:cloud_functions/cloud_functions.dart';

// Project imports:
import 'package:edu_play/features/payments/domain/entities/payment_checkout.dart';

abstract class RecurrenteDatasource {
  Future<PaymentCheckout> createCheckout({
    required double amount,
    required String orderId,
    required String userEmail,
    required String itemName,
    String currency = 'GTQ',
    Map<String, dynamic> metadata = const {},
  });
}

class FirebaseRecurrenteDatasource implements RecurrenteDatasource {
  FirebaseRecurrenteDatasource({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<PaymentCheckout> createCheckout({
    required double amount,
    required String orderId,
    required String userEmail,
    required String itemName,
    String currency = 'GTQ',
    Map<String, dynamic> metadata = const {},
  }) async {
    final callable = _functions.httpsCallable('createRecurrenteCheckout');
    final result = await callable.call<Map<String, dynamic>>({
      'amount': amount,
      'orderId': orderId,
      'userEmail': userEmail,
      'itemName': itemName,
      'currency': currency,
      'metadata': metadata,
      'isTest': kDebugMode,
    });

    final data = result.data;
    final checkoutUrl = data['checkoutUrl'] as String?;
    final checkoutId = data['checkoutId'] as String?;
    if (data['success'] != true || checkoutUrl == null || checkoutUrl.isEmpty) {
      throw Exception('No se pudo iniciar el pago con Recurrente.');
    }

    return PaymentCheckout(
      checkoutUrl: checkoutUrl,
      checkoutId: checkoutId ?? '',
      orderId: orderId,
    );
  }
}
