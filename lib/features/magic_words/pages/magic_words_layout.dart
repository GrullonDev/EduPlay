import 'package:edu_play/features/magic_words/bloc/magic_words_bloc.dart';
// Reusing header widgets? Or duplicate logic.
// Ideally, refactor Header to 'GameHeader', but for speed I might just duplicate or use similar widget.
// However, 'MathAdventureHeader' is specific to that bloc. I'll create a generic one or just inline.
// Let's create a generic looking header inline here or access properties.
// Actually, I can reuse the "Pill" concept but implemented here.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MagicWordsLayout extends StatelessWidget {
  const MagicWordsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MagicWordsProvider>();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoPill(context, Icons.star_rounded, Colors.amber,
                      '${bloc.score}'),
                  _buildInfoPill(context, Icons.favorite_rounded, Colors.red,
                      '${bloc.lives}'),
                ],
              ),
              const SizedBox(height: 40),

              // Game Area
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Question / Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
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
                          Icon(
                            bloc.targetIcon,
                            size: 80,
                            color: const Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 20),
                          if (bloc.age > 8) ...[
                            Text(
                              'Ordena: ${bloc.scrambledLetters.join(" ")}',
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ] else ...[
                            Text(
                              bloc.displayWord,
                              style: GoogleFonts.nunito(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Options Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: bloc.age > 8
                            ? 2
                            : 3, // 2 cols for full words, 3 for letters
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: bloc.age > 8 ? 2.5 : 1,
                      ),
                      itemCount: bloc.options.length,
                      itemBuilder: (context, index) {
                        return _buildOptionButton(
                            context, bloc, bloc.options[index]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(
      BuildContext context, IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D3142),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
      BuildContext context, MagicWordsProvider bloc, String text) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        onTap: () => bloc.checkAnswer(text),
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
            text,
            style: GoogleFonts.nunito(
              fontSize: bloc.age > 8 ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2196F3),
            ),
          ),
        ),
      ),
    );
  }
}
