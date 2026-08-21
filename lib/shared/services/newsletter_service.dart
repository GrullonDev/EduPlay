// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

/// Captures newsletter sign-ups from public, unauthenticated marketing pages
/// (parent guide, registration landing) into a write-only Firestore
/// collection. There is no reader in the app for this data — it's meant to
/// be exported/reviewed from the Firebase console.
class NewsletterService {
  const NewsletterService._();

  static FirebaseFirestore? _firestoreForTest;
  static FirebaseFirestore get _db =>
      _firestoreForTest ?? FirebaseFirestore.instance;

  @visibleForTesting
  static void useInstanceForTest(FirebaseFirestore firestore) {
    _firestoreForTest = firestore;
  }

  static Future<void> subscribe({
    required String email,
    required String source,
  }) async {
    await _db.collection('newsletter_subscribers').add({
      'email': email,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
