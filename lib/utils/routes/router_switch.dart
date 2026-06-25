import 'package:edu_play/core/analytics/analytics_service.dart';
import 'package:edu_play/features/main/main_page.dart';
import 'package:edu_play/features/legal/pages/privacy_policy_page.dart';
import 'package:edu_play/features/legal/pages/terms_of_service_page.dart';
import 'package:edu_play/features/teacher_assignment/pages/browse_teachers_page.dart';
import 'package:edu_play/features/games_catalog/pages/games_catalog_page.dart';
import 'package:edu_play/features/child_pin/pages/child_pin_page.dart';
import 'package:edu_play/features/child_portal/pages/child_portal_page.dart';
import 'package:edu_play/features/teacher_dashboard/pages/join_class_page.dart';
import 'package:edu_play/features/admin/pages/admin_dashboard_page.dart';
import 'package:edu_play/features/parent_guide/pages/parent_guide_page.dart';
import 'package:edu_play/features/settings/pages/settings_page.dart';
import 'package:edu_play/features/progress_reports/pages/progress_reports_page.dart';
import 'package:edu_play/features/create_explorer/pages/create_explorer_page.dart';
import 'package:edu_play/features/practice_session/pages/create_session_page.dart';
import 'package:edu_play/features/practice_session/pages/session_entry_page.dart';
import 'package:edu_play/features/practice_session/pages/practice_kiosk_page.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:flutter/material.dart';

import 'package:edu_play/features/landing/pages/landing_page.dart';
import 'package:edu_play/features/login/pages/login_page.dart';
// import 'package:edu_play/features/login_main/login_page.dart';
import 'package:edu_play/features/magic_words/pages/magic_words_page.dart';
import 'package:edu_play/features/math_adventure/pages/math_adventure_page.dart';
import 'package:edu_play/features/student_dashboard/pages/student_dashboard_page.dart';
import 'package:edu_play/features/register_child/pages/register_child_page.dart';
import 'package:edu_play/features/register_parents/pages/register_parents_page.dart';
import 'package:edu_play/features/guest/pages/guest_entry_page.dart';
import 'package:edu_play/features/parents_dashboard/pages/parents_dashboard_page.dart';
import 'package:edu_play/features/teacher_dashboard/pages/teacher_dashboard_page.dart';
import 'package:edu_play/features/teacher_registration/pages/teacher_registration_page.dart';
import 'package:edu_play/features/fun_english/pages/fun_english_page.dart';
import 'package:edu_play/features/nature_explorers/pages/nature_explorers_page.dart';
import 'package:edu_play/features/time_travel/pages/time_travel_page.dart';
import 'package:edu_play/features/treasure_map/pages/treasure_map_page.dart';
import 'package:edu_play/features/artists_in_action/pages/artists_in_action_page.dart';
import 'package:edu_play/features/color_concert/pages/color_concert_page.dart';
import 'package:edu_play/features/sports_challenge/pages/sports_challenge_page.dart';
import 'package:edu_play/features/sticker_album/pages/sticker_album_page.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    // Flutter web passes the full hash fragment (e.g. "/child-portal?pin=xxx")
    // as the route name. Strip the query string so the switch matches correctly.
    // ChildPortalPage reads the pin/profile data from Uri.base.fragment itself.
    final rawName = settings.name ?? '';
    final String name = rawName.contains('?')
        ? rawName.substring(0, rawName.indexOf('?'))
        : rawName;

    switch (name) {
      case RouterPaths.root:
        page = const MainPage();
        break;
      case RouterPaths.landing:
        page = const LandingPage();
        break;
      case RouterPaths.login:
        final userType = settings.arguments as String?;
        page = LoginPage(userType: userType);
        break;
      case RouterPaths.registerParents:
        page = const RegisterParentsPage();
        break;
      case RouterPaths.registerTeacher:
        page = const TeacherRegistrationPage();
        break;
      case RouterPaths.registerChild:
        page = const RegisterChildPage();
        break;
      // Legacy alias kept for back-compat
      case RouterPaths.menu:
      case RouterPaths.studentDashboard:
        // Accepts either a ChildProfile (from PIN flow) or a plain String username
        final args = settings.arguments;
        if (args is ChildProfile) {
          page = StudentDashboardPage(username: args.name, childProfile: args);
        } else {
          page = StudentDashboardPage(username: args as String?);
        }
        break;
      case RouterPaths.childPin:
        return MaterialPageRoute(builder: (_) => const ChildPinPage());

      case RouterPaths.mathAdventure:
        final userName = settings.arguments as String?;
        page = MathAdventurePage(userName: userName);
        break;
      case RouterPaths.magicWords:
        return MaterialPageRoute(
          builder: (_) => const MagicWordsPage(),
        );
      case RouterPaths.guestEntry:
        return MaterialPageRoute(
          builder: (_) => const GuestEntryPage(),
        );
      case RouterPaths.funEnglish:
        return MaterialPageRoute(
          builder: (_) => const FunEnglishPage(),
        );
      case RouterPaths.natureExplorers:
        return MaterialPageRoute(
          builder: (_) => const NatureExplorersPage(),
        );
      case RouterPaths.timeTravel:
        return MaterialPageRoute(
          builder: (_) => const TimeTravelPage(),
        );
      case RouterPaths.treasureMap:
        return MaterialPageRoute(
          builder: (_) => const TreasureMapPage(),
        );
      case RouterPaths.artistsInAction:
        return MaterialPageRoute(
          builder: (_) => const ArtistsInActionPage(),
        );
      case RouterPaths.colorConcert:
        return MaterialPageRoute(
          builder: (_) => const ColorConcertPage(),
        );
      case RouterPaths.sportsChallenge:
        return MaterialPageRoute(
          builder: (_) => const SportsChallengePage(),
        );
      case RouterPaths.stickerAlbum:
        return MaterialPageRoute(
          builder: (_) => const StickerAlbumPage(),
        );
      case RouterPaths.gamesCatalog:
        final catalogProfile = settings.arguments is ChildProfile
            ? settings.arguments as ChildProfile
            : null;
        return MaterialPageRoute(
          builder: (_) => GamesCatalogPage(childProfile: catalogProfile),
        );
      case RouterPaths.parentsDashboard:
        return MaterialPageRoute(
          builder: (_) => const ParentsDashboardPage(),
        );
      case RouterPaths.teacherDashboard:
        return MaterialPageRoute(
          builder: (_) => const TeacherDashboardPage(),
        );
      case RouterPaths.parentGuide:
        return MaterialPageRoute(
          builder: (_) => const ParentGuidePage(),
        );
      case RouterPaths.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      case RouterPaths.progressReports:
        return MaterialPageRoute(
          builder: (_) => const ProgressReportsPage(),
        );
      case RouterPaths.createExplorer:
        return MaterialPageRoute(
          builder: (_) => const CreateExplorerPage(),
        );
      case RouterPaths.createSession:
        return MaterialPageRoute(
          builder: (_) => const CreateSessionPage(),
        );
      case RouterPaths.practiceSession:
        return MaterialPageRoute(
          builder: (_) => const SessionEntryPage(),
        );
      case RouterPaths.practiceKiosk:
        final session = settings.arguments as PracticeSession;
        return MaterialPageRoute(
          builder: (_) => PracticeKioskPage(session: session),
        );
      case RouterPaths.childPortal:
        final pin = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ChildPortalPage(pinFromArgs: pin),
        );
      case RouterPaths.joinClass:
        final code = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => JoinClassPage(codeFromArgs: code),
        );
      case RouterPaths.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
        );
      case RouterPaths.privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyPage(),
        );
      case RouterPaths.termsOfService:
        return MaterialPageRoute(
          builder: (_) => const TermsOfServicePage(),
        );
      case RouterPaths.browseTeachers:
        final child = settings.arguments as ChildProfile;
        return MaterialPageRoute(
          builder: (_) => BrowseTeachersPage(child: child),
        );
      default:
        page = const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        );
        break;
    }

    return _getPageRoute(name, page, settings.arguments);
  }

  static PageRoute _getPageRoute(
    String routeName,
    dynamic viewToShow,
    Object? args,
  ) {
    AnalyticsService.logRouteChange(routeName);
    return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
        arguments: args,
      ),
      builder: (_) => viewToShow,
    );
  }
}
