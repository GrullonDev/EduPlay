// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;

// Project imports:
import 'package:edu_play/core/config/app_urls.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

String childPortalUrl(ChildProfile profile) {
  final origin = kIsWeb ? Uri.base.origin : AppUrls.webBase;
  final encoded = base64Url.encode(utf8.encode(jsonEncode(profile.toJson())));
  return '$origin/#/student-dashboard?pin=${profile.pin}&d=$encoded';
}

ChildProfile? childProfileFromUrl() {
  if (!kIsWeb) return null;
  try {
    final fragment = Uri.base.fragment;
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
