// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/l10n/app_localizations.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGreen = Color(0xFF27AE60);
const _kRed = Color(0xFFE53935);

/// Shows why an answer was right or wrong before the next question loads —
/// the piece every legacy game bloc was missing (they only decremented a
/// life and silently regenerated the next question, with no feedback on
/// *why* the answer was wrong).
///
/// Callers should `await` this before advancing to the next question, so
/// the player has time to read the explanation. Typically only shown on
/// incorrect answers, to keep the pace reasonable on correct streaks.
Future<void> showAnswerExplanation(
  BuildContext context, {
  required bool isCorrect,
  required String correctAnswerText,
  required String explanation,
  String? skillLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isCorrect ? _kGreen : _kRed,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCorrect
                        ? l10n.answerCorrectTitle
                        : l10n.answerIncorrectTitle,
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!isCorrect) ...[
                Text(
                  l10n.answerCorrectAnswerLabel(correctAnswerText),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                explanation,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              if (skillLabel != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kNavy.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    skillLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kNavy.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect ? _kGreen : _kNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.answerNextButton,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
