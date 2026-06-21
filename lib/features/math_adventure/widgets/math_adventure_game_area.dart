import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';

class MathAdventureGameArea extends StatelessWidget {
  const MathAdventureGameArea({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MathAdventureProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = ScreenSize.fromConstraints(constraints);
        final questionFontSize = s.when(mobile: 34.0, tablet: 42.0, desktop: 48.0);
        final answerFontSize = s.when(mobile: 26.0, tablet: 34.0, desktop: 40.0);
        final cardPadding = s.isMobile ? 16.0 : 24.0;
        final gridSpacing = s.isMobile ? 14.0 : 20.0;

        return Column(
          children: [
            // Question Board
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '¡Resuelve!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    bloc.currentQuestion,
                    style: GoogleFonts.nunito(
                      fontSize: questionFontSize,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D3142),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: s.isMobile ? 24 : 40),
            // Answers Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: gridSpacing,
                mainAxisSpacing: gridSpacing,
                childAspectRatio: s.isMobile ? 1.5 : 1.3,
              ),
              itemCount: bloc.currentAnswers.length,
              itemBuilder: (context, index) {
                final answer = bloc.currentAnswers[index];
                return Material(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  elevation: 4,
                  child: InkWell(
                    onTap: () => bloc.checkAnswer(index),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        answer,
                        style: GoogleFonts.nunito(
                          fontSize: answerFontSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
