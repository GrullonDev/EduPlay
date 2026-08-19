// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_header.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/features/games/core/widgets/game_over_dialog.dart';
import 'package:edu_play/features/games/core/widgets/game_scaffold.dart';
import 'package:edu_play/features/games/number_ninja/number_ninja_controller.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';

class NumberNinjaPage extends StatefulWidget {
  const NumberNinjaPage({super.key});

  @override
  State<NumberNinjaPage> createState() => _NumberNinjaPageState();
}

class _NumberNinjaPageState extends State<NumberNinjaPage> {
  late final NumberNinjaController _controller = NumberNinjaController();
  bool _gameOverShown = false;
  bool _explanationShowing = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(_maybeShowGameOver)
      ..addListener(_maybeShowExplanation);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWithIntro());
  }

  /// Shows the objective/difficulty dialog before the first equation
  /// appears, so the player knows what they're about to practice instead
  /// of being dropped straight into a countdown.
  Future<void> _startWithIntro() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Ninja de los Números',
      objective: 'Vas a practicar cálculo mental rápido con sumas y restas',
      difficultyLabel: 'Principiante',
    );
    if (!mounted) return;
    _controller.startGame();
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
        skills: _controller.skillTracker.tallies,
      );
    });
  }

  /// Reacts to the controller freezing a round on a wrong answer/timeout
  /// ([NumberNinjaController.pendingExplanation]) by showing why the
  /// player failed, then tells the controller to advance once the sheet is
  /// dismissed. The controller has no [BuildContext] of its own, so this
  /// page is what bridges its state to the dialog/sheet widgets.
  void _maybeShowExplanation() {
    final explanation = _controller.pendingExplanation;
    if (explanation == null || _explanationShowing) return;
    _explanationShowing = true;
    final correctLabel = _controller.pendingCorrectAnswerLabel ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _explanationShowing = false;
        return;
      }
      await showAnswerExplanation(
        context,
        isCorrect: false,
        correctAnswerText: correctLabel,
        explanation: explanation,
        skillLabel: skillByKey('calculo_mental').label,
      );
      _explanationShowing = false;
      if (!mounted) return;
      _controller.acknowledgeExplanation();
    });
  }

  /// Whether the board should accept a tap right now — locked out while
  /// there are no lives left or while the explanation sheet for the
  /// previous wrong answer hasn't been dismissed yet.
  bool get _canAnswer =>
      _controller.lives > 0 && _controller.pendingExplanation == null;

  @override
  void dispose() {
    _controller
      ..removeListener(_maybeShowGameOver)
      ..removeListener(_maybeShowExplanation)
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
                            onPressed: _canAnswer
                                ? () => _controller.answer(true)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _AnswerButton(
                            label: 'Falso',
                            color: const Color(0xFFE74C3C),
                            onPressed: _canAnswer
                                ? () => _controller.answer(false)
                                : null,
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
  final VoidCallback? onPressed;

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
