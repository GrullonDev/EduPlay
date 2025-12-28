import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';
import 'package:edu_play/features/math_adventure/pages/math_adventure_layout.dart';

class MathAdventurePage extends StatelessWidget {
  const MathAdventurePage({
    super.key,
    required this.userName,
  });

  final String? userName;

  @override
  Widget build(BuildContext context) {
    // Obtain age from RegisterProvider, default to 6 if not set or invalid
    final registerProvider = context.read<RegisterProvider>();
    int age = int.tryParse(registerProvider.age) ?? 6;

    return ChangeNotifierProvider<MathAdventureProvider>(
      create: (context) => MathAdventureProvider(
        context: context,
        age: age,
        userName: userName,
      ),
      builder: (_, __) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4CAF50), // Fresh Green
                Color(0xFF81C784), // Lighter Green
              ],
            ),
          ),
          child: const SafeArea(
            child: MathAdventureLayout(),
          ),
        ),
      ),
    );
  }
}
