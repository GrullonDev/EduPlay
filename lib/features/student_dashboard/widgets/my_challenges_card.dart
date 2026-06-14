import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:edu_play/utils/app_theme.dart';

/// "Mis Retos" card: lists the challenges assigned by the teacher (stored
/// locally) with a checkbox to mark them as completed.
class MyChallengesCard extends StatelessWidget {
  const MyChallengesCard({
    super.key,
    required this.challenges,
    required this.onComplete,
  });

  final List<Map<String, dynamic>> challenges;
  final ValueChanged<int> onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppTheme.secondaryColor),
              const SizedBox(width: 10),
              Text(
                'Mis Retos',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (challenges.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Tu profesor aún no te ha asignado retos.',
                style: GoogleFonts.nunito(color: Colors.grey[600]),
              ),
            )
          else
            for (final challenge in challenges)
              _ChallengeRow(challenge: challenge, onComplete: onComplete),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge, required this.onComplete});

  final Map<String, dynamic> challenge;
  final ValueChanged<int> onComplete;

  @override
  Widget build(BuildContext context) {
    final id = challenge['id'] as int;
    final title = challenge['title'] as String? ?? 'Reto';
    final subjectKey = challenge['subject_key'] as String?;
    final subject = subjectKey != null ? subjectByKey(subjectKey) : null;
    final isCompleted = challenge['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            activeColor: AppTheme.secondaryColor,
            onChanged: isCompleted ? null : (_) => onComplete(id),
          ),
          if (subject != null) ...[
            Icon(subject.icon, size: 18, color: subject.color),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
