// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/streak_recovery/bloc/streak_recovery_controller.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);

/// 10-question streak-recovery quiz: pass with 9+ correct to keep a lapsed
/// streak alive, otherwise it resets and the child starts a new one.
class StreakRecoveryQuizPage extends StatelessWidget {
  const StreakRecoveryQuizPage({super.key, required this.childProfile});

  final ChildProfile childProfile;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StreakRecoveryController>(
      create: (_) => StreakRecoveryController(age: childProfile.age),
      child: const _StreakRecoveryQuizView(),
    );
  }
}

class _StreakRecoveryQuizView extends StatefulWidget {
  const _StreakRecoveryQuizView();

  @override
  State<_StreakRecoveryQuizView> createState() =>
      _StreakRecoveryQuizViewState();
}

class _StreakRecoveryQuizViewState extends State<_StreakRecoveryQuizView> {
  bool _resultShown = false;

  void _maybeShowResult(StreakRecoveryController controller) {
    if (!controller.isFinished || _resultShown) return;
    _resultShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showResultDialog(controller);
    });
  }

  void _showResultDialog(StreakRecoveryController controller) {
    final passed = controller.passed;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDialog(
        type: passed ? DialogType.reward : DialogType.gameOver,
        title: passed ? '¡Racha recuperada!' : 'Racha reiniciada',
        content: passed
            ? 'Acertaste ${controller.correctCount} de ${StreakRecoveryController.totalQuestions}. ¡Tu racha sigue viva! 🔥'
            : 'Acertaste ${controller.correctCount} de ${StreakRecoveryController.totalQuestions}. No alcanzó, pero puedes empezar una nueva racha jugando hoy.',
        buttonText: 'Volver al inicio',
        onButtonPressed: () =>
            StudentSessionNavigationService.returnAfterGameOver(
          dialogContext,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StreakRecoveryController>();
    _maybeShowResult(controller);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kNavy, _kNavyDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: controller.isFinished
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🔥 Recupera tu racha',
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pregunta ${controller.questionNumber} de ${StreakRecoveryController.totalQuestions} · necesitas ${StreakRecoveryController.passThreshold} correctas',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(height: 28),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (controller.questionNumber - 1) /
                                  StreakRecoveryController.totalQuestions,
                              minHeight: 8,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.12),
                              color: _kCoral,
                            ),
                          ),
                          const SizedBox(height: 36),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 28, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              controller.current.question,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 2.2,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (var i = 0;
                                  i < controller.current.options.length;
                                  i++)
                                _AnswerButton(
                                  label: controller.current.options[i],
                                  onTap: () => controller.submitAnswer(i),
                                ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _kNavy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}
