import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_play/utils/routes/router_paths.dart';

/// Keeps the child-facing navigation flow independent from individual games.
///
/// Games should call [returnAfterGameOver] instead of routing directly to the
/// dashboard. That lets the app preserve the PIN-authenticated child context
/// when one exists, or fall back to the guest games screen without logging the
/// current Firebase session out.
class StudentSessionNavigationService {
  StudentSessionNavigationService._();

  static const childPinKey = 'edu_play_child_pin';

  static Future<void> rememberChildPin(String pin) async {
    if (pin.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(childPinKey, pin);
  }

  static Future<void> clearChildPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(childPinKey);
  }

  static Future<bool> hasRememberedChildPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(childPinKey);
    return pin != null && pin.isNotEmpty;
  }

  static Future<void> returnAfterGameOver(
    BuildContext context, {
    bool dismissCurrentRoute = true,
  }) async {
    final navigator = Navigator.of(context);
    if (dismissCurrentRoute && navigator.canPop()) {
      navigator.pop();
    }

    final hasPin = await hasRememberedChildPin();
    if (!navigator.context.mounted) return;

    navigator.pushNamedAndRemoveUntil(
      hasPin ? RouterPaths.studentDashboard : RouterPaths.gamesCatalog,
      (route) => false,
    );
  }

  static void goToAdultRegistration(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouterPaths.registerParents,
      (route) => false,
    );
  }
}
