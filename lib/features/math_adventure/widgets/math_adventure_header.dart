import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';

class MathAdventureHeader extends StatelessWidget {
  const MathAdventureHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MathAdventureProvider>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Score: ${bloc.score}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        Text(
          'Vidas: ${bloc.lives}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: bloc.resetScore,
          child: const Text('Reset Score'),
        ),
      ],
    );
  }
}
