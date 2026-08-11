import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared header every minigame page uses, so all games look consistent
/// without each one rebuilding its own title/score/lives bar.
///
/// [lives] and [timeRemaining] are optional — pass null to hide that chip
/// entirely (e.g. a puzzle game with no lives, or no per-question timer).
class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  const GameHeader({
    super.key,
    required this.title,
    required this.score,
    this.lives,
    this.timeRemaining,
  });

  final String title;
  final int score;
  final int? lives;
  final Duration? timeRemaining;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
      ),
      actions: [
        if (lives != null) _LivesChip(lives: lives!),
        if (timeRemaining != null) _TimeChip(remaining: timeRemaining!),
        _ScoreChip(score: score),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return _HeaderChip(
      icon: Icons.star_rounded,
      iconColor: const Color(0xFFFFD32A),
      label: '$score',
    );
  }
}

class _LivesChip extends StatelessWidget {
  const _LivesChip({required this.lives});
  final int lives;

  @override
  Widget build(BuildContext context) {
    return _HeaderChip(
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFFF6E6C),
      label: '$lives',
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final seconds = (remaining.inMilliseconds / 1000).ceil().clamp(0, 999);
    return _HeaderChip(
      icon: Icons.timer_rounded,
      iconColor: Colors.white,
      label: '${seconds}s',
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
