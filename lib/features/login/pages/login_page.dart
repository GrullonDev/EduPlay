import 'package:edu_play/features/login/pages/login_layout.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF), // Primary
              Color(0xFF00BFA6), // Secondary
            ],
          ),
        ),
        child: const LoginLayout(),
      ),
    );
  }
}
