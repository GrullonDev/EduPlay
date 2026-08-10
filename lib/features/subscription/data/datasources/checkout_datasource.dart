import 'package:cloud_functions/cloud_functions.dart';

abstract class CheckoutDatasource {
  Future<String> createCheckoutSessionUrl();
}

class FirebaseCheckoutDatasource implements CheckoutDatasource {
  FirebaseCheckoutDatasource({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<String> createCheckoutSessionUrl() async {
    final callable = _functions.httpsCallable('createStripeCheckoutSession');
    final result = await callable.call<Map<String, dynamic>>({});
    final sessionUrl = result.data['sessionUrl'] as String?;
    if (sessionUrl == null || sessionUrl.isEmpty) {
      throw Exception('No sessionUrl returned from Cloud Function.');
    }
    return sessionUrl;
  }
}
