import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
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
          style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2, // 2 columnas
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2, // Ajuste del tamaño de los botones
            children: bloc.currentAnswers.asMap().entries.map(
              (entry) {
                int index = entry.key;
                String answer = entry.value;
                return GestureDetector(
                  onTap: () => bloc.checkAnswer(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade800.withAlpha(1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      answer,
                      style: GoogleFonts.patrickHand(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
