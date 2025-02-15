import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';

class MathAdventureGameArea extends StatelessWidget {
  const MathAdventureGameArea({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MathAdventureProvider>();

    return Column(
      children: [
        Text(
          'Pregunta: ${bloc.currentQuestion}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...bloc.currentAnswers.asMap().entries.map(
          (entry) {
            int index = entry.key;
            String answer = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ElevatedButton(
                onPressed: () => bloc.checkAnswer(index),
                child: Text(answer),
              ),
            );
          },
        ),
      ],
    );
  }
}
