// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:edu_play/features/payments/domain/entities/payment_checkout.dart';
import 'package:edu_play/features/payments/domain/usecases/create_recurrente_checkout_usecase.dart';
import 'package:edu_play/utils/injection_container.dart';

enum RecurrentePaymentStatus {
  idle,
  loading,
  awaitingPayment,
  paid,
  cancelled,
  error
}

/// Drives the "start a Recurrente payment" step: calls
/// `createRecurrenteCheckout` and exposes the resulting [PaymentCheckout]
/// plus a real-time listener on `orders/{orderId}` for callers that want to
/// react to the PAID transition without pushing
/// [RecurrenteCheckoutScreen](../screens/recurrente_checkout_screen.dart)
/// (which keeps its own independent listener while it's on screen).
class RecurrentePaymentProvider extends ChangeNotifier {
  RecurrentePaymentProvider({
    CreateRecurrenteCheckoutUseCase? useCase,
    FirebaseFirestore? firestore,
  })  : _useCase = useCase ?? sl<CreateRecurrenteCheckoutUseCase>(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final CreateRecurrenteCheckoutUseCase _useCase;
  final FirebaseFirestore _firestore;

  RecurrentePaymentStatus status = RecurrentePaymentStatus.idle;
  PaymentCheckout? checkout;
  String? errorMessage;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _orderSubscription;

  bool get isLoading => status == RecurrentePaymentStatus.loading;

  Future<PaymentCheckout?> startCheckout({
    required double amount,
    required String orderId,
    required String userEmail,
    required String itemName,
    String currency = 'GTQ',
    Map<String, dynamic> metadata = const {},
  }) async {
    status = RecurrentePaymentStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _useCase(
        amount: amount,
        orderId: orderId,
        userEmail: userEmail,
        itemName: itemName,
        currency: currency,
        metadata: metadata,
      );
      checkout = result;
      status = RecurrentePaymentStatus.awaitingPayment;
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = e.toString();
      status = RecurrentePaymentStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Listens to `orders/{orderId}` in real time; [onPaid] fires once, the
  /// first time `status` transitions to `'PAID'`.
  void listenToOrder(String orderId, {required VoidCallback onPaid}) {
    _orderSubscription?.cancel();
    _orderSubscription = _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen((snapshot) {
      final orderStatus = snapshot.data()?['status'] as String?;
      if (orderStatus == 'PAID' && status != RecurrentePaymentStatus.paid) {
        status = RecurrentePaymentStatus.paid;
        notifyListeners();
        onPaid();
      }
    });
  }

  void markCancelled() {
    if (status == RecurrentePaymentStatus.paid) return;
    status = RecurrentePaymentStatus.cancelled;
    notifyListeners();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
