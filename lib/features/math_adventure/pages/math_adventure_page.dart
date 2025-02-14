import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';
import 'package:edu_play/features/math_adventure/widgets/math_adventure_layout.dart';

class MathAdventurePage extends StatelessWidget {
  const MathAdventurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MathAdventureProvider>(
      create: (context) => MathAdventureProvider(),
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Math Adventure',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const MathAdventureLayout(),
      ),
    );
  }
}
