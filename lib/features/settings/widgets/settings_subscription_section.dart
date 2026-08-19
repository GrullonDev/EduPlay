// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/settings/widgets/settings_section_card.dart';
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/features/subscription/services/stripe_service.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);

class SettingsSubscriptionSection extends StatelessWidget {
  const SettingsSubscriptionSection(
      {super.key, SubscriptionRepository? repository})
      : _repository = repository;

  final SubscriptionRepository? _repository;

  @override
  Widget build(BuildContext context) {
    init();
    final repository = _repository ?? sl<SubscriptionRepository>();

    return StreamBuilder<Subscription>(
      stream: repository.watchSubscription(),
      builder: (context, snap) {
        final sub = snap.data ?? Subscription.freeTier();
        final isPro = sub.isPro;
        final sessionsUsed = sub.sessionsThisMonth;
        const sessionLimit = Subscription.freeSessionLimit;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSectionCard(
              icon: Icons.credit_card_outlined,
              title: 'Suscripción',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current plan banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPro
                            ? [const Color(0xFF1E1B6A), const Color(0xFF3A36A0)]
                            : [Colors.grey.shade100, Colors.grey.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: isPro ? 0.12 : 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPro
                                ? Icons.star_rounded
                                : Icons.lock_outline_rounded,
                            color: isPro ? Colors.white : Colors.grey.shade500,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPro ? 'Plan Pro' : 'Plan Gratuito',
                                style: GoogleFonts.fredoka(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isPro
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                isPro
                                    ? 'Acceso ilimitado a todas las funciones'
                                    : 'Limitado a 1 niño y 5 sesiones/mes',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: isPro
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isPro) ...[
                    const SizedBox(height: 24),

                    // Usage meters
                    Text(
                      'USO ESTE MES',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: _kNavy.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _UsageMeter(
                      label: 'Sesiones de práctica',
                      used: sessionsUsed,
                      limit: sessionLimit,
                    ),
                    const SizedBox(height: 12),
                    const _UsageMeter(
                      label: 'Perfiles de niño',
                      used: null, // loaded by a separate FutureBuilder below
                      limit: Subscription.freeChildLimit,
                      isChildMeter: true,
                    ),

                    const SizedBox(height: 24),

                    // Upgrade CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await StripeService.startCheckout();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'No se pudo abrir el pago. Inténtalo de nuevo.',
                                    style: GoogleFonts.nunito(),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.rocket_launch_rounded,
                            size: 18, color: Colors.white),
                        label: Text(
                          'Mejorar a Pro — \$9.99/mes',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6E6C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],

                  if (isPro) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Tienes acceso ilimitado. Gracias por tu apoyo.',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            const SettingsFooter(),
          ],
        );
      },
    );
  }
}

// ── Usage meter ───────────────────────────────────────────────────────────────

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({
    required this.label,
    required this.used,
    required this.limit,
    this.isChildMeter = false,
  });

  final String label;
  final int? used; // null triggers a FutureBuilder for child count
  final int limit;
  final bool isChildMeter;

  @override
  Widget build(BuildContext context) {
    if (isChildMeter) {
      return FutureBuilder<int>(
        future: ChildProfilesService.getProfiles().then((list) => list.length),
        builder: (ctx, snap) => _bar(label, snap.data ?? 0, limit),
      );
    }
    return _bar(label, used ?? 0, limit);
  }

  Widget _bar(String lbl, int u, int lim) {
    final fraction = (u / lim).clamp(0.0, 1.0);
    final atLimit = u >= lim;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lbl,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333355))),
            Text(
              '$u / $lim',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                    atLimit ? const Color(0xFFE74C3C) : const Color(0xFF1E1B6A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: const Color(0xFFEEEDF8),
            valueColor: AlwaysStoppedAnimation<Color>(
              atLimit ? const Color(0xFFE74C3C) : const Color(0xFF1E1B6A),
            ),
          ),
        ),
      ],
    );
  }
}
