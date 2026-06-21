import 'package:edu_play/features/magic_words/bloc/magic_words_bloc.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MagicWordsLayout extends StatelessWidget {
  const MagicWordsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MagicWordsProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = ScreenSize.fromConstraints(constraints);
        final hPad = s.when(mobile: 16.0, tablet: 24.0, desktop: 32.0);
        final iconSize = s.when(mobile: 56.0, tablet: 68.0, desktop: 80.0);
        final scrambleFontSize = s.when(mobile: 18.0, tablet: 22.0, desktop: 24.0);
        final wordFontSize = s.when(mobile: 34.0, tablet: 42.0, desktop: 48.0);
        final answerFontSize = bloc.age > 8
            ? s.when(mobile: 18.0, tablet: 22.0, desktop: 24.0)
            : s.when(mobile: 22.0, tablet: 28.0, desktop: 32.0);
        final gridSpacing = s.isMobile ? 14.0 : 20.0;

        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(hPad),
              child: Column(
                children: [
                  // Header pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoPill(
                          context, Icons.star_rounded, Colors.amber,
                          '${bloc.score}', s),
                      _buildInfoPill(
                          context, Icons.favorite_rounded, Colors.red,
                          '${bloc.lives}', s),
                    ],
                  ),
                  SizedBox(height: s.isMobile ? 24 : 40),

                  // Game Area
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        // Question / Display
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(s.isMobile ? 20 : 32),
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
                                size: iconSize,
                                color: const Color(0xFF2196F3),
                              ),
                              const SizedBox(height: 20),
                              if (bloc.age > 8) ...[
                                Text(
                                  'Ordena: ${bloc.scrambledLetters.join(" ")}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: scrambleFontSize,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ] else ...[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    bloc.displayWord,
                                    style: GoogleFonts.nunito(
                                      fontSize: wordFontSize,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 8,
                                      color: const Color(0xFF2D3142),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: s.isMobile ? 24 : 40),

                        // Options Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: bloc.age > 8 ? 2 : 3,
                            crossAxisSpacing: gridSpacing,
                            mainAxisSpacing: gridSpacing,
                            childAspectRatio: bloc.age > 8
                                ? (s.isMobile ? 2.8 : 2.5)
                                : (s.isMobile ? 1.2 : 1),
                          ),
                          itemCount: bloc.options.length,
                          itemBuilder: (context, index) {
                            return _buildOptionButton(
                                context, bloc, bloc.options[index],
                                answerFontSize);
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
      },
    );
  }

  Widget _buildInfoPill(BuildContext context, IconData icon, Color color,
      String text, ScreenSize s) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: s.isMobile ? 12 : 16, vertical: s.isMobile ? 6 : 8),
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
          Icon(icon, color: color, size: s.isMobile ? 22 : 28),
          SizedBox(width: s.isMobile ? 6 : 8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: s.isMobile ? 18 : null,
                  color: const Color(0xFF2D3142),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, MagicWordsProvider bloc,
      String text, double fontSize) {
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
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2196F3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
