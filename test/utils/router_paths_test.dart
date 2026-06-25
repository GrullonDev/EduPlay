// Ensures all RouterPaths constants are unique — duplicate route strings would
// cause silent navigation bugs that are hard to trace at runtime.

import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Collect all route strings via reflection-free manual list.
  // Update this list whenever a new route is added to RouterPaths.
  final allRoutes = [
    RouterPaths.root,
    RouterPaths.landing,
    RouterPaths.login,
    RouterPaths.registerParents,
    RouterPaths.registerTeacher,
    RouterPaths.registerChild,
    RouterPaths.menu,
    RouterPaths.mathAdventure,
    RouterPaths.magicWords,
    RouterPaths.funEnglish,
    RouterPaths.notFound,
    RouterPaths.guestEntry,
    RouterPaths.studentDashboard,
    RouterPaths.parentsDashboard,
    RouterPaths.teacherDashboard,
    RouterPaths.natureExplorers,
    RouterPaths.timeTravel,
    RouterPaths.treasureMap,
    RouterPaths.artistsInAction,
    RouterPaths.colorConcert,
    RouterPaths.sportsChallenge,
    RouterPaths.stickerAlbum,
    RouterPaths.gamesCatalog,
    RouterPaths.childPin,
    RouterPaths.parentGuide,
    RouterPaths.settings,
    RouterPaths.progressReports,
    RouterPaths.createExplorer,
    RouterPaths.createSession,
    RouterPaths.practiceSession,
    RouterPaths.practiceKiosk,
    RouterPaths.childPortal,
    RouterPaths.joinClass,
    RouterPaths.adminDashboard,
    RouterPaths.privacyPolicy,
    RouterPaths.termsOfService,
    RouterPaths.browseTeachers,
  ];

  test('all route strings are non-empty', () {
    for (final route in allRoutes) {
      expect(route, isNotEmpty, reason: 'A RouterPaths constant is empty');
    }
  });

  test('no two route strings are identical', () {
    final seen = <String>{};
    for (final route in allRoutes) {
      expect(seen.contains(route), isFalse,
          reason: 'Duplicate route string detected: "$route"');
      seen.add(route);
    }
  });

  test('slash-prefixed routes start with /', () {
    // Not all routes use a leading slash (some are simple string names),
    // but the canonical slash-prefixed ones should all be consistent.
    final slashRoutes = allRoutes.where((r) => r.startsWith('/'));
    for (final route in slashRoutes) {
      expect(route.startsWith('/'), isTrue);
      // Should not have double slashes
      expect(route.contains('//'), isFalse,
          reason: 'Route "$route" has a double slash');
    }
  });
}
