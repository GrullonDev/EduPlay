import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';

class MathAdventureLayout extends StatelessWidget {
  const MathAdventureLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MathAdventureProvider>(
      builder: (context, bloc, __) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Score: ${bloc.score}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: bloc.increaseScore,
              child: const Text('Increase Score'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: bloc.resetScore,
              child: const Text('Reset Score'),
            ),
          ],
        ),
      ),
    );
  }
}
