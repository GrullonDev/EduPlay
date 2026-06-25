import 'package:flutter/foundation.dart';

/// Lightweight analytics service for EduPlay.
///
/// Currently logs route changes and events to the debug console.
/// To add Firebase Analytics in future:
///   1. Add `firebase_analytics` to pubspec.yaml.
///   2. Replace the `debugPrint` calls with FirebaseAnalytics.instance calls.
///
/// Usage — route tracking (wired into AppRouter.generateRoute):
///   AnalyticsService.logRouteChange('/student-dashboard');
///
/// Usage — custom events:
///   AnalyticsService.logEvent('enroll_class', params: {'classId': id});
class AnalyticsService {
  AnalyticsService._();

  // ── Route tracking ────────────────────────────────────────────────────────

  /// Called every time the app navigates to a named route.
  static void logRouteChange(String routeName, {String? previousRoute}) {
    if (!kDebugMode) return; // swap for FirebaseAnalytics in production
    debugPrint(
      '[Analytics] screen: $routeName'
      '${previousRoute != null ? ' (from: $previousRoute)' : ''}',
    );
    // TODO: replace with Firebase Analytics when the package is added:
    // await FirebaseAnalytics.instance.logScreenView(screenName: routeName);
  }

  // ── Custom events ─────────────────────────────────────────────────────────

  /// Log a custom event with optional string parameters.
  static void logEvent(
    String name, {
    Map<String, String> params = const {},
  }) {
    if (!kDebugMode) return;
    final paramsStr = params.isEmpty ? '' : ' ${params.toString()}';
    debugPrint('[Analytics] event: $name$paramsStr');
    // TODO: await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
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
}
