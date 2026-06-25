import 'package:edu_play/features/main/main_layout.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFEEEDF8),
      body: MainLayout(),
    );
  }
}
