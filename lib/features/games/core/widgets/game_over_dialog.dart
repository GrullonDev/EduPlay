// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';

/// Shared "game over" dialog. Score persistence already happened in
/// `GameSessionController.onGameOver()` by the time this shows — this is
/// UI-only, so every game gets the same look without copy-pasting the
/// dialog block `math_adventure_bloc` used to hand-roll.
Future<void> showGameOverDialog({
  required BuildContext context,
  required int finalScore,
  String title = '¡Buen intento!',
  Map<String, SkillTally>? skills,
  VoidCallback? onContinue,
}) {
  final summary = skills == null ? '' : skillSummaryText(skills);
  final content = summary.isEmpty
      ? 'Puntuación final: $finalScore pts\n¡Sigue practicando!'
      : 'Puntuación final: $finalScore pts\n$summary\n¡Sigue practicando!';

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CustomDialog(
      title: title,
      content: content,
      buttonText: 'Volver al inicio',
      type: DialogType.gameOver,
      onButtonPressed: onContinue ??
          () => StudentSessionNavigationService.returnAfterGameOver(
                dialogContext,
              ),
    ),
  );
}
