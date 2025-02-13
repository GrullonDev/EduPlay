import 'package:flutter/material.dart';

import 'package:edu_play/features/login/pages/login_page.dart';
import 'package:edu_play/features/menu/pages/menu_page.dart';
import 'package:edu_play/features/register/pages/register_page.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterPaths.root:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RouterPaths.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case RouterPaths.menu:
        return MaterialPageRoute(builder: (_) => const MenuPage());
      // Agrega más rutas aquí según sea necesario
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
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
