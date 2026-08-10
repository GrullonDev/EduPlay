import 'package:flutter/material.dart';

import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';

/// Shared "game over" dialog. Score persistence already happened in
/// `GameSessionController.onGameOver()` by the time this shows — this is
/// UI-only, so every game gets the same look without copy-pasting the
/// dialog block `math_adventure_bloc` used to hand-roll.
Future<void> showGameOverDialog({
  required BuildContext context,
  required int finalScore,
  String title = '¡Buen intento!',
  VoidCallback? onContinue,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CustomDialog(
      title: title,
      content: 'Puntuación final: $finalScore pts\n¡Sigue practicando!',
      buttonText: 'Volver al inicio',
      type: DialogType.gameOver,
      onButtonPressed: onContinue ??
          () => StudentSessionNavigationService.returnAfterGameOver(
                dialogContext,
              ),
    ),
  );
}
