import 'package:edu_play/features/login_main/login_layout.dart';
import 'package:flutter/material.dart';

class LoginMainPage extends StatelessWidget {
  const LoginMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent[200],
      body: const LoginMainLayout(),
    );
  }
}
