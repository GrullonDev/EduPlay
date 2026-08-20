// Project imports:
import 'package:edu_play/features/subscription/domain/repositories/checkout_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

import 'stripe_service_web.dart' if (dart.library.io) 'stripe_service_stub.dart'
    as launcher;

/// Calls `createStripeCheckoutSession` Cloud Function and opens the Stripe
/// Checkout URL in a new browser tab.
class StripeService {
  static Future<void> startCheckout() async {
    final sessionUrl =
        await sl<CheckoutRepository>().createCheckoutSessionUrl();
    launcher.openUrl(sessionUrl);
  }
}
