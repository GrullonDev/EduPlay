import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';
import 'package:edu_play/features/math_adventure/pages/math_adventure_layout.dart';

class MathAdventurePage extends StatelessWidget {
  const MathAdventurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MathAdventureProvider>(
      create: (context) => MathAdventureProvider(context: context),
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Aventuras Matemáticas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: const Column(
          children: [
            MathAdventureLayout(),
          ],
        ),
      ),
    );
  }
}
