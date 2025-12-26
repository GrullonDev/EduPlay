import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';
import 'package:edu_play/features/math_adventure/widgets/math_adventure_game_area.dart';
import 'package:edu_play/features/math_adventure/widgets/math_adventure_header.dart';

class MathAdventureLayout extends StatelessWidget {
  const MathAdventureLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MathAdventureProvider>(
      builder: (context, bloc, __) => Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MathAdventureHeader(),
                const SizedBox(height: 40),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const MathAdventureGameArea(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
