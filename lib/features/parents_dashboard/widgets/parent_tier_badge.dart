// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kPro = Color(0xFFF39C12);

class ParentTierBadge extends StatelessWidget {
  ParentTierBadge({super.key, SubscriptionRepository? repository})
      : _repository = repository ?? sl<SubscriptionRepository>();

  final SubscriptionRepository _repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Subscription>(
      stream: _repository.watchSubscription(),
      builder: (context, snap) {
        final sub = snap.data;
        if (sub == null) return const SizedBox.shrink();

        final isPro = sub.isPro;
        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RouterPaths.settings),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isPro
                  ? _kPro.withValues(alpha: 0.15)
                  : _kNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPro ? _kPro : _kNavy.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPro ? Icons.star_rounded : Icons.lock_outline_rounded,
                  size: 11,
                  color: isPro ? _kPro : _kNavy,
                ),
                const SizedBox(width: 4),
                Text(
                  isPro ? 'PRO' : 'GRATIS',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isPro ? _kPro : _kNavy,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
