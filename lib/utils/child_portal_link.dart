import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

/// Generates the shareable link for [profile] straight to the student
/// dashboard (the consolidated "Panel de Control" screen).
///
/// The profile data is base64url-encoded and embedded as the `d=` query
/// parameter so the dashboard can render immediately — without any
/// Firestore query or Firebase authentication — on any device.
///
/// Format: `{origin}/#studentDashboard?pin={pin}&d={base64Profile}`
///
/// Old links of the form `/#/child-portal?...` still work — `childPortal`
/// stays registered as a route alias, and this parsing logic (below) reads
/// straight from the URL fragment regardless of which route name matched.
String childPortalUrl(ChildProfile profile) {
  final origin = kIsWeb ? Uri.base.origin : 'http://localhost:3000';
  final encoded = base64Url.encode(utf8.encode(jsonEncode(profile.toJson())));
  return '$origin/#studentDashboard?pin=${profile.pin}&d=$encoded';
}

/// Parses a [ChildProfile] from the `d=` query parameter embedded in the
/// current page URL (Flutter web hash routing).
///
/// Returns `null` if the parameter is absent or the data cannot be decoded.
ChildProfile? childProfileFromUrl() {
  if (!kIsWeb) return null;
  try {
    final fragment = Uri.base.fragment; // e.g. "/child-portal?pin=1234&d=..."
    final qIdx = fragment.indexOf('?');
    if (qIdx == -1) return null;
    final params = Uri.splitQueryString(fragment.substring(qIdx + 1));
    final data = params['d'];
    if (data == null || data.isEmpty) return null;
    final json =
        jsonDecode(utf8.decode(base64Url.decode(data))) as Map<String, dynamic>;
    return ChildProfile.fromJson(json);
  } catch (_) {
    return null;
  }
}

/// Parses just the PIN from the current URL fragment.
String? pinFromUrl() {
  if (!kIsWeb) return null;
  try {
    final fragment = Uri.base.fragment;
    final qIdx = fragment.indexOf('?');
    if (qIdx == -1) return null;
    final params = Uri.splitQueryString(fragment.substring(qIdx + 1));
    return params['pin'];
  } catch (_) {
    return null;
  }
}
