import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/core/analytics/analytics_service.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/store/bloc/store_bloc.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/store/widgets/avatar_preview_dialog.dart';
import 'package:edu_play/features/store/widgets/my_purchases_view.dart';
import 'package:edu_play/features/store/widgets/purchase_confirm_dialog.dart';
import 'package:edu_play/features/store/widgets/purchase_success_overlay.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/shared/widgets/upgrade_prompt_dialog.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

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
    AnalyticsService.logStoreView();
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
    final available = storeBloc.availableCatalog;
    final filtered = storeBloc.filterItems(available);
    final avatarColors =
        filtered.where((i) => i.category == StoreCategory.avatarColor).toList();
    final avatarIcons =
        filtered.where((i) => i.category == StoreCategory.avatarIcon).toList();
    final stickers =
        filtered.where((i) => i.category == StoreCategory.sticker).toList();
    final isEmpty = avatarColors.isEmpty && avatarIcons.isEmpty && stickers.isEmpty;
    final showFeatured =
        storeBloc.filter == StoreFilter.all && storeBloc.featuredItems.isNotEmpty;

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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
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
                            ],
                          ),
                        ),
                        _MyPurchasesButton(storeBloc: storeBloc),
                      ],
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
              if (!storeBloc.catalogLoaded) ...[
                const _CatalogLoadingBanner(),
                const SizedBox(height: 16),
              ] else if (storeBloc.catalogHasError) ...[
                _CatalogErrorBanner(onRetry: storeBloc.retryCatalogLoad),
                const SizedBox(height: 16),
              ],
              if (storeBloc.dashboardBloc.isGuest) ...[
                _GuestStoreLimitBanner(
                  remaining: storeBloc.guestPurchasesRemaining,
                ),
                const SizedBox(height: 16),
              ],
              if (storeBloc.requiresApproval && !storeBloc.dashboardBloc.isGuest) ...[
                const _ApprovalRequiredBanner(),
                const SizedBox(height: 16),
              ],
              if (storeBloc.spendLimitEnabled) ...[
                _SpendLimitBanner(storeBloc: storeBloc),
                const SizedBox(height: 16),
              ],
              if (showFeatured) ...[
                _FeaturedSection(items: storeBloc.featuredItems),
                const SizedBox(height: 24),
              ],
              const _FilterChipsRow(),
              const SizedBox(height: 20),
              if (isEmpty)
                const _EmptyFilterState()
              else ...[
                if (avatarColors.isNotEmpty) ...[
                  _StoreSection(title: 'Colores de avatar', items: avatarColors),
                  const SizedBox(height: 24),
                ],
                if (avatarIcons.isNotEmpty) ...[
                  _StoreSection(title: 'Íconos de avatar', items: avatarIcons),
                  const SizedBox(height: 24),
                ],
                if (stickers.isNotEmpty)
                  _StoreSection(title: 'Stickers exclusivos ⭐', items: stickers),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _MyPurchasesButton extends StatelessWidget {
  const _MyPurchasesButton({required this.storeBloc});
  final StoreBloc storeBloc;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Mis compras',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MyPurchasesPage(storeBloc: storeBloc)),
      ),
      icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        shape: const CircleBorder(),
      ),
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

class _GuestStoreLimitBanner extends StatelessWidget {
  const _GuestStoreLimitBanner({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final reached = remaining <= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: reached ? const Color(0xFFFFEBEE) : const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reached ? const Color(0xFFE53935) : const Color(0xFF00897B),
        ),
      ),
      child: Row(
        children: [
          Icon(
            reached ? Icons.lock_outline_rounded : Icons.shopping_bag_rounded,
            color: reached ? const Color(0xFFE53935) : const Color(0xFF00897B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reached
                  ? 'Ya compraste tus 3 productos de prueba. Regístrate para seguir comprando.'
                  : 'Modo invitado: puedes comprar $remaining producto${remaining == 1 ? '' : 's'} más antes de registrarte.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: reached ? const Color(0xFF7F1D1D) : _kNavy,
              ),
            ),
          ),
          if (reached) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                RouterPaths.registerParents,
              ),
              child: const Text('Registrarse'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApprovalRequiredBanner extends StatelessWidget {
  const _ApprovalRequiredBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.family_restroom_rounded, color: Color(0xFF7C3AED)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tus papás revisan tus compras antes de que se hagan. Cuando compres algo, esperarás su aprobación.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5B21B6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendLimitBanner extends StatelessWidget {
  const _SpendLimitBanner({required this.storeBloc});
  final StoreBloc storeBloc;

  @override
  Widget build(BuildContext context) {
    final bloc = storeBloc.dashboardBloc;
    final reached = bloc.spendLimitReached;
    final periodLabel =
        bloc.spendLimitPeriod.windowDays == 1 ? 'hoy' : 'esta semana';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: reached ? const Color(0xFFFFF3E0) : const Color(0xFFF3F5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reached ? const Color(0xFFEF6C00) : const Color(0xFF3D3AA0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.savings_rounded,
            color: reached ? const Color(0xFFEF6C00) : const Color(0xFF3D3AA0),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reached
                  ? 'Llegaste al límite de gasto de tus papás para $periodLabel.'
                  : 'Puedes gastar hasta ${storeBloc.spendLimitRemaining} pts más $periodLabel (límite de tus papás).',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: reached ? const Color(0xFF7A3E00) : _kNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogLoadingBanner extends StatelessWidget {
  const _CatalogLoadingBanner();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: _kNavy),
        ),
        const SizedBox(width: 10),
        Text(
          'Cargando catálogo…',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _CatalogErrorBanner extends StatelessWidget {
  const _CatalogErrorBanner({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF6C00)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFEF6C00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No pudimos actualizar la tienda. Mostrando el catálogo guardado.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7A3E00),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

// ── Featured ─────────────────────────────────────────────────────────────────

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.items});
  final List<StoreItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department_rounded,
                color: Color(0xFFFF6E6C), size: 18),
            const SizedBox(width: 6),
            Text(
              'Destacados',
              style: GoogleFonts.fredoka(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _StoreItemCard(item: items[i]),
          ),
        ),
      ],
    );
  }
}

// ── Filters ──────────────────────────────────────────────────────────────────

class _FilterOption {
  const _FilterOption(this.filter, this.label, this.icon);
  final StoreFilter filter;
  final String label;
  final IconData icon;
}

const _filterOptions = [
  _FilterOption(StoreFilter.all, 'Todos', Icons.apps_rounded),
  _FilterOption(StoreFilter.avatarColor, 'Colores', Icons.palette_rounded),
  _FilterOption(StoreFilter.avatarIcon, 'Íconos', Icons.emoji_emotions_rounded),
  _FilterOption(StoreFilter.sticker, 'Stickers', Icons.auto_awesome_rounded),
  _FilterOption(StoreFilter.pro, 'PRO', Icons.workspace_premium_rounded),
  _FilterOption(StoreFilter.owned, 'Comprados', Icons.check_circle_rounded),
];

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context) {
    final storeBloc = context.watch<StoreBloc>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filterOptions.map((option) {
        final selected = storeBloc.filter == option.filter;
        return GestureDetector(
          onTap: () => storeBloc.setFilter(option.filter),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _kNavy : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? _kNavy : Colors.black12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.icon,
                  size: 14,
                  color: selected ? Colors.white : _kNavy,
                ),
                const SizedBox(width: 6),
                Text(
                  option.label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _kNavy,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: Colors.grey[350]),
            const SizedBox(height: 10),
            Text(
              'No hay productos en este filtro todavía.',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Catalog sections ──────────────────────────────────────────────────────────

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
    final pending = storeBloc.isPending(item);
    final proOnly = storeBloc.isProOnly(item);
    final levelLocked = storeBloc.isLevelLocked(item);
    final locked = !owned &&
        !pending &&
        (!storeBloc.canAccess(item) || storeBloc.guestLimitReached);

    Color cardColor = Colors.white;
    if (equipped) {
      cardColor = _kGold.withValues(alpha: 0.06);
    } else if (owned) {
      cardColor = const Color(0xFF2ECC71).withValues(alpha: 0.05);
    } else if (pending) {
      cardColor = const Color(0xFF7C3AED).withValues(alpha: 0.05);
    }

    return Container(
      width: 136,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: locked ? 0.5 : 1,
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
                if (item.isSeasonal) ...[
                  const SizedBox(height: 2),
                  Text(
                    '⏳ Por tiempo limitado',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF6C00),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _ActionButton(
                  item: item,
                  owned: owned,
                  equipped: equipped,
                  pending: pending,
                ),
              ],
            ),
          ),
          if (proOnly)
            Positioned(top: -6, right: -6, child: _ProBadge()),
          if (locked && levelLocked)
            Positioned(
              top: 4,
              left: 4,
              child: _LevelLockBadge(minLevel: item.minLevel),
            )
          else if (locked)
            const Positioned(
              top: 4,
              left: 4,
              child: Icon(Icons.lock_rounded, size: 16, color: _kNavy),
            ),
        ],
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _kGold,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 10, color: _kNavy),
          const SizedBox(width: 2),
          Text(
            'PRO',
            style: GoogleFonts.fredoka(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelLockBadge extends StatelessWidget {
  const _LevelLockBadge({required this.minLevel});
  final int minLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'Nv.$minLevel',
            style: GoogleFonts.fredoka(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
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
      final sticker = allStickers.firstWhere(
        (s) => s.id == item.id,
        orElse: () => Sticker(
          id: item.id,
          name: item.name,
          icon: item.icon ?? Icons.star_rounded,
          color: _kNavy,
          description: item.name,
        ),
      );
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

// ── Purchase CTA / locked-state helpers ───────────────────────────────────────

Future<void> _showGuestNeedsAccountDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Crea una cuenta',
        style: GoogleFonts.fredoka(color: _kNavy, fontSize: 18),
      ),
      content: Text(
        'Los stickers exclusivos son solo para miembros Pro. Regístrate primero '
        'para poder mejorar tu cuenta a Pro.',
        style: GoogleFonts.nunito(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Ahora no'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _kNavy),
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(context, RouterPaths.registerParents);
          },
          child: const Text('Registrarse', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Future<void> _handleProLockedTap(BuildContext context, StoreBloc storeBloc) async {
  if (storeBloc.dashboardBloc.isGuest) {
    await _showGuestNeedsAccountDialog(context);
    return;
  }
  final wantsUpgrade = await showUpgradePrompt(context, UpgradeReason.proSticker);
  if (wantsUpgrade && context.mounted) {
    Navigator.pushNamed(context, RouterPaths.settings);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.pending,
  });
  final StoreItem item;
  final bool owned;
  final bool equipped;
  final bool pending;

  Future<void> _handleBuy(BuildContext context, StoreBloc storeBloc) async {
    final requiresApproval =
        storeBloc.requiresApproval && !storeBloc.dashboardBloc.isGuest;
    final confirmed = await showPurchaseConfirmDialog(
      context,
      item: item,
      points: storeBloc.points,
      requiresApproval: requiresApproval,
    );
    if (!confirmed) return;

    final outcome = await storeBloc.purchase(item);
    if (!context.mounted) return;

    switch (outcome) {
      case PurchaseOutcome.success:
        await showPurchaseSuccessCelebration(context, itemName: item.name);
      case PurchaseOutcome.pendingApproval:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storeBloc.lastInfo ?? 'Solicitud enviada a tus papás.'),
            backgroundColor: const Color(0xFF7C3AED),
            duration: const Duration(seconds: 3),
          ),
        );
      case PurchaseOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storeBloc.lastError ?? 'No se pudo comprar.'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  Future<void> _handleEquip(BuildContext context, StoreBloc storeBloc) async {
    final confirmed = await showAvatarPreviewDialog(
      context,
      storeBloc: storeBloc,
      item: item,
    );
    if (confirmed && context.mounted) {
      await storeBloc.equip(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeBloc = context.watch<StoreBloc>();

    if (pending) {
      return const _StaticLabel(text: '⏳ Esperando aprobación', color: Color(0xFF7C3AED));
    }
    if (owned && item.category == StoreCategory.sticker) {
      return const _StaticLabel(text: '✓ En tu álbum', color: Colors.green);
    }
    if (owned && equipped) {
      return Column(
        children: [
          const _StaticLabel(text: '✓ Equipado', color: Colors.green),
          TextButton(
            onPressed: storeBloc.isBusy
                ? null
                : () => storeBloc.unequip(
                      color: item.category == StoreCategory.avatarColor,
                      icon: item.category == StoreCategory.avatarIcon,
                    ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Quitar',
              style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey[500]),
            ),
          ),
        ],
      );
    }
    if (owned) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: storeBloc.isBusy ? null : () => _handleEquip(context, storeBloc),
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

    if (storeBloc.isLevelLocked(item)) {
      return _StaticLabel(
        text: 'Nivel ${item.minLevel} requerido',
        color: _kNavy,
      );
    }

    if (!storeBloc.canAccess(item)) {
      return GestureDetector(
        onTap: () => _handleProLockedTap(context, storeBloc),
        child: const _StaticLabel(text: 'Solo PRO · Toca para saber más', color: Color(0xFF7C3AED)),
      );
    }

    if (storeBloc.guestLimitReached) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            RouterPaths.registerParents,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kNavy,
            side: const BorderSide(color: _kNavy),
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Registrarse', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    final canAfford = storeBloc.points >= item.cost;
    final overSpendLimit = storeBloc.wouldExceedSpendLimit(item);
    final canPurchase = storeBloc.canPurchase(item);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: storeBloc.isBusy || !canPurchase
                ? null
                : () => _handleBuy(context, storeBloc),
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford && !overSpendLimit ? _kNavy : Colors.grey[300],
              foregroundColor: canAfford && !overSpendLimit ? Colors.white : Colors.grey[600],
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded,
                    size: 14,
                    color: canAfford && !overSpendLimit ? _kGold : Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${item.cost}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
        if (!canAfford) ...[
          const SizedBox(height: 4),
          Text(
            'Te faltan ${item.cost - storeBloc.points} pts',
            style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey[500]),
          ),
        ] else if (overSpendLimit) ...[
          const SizedBox(height: 4),
          Text(
            'Supera tu límite de gasto',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
