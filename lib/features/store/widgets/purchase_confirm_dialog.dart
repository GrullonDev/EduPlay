// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/store/models/store_item.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGold = Color(0xFFFFD700);

/// Confirmation modal shown before a purchase is submitted — either spent
/// immediately or, when [requiresApproval] is true, sent to the child's
/// parent for review. Returns true only if the user tapped the confirm CTA.
Future<bool> showPurchaseConfirmDialog(
  BuildContext context, {
  required StoreItem item,
  required int points,
  required bool requiresApproval,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => _PurchaseConfirmDialog(
          item: item,
          points: points,
          requiresApproval: requiresApproval,
        ),
      ) ??
      false;
}

class _PurchaseConfirmDialog extends StatelessWidget {
  const _PurchaseConfirmDialog({
    required this.item,
    required this.points,
    required this.requiresApproval,
  });

  final StoreItem item;
  final int points;
  final bool requiresApproval;

  String get _categoryLabel {
    switch (item.category) {
      case StoreCategory.avatarColor:
        return 'Color de avatar';
      case StoreCategory.avatarIcon:
        return 'Ícono de avatar';
      case StoreCategory.sticker:
        return 'Sticker exclusivo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = points - item.cost;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _kNavy.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PreviewCircle(item: item),
              const SizedBox(height: 14),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _categoryLabel,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 18),
              _ReceiptCard(item: item, points: points, remaining: remaining),
              const SizedBox(height: 12),
              if (requiresApproval)
                const _InfoBanner(
                  icon: Icons.family_restroom_rounded,
                  color: Color(0xFF7C3AED),
                  text:
                      'Tus papás activaron aprobación de compras. Les enviaremos '
                      'tu solicitud y verás el artículo aquí cuando la aprueben.',
                )
              else
                Text(
                  remaining >= 0
                      ? 'Te quedarán $remaining pts después de comprar.'
                      : 'Todavía no te alcanzan los puntos para esto.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: requiresApproval
                          ? const [Color(0xFF7C3AED), Color(0xFF9C6BF0)]
                          : const [_kNavy, Color(0xFF3A36A0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (requiresApproval ? Colors.deepPurple : _kNavy)
                            .withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            requiresApproval
                                ? Icons.send_rounded
                                : Icons.bolt_rounded,
                            color: _kGold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            requiresApproval
                                ? 'Enviar solicitud a mis papás'
                                : 'Comprar por ${item.cost} pts',
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style:
                      GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(
      {required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A receipt-style breakdown of the purchase — item, balance, and running
/// total — so spending points feels like a real checkout rather than a
/// single "confirm?" tap.
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.item,
    required this.points,
    required this.remaining,
  });

  final StoreItem item;
  final int points;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0DEFF)),
      ),
      child: Column(
        children: [
          _ReceiptRow(label: item.name, value: '${item.cost} pts'),
          const SizedBox(height: 8),
          _ReceiptRow(
            label: 'Tu saldo',
            value: '$points pts',
            muted: true,
          ),
          const SizedBox(height: 10),
          const _DashedDivider(),
          const SizedBox(height: 10),
          _ReceiptRow(
            label: remaining >= 0 ? 'Te quedarán' : 'Te faltan',
            value: '${remaining >= 0 ? remaining : remaining.abs()} pts',
            emphasized: true,
            valueColor: remaining >= 0 ? _kNavy : const Color(0xFFE74C3C),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.muted = false,
    this.emphasized = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool muted;
  final bool emphasized;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.nunito(
      fontSize: emphasized ? 13 : 12,
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
      color: muted ? Colors.grey[500] : _kNavy.withValues(alpha: 0.8),
    );
    final valueStyle = emphasized
        ? GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor ?? _kNavy,
          )
        : GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: muted ? Colors.grey[500] : _kNavy,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child:
              Text(label, style: labelStyle, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 12),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dashWidth + gap)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Padding(
              padding: const EdgeInsets.only(right: gap),
              child: Container(
                width: dashWidth,
                height: 1.4,
                color: const Color(0xFFCFCBF5),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewCircle extends StatelessWidget {
  const _PreviewCircle({required this.item});
  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    if (item.category == StoreCategory.sticker) {
      final sticker = allStickers.firstWhere((s) => s.id == item.id);
      return CircleAvatar(
        radius: 34,
        backgroundColor: sticker.color.withValues(alpha: 0.15),
        child: Icon(sticker.icon, color: sticker.color, size: 34),
      );
    }
    if (item.category == StoreCategory.avatarColor) {
      return CircleAvatar(radius: 34, backgroundColor: item.color);
    }
    return CircleAvatar(
      radius: 34,
      backgroundColor: _kNavy,
      child: Icon(item.icon, color: Colors.white, size: 30),
    );
  }
}
