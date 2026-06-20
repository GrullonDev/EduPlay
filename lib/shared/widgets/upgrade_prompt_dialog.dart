import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/subscription/models/subscription.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kGold = Color(0xFFF39C12);
const _kBg = Color(0xFFF8F7FF);

enum UpgradeReason { childLimit, sessionLimit }

/// Shows a paywall dialog explaining the free-tier limit that was hit and
/// presenting the Pro upgrade offer.
///
/// Usage:
/// ```dart
/// final upgraded = await showUpgradePrompt(context, UpgradeReason.sessionLimit);
/// ```
/// Returns true if the user tapped the upgrade CTA (reserved for Stripe flow).
Future<bool> showUpgradePrompt(
  BuildContext context,
  UpgradeReason reason,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => _UpgradePromptDialog(reason: reason),
      ) ??
      false;
}

class _UpgradePromptDialog extends StatelessWidget {
  const _UpgradePromptDialog({required this.reason});
  final UpgradeReason reason;

  String get _title => reason == UpgradeReason.childLimit
      ? 'Has alcanzado el límite\nde exploradores'
      : 'Has alcanzado el límite\nde sesiones este mes';

  String get _subtitle => reason == UpgradeReason.childLimit
      ? 'El plan gratuito incluye hasta ${Subscription.freeChildLimit} perfil de niño. '
          'Pasa a Pro para añadir exploradores ilimitados.'
      : 'El plan gratuito incluye hasta ${Subscription.freeSessionLimit} sesiones por mes. '
          'Pasa a Pro para crear sesiones sin límite.';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _kNavy.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header band ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B6A), Color(0xFF3A36A0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.rocket_launch_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Plan comparison ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _PlanCard.free()),
                        const SizedBox(width: 12),
                        Expanded(child: _PlanCard.pro()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Upgrade CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kCoral,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Mejorar a Pro',
                              style: GoogleFonts.fredoka(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Continuar con el plan gratuito',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Plan comparison cards ─────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.features,
    required this.highlighted,
    required this.badgeColor,
  });

  factory _PlanCard.free() => const _PlanCard(
        name: 'Gratuito',
        price: '\$0/mes',
        features: [
          '1 perfil de niño',
          '5 sesiones/mes',
          '9 juegos educativos',
          'Informes básicos',
        ],
        highlighted: false,
        badgeColor: Color(0xFF888888),
      );

  factory _PlanCard.pro() => const _PlanCard(
        name: 'Pro',
        price: '\$9.99/mes',
        features: [
          'Niños ilimitados',
          'Sesiones ilimitadas',
          '9 juegos educativos',
          'Informes avanzados',
          'Soporte prioritario',
        ],
        highlighted: true,
        badgeColor: _kGold,
      );

  final String name;
  final String price;
  final List<String> features;
  final bool highlighted;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? _kNavy : _kBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? _kNavy : const Color(0xFFE0DEFF),
          width: highlighted ? 0 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: highlighted ? 1.0 : 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              name,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: highlighted ? Colors.white : badgeColor,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Price
          Text(
            price,
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: highlighted ? Colors.white : _kNavy,
            ),
          ),
          const SizedBox(height: 12),

          // Features
          for (final feature in features) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: highlighted ? _kCoral : const Color(0xFF27AE60),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    feature,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: highlighted
                          ? Colors.white.withValues(alpha: 0.85)
                          : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
