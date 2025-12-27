import 'package:flutter/material.dart';

import 'package:edu_play/features/login/pages/login_page.dart';
import 'package:edu_play/features/login_main/login_page.dart';
import 'package:edu_play/features/magic_words/pages/magic_words_page.dart';
import 'package:edu_play/features/math_adventure/pages/math_adventure_page.dart';
import 'package:edu_play/features/menu/pages/menu_page.dart';
import 'package:edu_play/features/register_child/pages/register_child_page.dart';
import 'package:edu_play/features/register_parents/pages/register_parents_page.dart';
import 'package:edu_play/features/guest/pages/guest_entry_page.dart';
import 'package:edu_play/features/parents_dashboard/pages/parents_dashboard_page.dart';
import 'package:edu_play/features/fun_english/pages/fun_english_page.dart';
import 'package:edu_play/features/nature_explorers/pages/nature_explorers_page.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    String name = settings.name ?? '';

    switch (name) {
      case RouterPaths.root:
        page = const LoginMainPage();
        break;
      case RouterPaths.login:
        page = const LoginPage();
        break;
      case RouterPaths.registerParents:
        page = const RegisterParentsPage();
        break;
      case RouterPaths.registerChild:
        page = const RegisterChildPage();
        break;
      case RouterPaths.menu:
        final userName = settings.arguments as String?;
        page = MenuPage(username: userName);
        break;
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
      case RouterPaths.parentsDashboard:
        return MaterialPageRoute(
          builder: (_) => const ParentsDashboardPage(),
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
    // sl<GoogleAnalyticsService>().setScreenName(routeName);
    return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
        arguments: args,
      ),
      builder: (_) => viewToShow,
    );
  }
}
