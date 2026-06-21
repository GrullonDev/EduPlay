import 'package:cloud_functions/cloud_functions.dart';
import 'stripe_service_web.dart' if (dart.library.io) 'stripe_service_stub.dart'
    as launcher;

/// Calls `createStripeCheckoutSession` Cloud Function and opens the Stripe
/// Checkout URL in a new browser tab.
class StripeService {
  static Future<void> startCheckout() async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('createStripeCheckoutSession');

    final result = await callable.call<Map<String, dynamic>>({});
    final sessionUrl = result.data['sessionUrl'] as String?;

    if (sessionUrl == null || sessionUrl.isEmpty) {
      throw Exception('No sessionUrl returned from Cloud Function.');
    }

    launcher.openUrl(sessionUrl);
  }
}
