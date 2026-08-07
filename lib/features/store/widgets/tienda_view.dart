import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/store/bloc/store_bloc.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGold = Color(0xFFFFD700);

/// The "Tienda" dashboard tab — a student spends their gamification points
/// on avatar cosmetics and exclusive stickers. Owns its own [StoreBloc] but
/// reads/writes through [dashboardBloc] so the points badge and sticker
/// album elsewhere in the dashboard stay in sync after a purchase.
class TiendaView extends StatefulWidget {
  const TiendaView({super.key, required this.bloc, required this.s});
  final StudentDashboardBloc bloc;
  final ScreenSize s;

  @override
  State<TiendaView> createState() => _TiendaViewState();
}

class _TiendaViewState extends State<TiendaView> {
  late final StoreBloc _storeBloc;

  @override
  void initState() {
    super.initState();
    _storeBloc = StoreBloc(dashboardBloc: widget.bloc);
  }

  @override
  void dispose() {
    _storeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreBloc>.value(
      value: _storeBloc,
      child: _TiendaBody(s: widget.s),
    );
  }
}

class _TiendaBody extends StatelessWidget {
  const _TiendaBody({required this.s});
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final storeBloc = context.watch<StoreBloc>();
    final avatarColors = allStoreItems
        .where((i) => i.category == StoreCategory.avatarColor)
        .toList();
    final avatarIcons = allStoreItems
        .where((i) => i.category == StoreCategory.avatarIcon)
        .toList();
    final stickers = allStoreItems
        .where((i) => i.category == StoreCategory.sticker)
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00897B), Color(0xFF26A69A)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    s.isMobile ? 20 : 28, 20, s.isMobile ? 20 : 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🛍️ Tienda',
                      style: GoogleFonts.fredoka(
                        fontSize: s.isMobile ? 22 : 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Usa tus puntos para personalizarte',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StorePointsPill(points: storeBloc.points),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _StoreSection(title: 'Colores de avatar', items: avatarColors),
              const SizedBox(height: 24),
              _StoreSection(title: 'Íconos de avatar', items: avatarIcons),
              const SizedBox(height: 24),
              _StoreSection(
                  title: 'Stickers exclusivos ⭐', items: stickers),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StorePointsPill extends StatelessWidget {
  const _StorePointsPill({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: _kGold, size: 18),
          const SizedBox(width: 6),
          Text(
            '$points pts disponibles',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreSection extends StatelessWidget {
  const _StoreSection({required this.title, required this.items});
  final String title;
  final List<StoreItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) => _StoreItemCard(item: item)).toList(),
        ),
      ],
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  const _StoreItemCard({required this.item});
  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    final storeBloc = context.watch<StoreBloc>();
    final owned = storeBloc.isOwned(item);
    final equipped = storeBloc.isEquipped(item);

    return Container(
      width: 136,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: equipped ? _kGold : Colors.black12,
          width: equipped ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ItemPreview(item: item),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 8),
          _ActionButton(item: item, owned: owned, equipped: equipped),
        ],
      ),
    );
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({required this.item});
  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    if (item.category == StoreCategory.sticker) {
      final sticker = allStickers.firstWhere((s) => s.id == item.id);
      return CircleAvatar(
        radius: 26,
        backgroundColor: sticker.color.withValues(alpha: 0.15),
        child: Icon(sticker.icon, color: sticker.color, size: 26),
      );
    }
    if (item.category == StoreCategory.avatarColor) {
      return CircleAvatar(radius: 26, backgroundColor: item.color);
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: _kNavy,
      child: Icon(item.icon, color: Colors.white, size: 24),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.item,
    required this.owned,
    required this.equipped,
  });
  final StoreItem item;
  final bool owned;
  final bool equipped;

  @override
  Widget build(BuildContext context) {
    final storeBloc = context.watch<StoreBloc>();

    if (owned && item.category == StoreCategory.sticker) {
      return const _StaticLabel(text: '✓ En tu álbum', color: Colors.green);
    }
    if (owned && equipped) {
      return const _StaticLabel(text: '✓ Equipado', color: Colors.green);
    }
    if (owned) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: storeBloc.isBusy ? null : () => storeBloc.equip(item),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kNavy,
            side: const BorderSide(color: _kNavy),
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Equipar', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    final canAfford = storeBloc.points >= item.cost;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: storeBloc.isBusy || !canAfford
            ? null
            : () async {
                final ok = await storeBloc.purchase(item);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        storeBloc.lastError ?? 'No se pudo comprar.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: canAfford ? _kNavy : Colors.grey[300],
          foregroundColor: canAfford ? Colors.white : Colors.grey[600],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded,
                size: 14, color: canAfford ? _kGold : Colors.grey[500]),
            const SizedBox(width: 4),
            Text('${item.cost}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StaticLabel extends StatelessWidget {
  const _StaticLabel({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
