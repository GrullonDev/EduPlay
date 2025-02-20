import 'package:flutter/material.dart';

import 'package:edu_play/features/login/pages/login_page.dart';
import 'package:edu_play/features/math_adventure/pages/math_adventure_page.dart';
import 'package:edu_play/features/menu/pages/menu_page.dart';
import 'package:edu_play/features/register/pages/register_page.dart';
import 'package:edu_play/features/register/widgets/register_child.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget? page;
    String name = settings.name ?? '';

    switch (name) {
      case RouterPaths.root:
        page = const LoginPage();
      case RouterPaths.register:
        page = const RegisterPage();
      case RouterPaths.registerChild:
        page = const RegisterChild();
      case RouterPaths.menu:
        final userName = settings.arguments as String?;
        print(userName);
        page = MenuPage(username: userName);
      case RouterPaths.mathAdventure:
        final userName = settings.arguments as String?;
        print(userName);
        page = MathAdventurePage(userName: userName);

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
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

  static PageRoute _getPageRouteMap(
    String routeName,
    dynamic viewToShow,
    Object? args,
  ) {
    // sl<GoogleAnalytics>().setScreenName(routeName);
    return MaterialPageRoute<Map<String, dynamic>>(
      settings: RouteSettings(
        name: routeName,
        arguments: args,
      ),
      builder: (_) => viewToShow,
    );
  }

  // Valida use because it call dispose navigation to a new page
  static PageRoute _fadeRoute(
    String routeName,
    dynamic viewToShow,
    Object? args,
  ) {
    /* sl<GoogleAnalytics>().setScreenName(routeName);
    return FadeTransitionRoute(
      settings: RouteSettings(
        name: routeName,
        arguments: args,
      ),
      page: viewToShow,
    ); */
    return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
        arguments: args,
      ),
      builder: (_) => viewToShow,
    );
  }
}
