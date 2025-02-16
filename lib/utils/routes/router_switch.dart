import 'package:flutter/material.dart';

import 'package:edu_play/features/login/pages/login_page.dart';
import 'package:edu_play/features/math_adventure/pages/math_adventure_page.dart';
import 'package:edu_play/features/menu/pages/menu_page.dart';
import 'package:edu_play/features/register/pages/register_page.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterPaths.root:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case RouterPaths.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );
      case RouterPaths.menu:
        final userName = settings.arguments as String?;
        print(userName);
        return MaterialPageRoute(
          builder: (_) => MenuPage(username: userName),
        );
      case RouterPaths.mathAdventure:
        final userName = settings.arguments as String?;
        print(userName);
        return MaterialPageRoute(
          builder: (_) => MathAdventurePage(userName: userName),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }

  static Future<dynamic> push(BuildContext context, String path,
      {Map<String, dynamic>? params}) {
    return Navigator.pushNamed(context, path, arguments: params);
  }

  static Future<dynamic> replace(BuildContext context, String path,
      {Map<String, dynamic>? params}) {
    return Navigator.pushReplacementNamed(context, path, arguments: params);
  }

  void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
