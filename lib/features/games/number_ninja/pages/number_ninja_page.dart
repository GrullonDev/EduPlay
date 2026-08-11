import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/games/core/widgets/game_header.dart';
import 'package:edu_play/features/games/core/widgets/game_over_dialog.dart';
import 'package:edu_play/features/games/core/widgets/game_scaffold.dart';
import 'package:edu_play/features/games/number_ninja/number_ninja_controller.dart';

class NumberNinjaPage extends StatefulWidget {
  const NumberNinjaPage({super.key});

  @override
  State<NumberNinjaPage> createState() => _NumberNinjaPageState();
}

class _NumberNinjaPageState extends State<NumberNinjaPage> {
  late final NumberNinjaController _controller = NumberNinjaController();
  bool _gameOverShown = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(_maybeShowGameOver)
      ..startGame();
  }

  void _maybeShowGameOver() {
    if (_gameOverShown || _controller.lives > 0) return;
    _gameOverShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameOverDialog(
        context: context,
        finalScore: _controller.score,
        title: 'Fin del reto ninja',
      );
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_maybeShowGameOver)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GameScaffold(
          header: GameHeader(
            title: _controller.metadata.title,
            score: _controller.score,
            lives: _controller.lives,
            timeRemaining: _controller.timeRemaining,
          ),
          backgroundGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F3443), Color(0xFF34E89E)],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Verdadero o falso?',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 34,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Text(
                        _controller.equationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F3443),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _AnswerButton(
                            label: 'Verdadero',
                            color: const Color(0xFF16A085),
                            onPressed: () => _controller.answer(true),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _AnswerButton(
                            label: 'Falso',
                            color: const Color(0xFFE74C3C),
                            onPressed: () => _controller.answer(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
