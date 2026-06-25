import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Dialog type ───────────────────────────────────────────────────────────────

enum DialogType { reward, levelUp, gameOver, info }

// ── Tokens ────────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kGold = Color(0xFFFFD32A);

// ── Public dialog widget ──────────────────────────────────────────────────────

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onButtonPressed,
    this.type = DialogType.info,
  });

  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final DialogType type;

  // ── Per-type config ─────────────────────────────────────────────────────────

  String get _emoji {
    switch (type) {
      case DialogType.reward:
        return '🎉';
      case DialogType.levelUp:
        return '⭐';
      case DialogType.gameOver:
        return '💫';
      case DialogType.info:
        return '📚';
    }
  }

  List<Color> get _gradientColors {
    switch (type) {
      case DialogType.reward:
        return [const Color(0xFFFF6E6C), const Color(0xFFFF9A5C)];
      case DialogType.levelUp:
        return [const Color(0xFF7B61FF), const Color(0xFF9F8BFF)];
      case DialogType.gameOver:
        return [const Color(0xFF1E1B6A), const Color(0xFF2D2A82)];
      case DialogType.info:
        return [const Color(0xFF1E1B6A), const Color(0xFF3D3AA0)];
    }
  }

  Color get _buttonColor {
    switch (type) {
      case DialogType.reward:
        return _kCoral;
      case DialogType.levelUp:
        return const Color(0xFF7B61FF);
      case DialogType.gameOver:
        return _kCoral;
      case DialogType.info:
        return _kNavy;
    }
  }

  bool get _isRewardType =>
      type == DialogType.reward || type == DialogType.levelUp;

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: _DialogCard(
        emoji: _emoji,
        title: title,
        content: content,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        gradientColors: _gradientColors,
        buttonColor: _buttonColor,
        isRewardType: _isRewardType,
      ),
    );
  }
}

// ── Card widget ───────────────────────────────────────────────────────────────

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.emoji,
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onButtonPressed,
    required this.gradientColors,
    required this.buttonColor,
    required this.isRewardType,
  });

  final String emoji;
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final List<Color> gradientColors;
  final Color buttonColor;
  final bool isRewardType;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Colored header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Decorative blobs
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                // Stars for reward types
                if (isRewardType) ...[
                  Positioned(
                    top: 4,
                    left: 12,
                    child: Icon(Icons.star_rounded,
                        size: 14, color: _kGold.withValues(alpha: 0.8)),
                  ),
                  Positioned(
                    top: 24,
                    left: 44,
                    child: Icon(Icons.star_rounded,
                        size: 9, color: _kGold.withValues(alpha: 0.6)),
                  ),
                  Positioned(
                    top: 8,
                    right: 40,
                    child: Icon(Icons.star_rounded,
                        size: 11, color: _kGold.withValues(alpha: 0.7)),
                  ),
                ],
                // Main emoji + title
                Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── White body ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
            child: Column(
              children: [
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _kNavy.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.fredoka(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
