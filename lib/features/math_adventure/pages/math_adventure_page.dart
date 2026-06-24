import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';
import 'package:edu_play/features/math_adventure/pages/math_adventure_layout.dart';

class MathAdventurePage extends StatelessWidget {
  const MathAdventurePage({
    super.key,
    required this.userName,
    this.onScoreUpdate,
  });

  final String? userName;

  /// Optional callback invoked each time the player earns points.
  /// The kiosk wrapper uses this to capture the real score before
  /// recording game completion.
  final void Function(int score)? onScoreUpdate;

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
        onScoreUpdate: onScoreUpdate,
      ),
      builder: (_, __) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF16125C),
                Color(0xFF231B72),
                Color(0xFF12104A),
              ],
              stops: [0.0, 0.55, 1.0],
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
