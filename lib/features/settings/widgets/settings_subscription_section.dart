// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/payments/domain/usecases/create_recurrente_checkout_usecase.dart';
import 'package:edu_play/features/payments/presentation/screens/recurrente_checkout_screen.dart';
import 'package:edu_play/features/settings/widgets/settings_section_card.dart';
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGold = Color(0xFFF39C12);
const _kCoral = Color(0xFFFF6E6C);

const _kProPriceUsd = 4.99;
const _kProPriceGtq = 38.04;

const _kProBenefits = [
  'Exploradores ilimitados',
  'Sesiones de práctica ilimitadas',
  'Informes avanzados de progreso',
  'Soporte prioritario',
];

class SettingsSubscriptionSection extends StatefulWidget {
  const SettingsSubscriptionSection(
      {super.key, SubscriptionRepository? repository})
      : _repository = repository;

  final SubscriptionRepository? _repository;

  @override
  State<SettingsSubscriptionSection> createState() =>
      _SettingsSubscriptionSectionState();
}

class _SettingsSubscriptionSectionState
    extends State<SettingsSubscriptionSection> {
  bool _startingCheckout = false;

  Future<void> _startCheckout(BuildContext context) async {
    if (_startingCheckout) return;
    setState(() => _startingCheckout = true);
    try {
      final authRepository = sl<AuthRepository>();
      final uid = authRepository.getCurrentUserUid();
      final email = authRepository.getCurrentUserEmail();
      if (uid == null || email == null) {
        throw Exception('Debes iniciar sesión para suscribirte.');
      }

      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final checkout = await sl<CreateRecurrenteCheckoutUseCase>()(
        amount: _kProPriceGtq,
        orderId: orderId,
        userEmail: email,
        itemName: 'EduPlay Pro - Suscripción mensual',
        currency: 'GTQ',
        metadata: const {'kind': 'subscription'},
      );

      if (!context.mounted) return;
      final paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => RecurrenteCheckoutScreen(
            checkoutUrl: checkout.checkoutUrl,
            orderId: checkout.orderId,
          ),
        ),
      );

      if (paid == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Listo! Ya eres Pro.',
              style: GoogleFonts.nunito(),
            ),
          ),
        );
      }
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
    } finally {
      if (mounted) setState(() => _startingCheckout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    final repository = widget._repository ?? sl<SubscriptionRepository>();

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
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPro
                            ? [const Color(0xFF1E1B6A), const Color(0xFF3A36A0)]
                            : [Colors.grey.shade100, Colors.grey.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: isPro
                          ? Border.all(
                              color: _kGold.withValues(alpha: 0.5), width: 1)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (isPro)
                          Positioned(
                            top: -30,
                            right: -30,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kGold.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                    ? Icons.workspace_premium_rounded
                                    : Icons.lock_outline_rounded,
                                color: isPro ? _kGold : Colors.grey.shade500,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                      if (isPro) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _kGold,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'ACTIVO',
                                            style: GoogleFonts.nunito(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                              color: _kNavy,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
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
                      used: null,
                      limit: Subscription.freeChildLimit,
                      isChildMeter: true,
                    ),

                    const SizedBox(height: 24),

                    // Pro pricing card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0DEFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  color: _kGold, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Con Plan Pro obtienes',
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _kNavy,
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '\$$_kProPriceUsd',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _kNavy,
                                        ),
                                      ),
                                      Text(
                                        '/mes',
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '≈ Q$_kProPriceGtq',
                                    style: GoogleFonts.nunito(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (final benefit in _kProBenefits) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 15, color: Color(0xFF27AE60)),
                                  const SizedBox(width: 8),
                                  Text(
                                    benefit,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Upgrade CTA
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kCoral, Color(0xFFFF8B69)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _kCoral.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _startingCheckout
                                ? null
                                : () => _startCheckout(context),
                            child: Center(
                              child: _startingCheckout
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.rocket_launch_rounded,
                                            size: 18, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Mejorar a Pro',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          'Pago seguro con Recurrente · Cancela cuando quieras',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
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
