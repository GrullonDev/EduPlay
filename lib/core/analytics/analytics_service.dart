// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

/// Lightweight analytics service for EduPlay.
///
/// Every call is fire-and-forget from the caller's point of view (no
/// `await` at most call sites) and must never throw or hang a test:
///   - [Firebase.apps] is checked before touching [FirebaseAnalytics] —
///     unit/widget tests don't call `Firebase.initializeApp()`, so there is
///     no default app and a raw `FirebaseAnalytics.instance` call would
///     throw `[core/no-app]`. When no app is registered, calls become a
///     no-op (console logging in debug mode still happens).
///   - Any remaining Firebase error (offline, disabled collection, …) is
///     caught and logged rather than propagated, since analytics failing
///     must never break the feature that triggered it.
///
/// Usage — route tracking (wired into AppRouter.generateRoute):
///   AnalyticsService.logRouteChange('/student-dashboard');
///
/// Usage — custom events:
///   AnalyticsService.logEvent('enroll_class', params: {'classId': id});
class AnalyticsService {
  AnalyticsService._();

  /// True once a Firebase app is registered (real app, or a test that set
  /// one up with `firebase_core_platform_interface`'s test bindings). False
  /// in a plain `flutter test` run, where sending would throw.
  static bool get _firebaseReady => Firebase.apps.isNotEmpty;

  static Future<void> _send(Future<void> Function() call) async {
    if (!_firebaseReady) return;
    try {
      await call();
    } catch (e) {
      debugPrint('AnalyticsService error: $e');
    }
  }

  // ── Route tracking ────────────────────────────────────────────────────────

  /// Called every time the app navigates to a named route.
  static Future<void> logRouteChange(String routeName,
      {String? previousRoute}) async {
    if (kDebugMode) {
      debugPrint(
        '[Analytics] screen: $routeName'
        '${previousRoute != null ? ' (from: $previousRoute)' : ''}',
      );
    }
    await _send(
      () => FirebaseAnalytics.instance.logScreenView(screenName: routeName),
    );
  }

  // ── Custom events ─────────────────────────────────────────────────────────

  /// Log a custom event with optional string parameters.
  static Future<void> logEvent(
    String name, {
    Map<String, String> params = const {},
  }) async {
    if (kDebugMode) {
      final paramsStr = params.isEmpty ? '' : ' ${params.toString()}';
      debugPrint('[Analytics] event: $name$paramsStr');
    }
    await _send(
      () => FirebaseAnalytics.instance.logEvent(name: name, parameters: params),
    );
  }

  // ── Auth events ───────────────────────────────────────────────────────────

  static void logLogin(String method) =>
      logEvent('login', params: {'method': method});

  static void logSignUp(String role) =>
      logEvent('sign_up', params: {'role': role});

  static void logLogout() => logEvent('logout');

  // ── Gamification events ───────────────────────────────────────────────────

  static void logGameStart(String gameId) =>
      logEvent('game_start', params: {'game_id': gameId});

  static void logGameComplete(String gameId, {int? score}) =>
      logEvent('game_complete', params: {
        'game_id': gameId,
        if (score != null) 'score': score.toString(),
      });

  static void logChallengeComplete(String challengeId) =>
      logEvent('challenge_complete', params: {'challenge_id': challengeId});

  // ── Enrollment events ─────────────────────────────────────────────────────

  static void logClassEnroll(String classId) =>
      logEvent('class_enroll', params: {'class_id': classId});

  // ── Subscription events ───────────────────────────────────────────────────

  static void logUpgradePrompt(String source) =>
      logEvent('upgrade_prompt_shown', params: {'source': source});

  // ── Store (Tienda) events ─────────────────────────────────────────────────

  static void logStoreView() => logEvent('store_view');

  static void logStorePurchaseSuccess(String itemId, {required bool pending}) =>
      logEvent('store_purchase_success', params: {
        'item_id': itemId,
        'pending': pending.toString(),
      });

  static void logStorePurchaseBlocked(String itemId, String reason) =>
      logEvent('store_purchase_blocked', params: {
        'item_id': itemId,
        'reason': reason,
      });

  static void logStoreProAttempt(String itemId) =>
      logEvent('store_pro_attempt', params: {'item_id': itemId});

  static void logStoreGuestLimitReached() =>
      logEvent('store_guest_limit_reached');
}
