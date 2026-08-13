import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/dialogs/confetti_burst.dart';

const _kNavy = Color(0xFF1E1B6A);

/// Brief, non-blocking celebration shown after a successful purchase —
/// confetti + a scale-in checkmark card that dismisses itself. Doesn't wait
/// for a button tap (unlike [CustomDialog]) since a purchase isn't a
/// decision the child needs to acknowledge, just good news to enjoy.
Future<void> showPurchaseSuccessCelebration(
  BuildContext context, {
  required String itemName,
}) async {
  final navigator = Navigator.of(context);
  unawaited(
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) => Stack(
        children: [
          const Positioned.fill(child: ConfettiBurst(particleCount: 28)),
          Center(
            child: _SuccessCard(itemName: itemName),
          ),
        ],
      ),
    ),
  );

  await Future.delayed(const Duration(milliseconds: 1400));
  if (navigator.canPop()) navigator.pop();
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.itemName});
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              '¡Lo compraste!',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              itemName,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
