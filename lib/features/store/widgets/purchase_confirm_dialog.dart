import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, color: _kGold, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${item.cost} pts',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
              ),
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
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: requiresApproval ? Colors.deepPurple : _kNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    requiresApproval
                        ? 'Enviar solicitud a mis papás'
                        : 'Comprar por ${item.cost} pts',
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
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
  const _InfoBanner({required this.icon, required this.color, required this.text});
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
