/// Result of starting a Recurrente checkout: what
/// [RecurrenteCheckoutScreen](../../presentation/screens/recurrente_checkout_screen.dart)
/// needs to open the payment page and track the matching `orders/{orderId}`
/// Firestore document.
class PaymentCheckout {
  const PaymentCheckout({
    required this.checkoutUrl,
    required this.checkoutId,
    required this.orderId,
  });

  final String checkoutUrl;
  final String checkoutId;
  final String orderId;
}
