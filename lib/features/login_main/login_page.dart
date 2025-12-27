import 'package:edu_play/features/login_main/login_layout.dart';
import 'package:flutter/material.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/data/datasources/local/database_helper.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class LoginMainPage extends StatefulWidget {
  const LoginMainPage({super.key});

  @override
  State<LoginMainPage> createState() => _LoginMainPageState();
}

class _LoginMainPageState extends State<LoginMainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndRedirect();
    });
  }

  Future<void> _checkAuthAndRedirect() async {
    // 1. Check if Parent is logged in (Firebase Auth)
    final authRepo = sl<AuthRepository>();
    final user = authRepo.getCurrentUser();

    if (user != null) {
      // 2. Check if there are children registered locally
      final db = DatabaseHelper();
      final children = await db.getChildren();

      if (mounted) {
        if (children.isNotEmpty) {
          // Go to Menu directly!
          final firstName = children.first['name'] as String;
          Navigator.pushReplacementNamed(context, RouterPaths.menu,
              arguments: firstName);
        } else {
          // Parent logged in, but no children found locally?
          // Maybe go to Register Child to finish setup
          Navigator.pushReplacementNamed(context, RouterPaths.registerChild);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent[200],
      body: const LoginMainLayout(),
    );
  }
}
