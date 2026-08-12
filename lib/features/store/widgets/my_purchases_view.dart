import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/store/bloc/store_bloc.dart';
import 'package:edu_play/features/store/models/purchase_transaction.dart';
import 'package:edu_play/features/store/models/store_item.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGold = Color(0xFFFFD700);

/// Full-screen summary of everything the student has bought — what's
/// equipped, and when it was purchased, plus a spending-history ledger.
/// Reuses the same [StoreBloc] instance the Tienda tab is already showing
/// (pushed on top of it), so equip actions here stay in sync with the
/// store grid underneath.
class MyPurchasesPage extends StatelessWidget {
  const MyPurchasesPage({super.key, required this.storeBloc});

  final StoreBloc storeBloc;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreBloc>.value(
      value: storeBloc,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F5F9),
          appBar: AppBar(
            backgroundColor: _kNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Mis compras',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            bottom: const TabBar(
              indicatorColor: _kGold,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: 'Mis artículos'),
                Tab(text: 'Historial'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _MyPurchasesBody(),
              _TransactionHistoryBody(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPurchasesBody extends StatelessWidget {
  const _MyPurchasesBody();

  @override
  Widget build(BuildContext context) {
    final storeBloc = context.watch<StoreBloc>();
    final catalog = storeBloc.fullCatalog;
    final owned = catalog
        .where(storeBloc.isOwned)
        .toList()
      ..sort((a, b) {
        final dateA = storeBloc.purchaseDateFor(a);
        final dateB = storeBloc.purchaseDateFor(b);
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA); // newest first
      });

    final pending = catalog.where(storeBloc.isPending).toList();

    if (owned.isEmpty && pending.isEmpty) {
      return const _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pending.isNotEmpty) ...[
          Text(
            'Esperando aprobación',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in pending) _PendingTile(item: item),
          const SizedBox(height: 24),
        ],
        if (owned.isNotEmpty) ...[
          Text(
            '${owned.length} artículo${owned.length == 1 ? '' : 's'} comprado${owned.length == 1 ? '' : 's'}',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in owned) _PurchaseTile(item: item),
        ],
      ],
    );
  }
}

class _TransactionHistoryBody extends StatelessWidget {
  const _TransactionHistoryBody();

  @override
  Widget build(BuildContext context) {
    final storeBloc = context.watch<StoreBloc>();
    return FutureBuilder<List<PurchaseTransaction>>(
      future: storeBloc.dashboardBloc.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kNavy));
        }
        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Todavía no hay compras en tu historial.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, i) => _TransactionTile(transaction: transactions[i]),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final PurchaseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.itemName,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM yyyy, HH:mm', 'es').format(transaction.createdAt),
                  style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[400]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.balanceBefore} → ${transaction.balanceAfter} pts',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${transaction.cost} pts',
            style: GoogleFonts.fredoka(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 56, color: Colors.grey[350]),
            const SizedBox(height: 12),
            Text(
              'Todavía no has comprado nada',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Visita la Tienda y usa tus puntos para personalizarte.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({required this.item});
  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _ItemPreview(item: item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Esperando que tus papás la aprueben',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF7C3AED),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.hourglass_top_rounded, color: Color(0xFF7C3AED), size: 20),
        ],
      ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({required this.item});
  final StoreItem item;

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
    final storeBloc = context.watch<StoreBloc>();
    final equipped = storeBloc.isEquipped(item);
    final canEquip = item.category != StoreCategory.sticker && !equipped;
    final date = storeBloc.purchaseDateFor(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: equipped ? _kGold : Colors.black12,
          width: equipped ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          _ItemPreview(item: item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  _categoryLabel,
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
                ),
                if (date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Comprado el ${DateFormat('d MMM yyyy', 'es').format(date)}',
                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ],
            ),
          ),
          if (equipped)
            const _StatusChip(text: 'Equipado', color: Colors.green)
          else if (item.category == StoreCategory.sticker)
            const _StatusChip(text: 'En tu álbum', color: Colors.green)
          else if (canEquip)
            OutlinedButton(
              onPressed: () => storeBloc.equip(item),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kNavy,
                side: const BorderSide(color: _kNavy),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Equipar', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
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
        radius: 22,
        backgroundColor: sticker.color.withValues(alpha: 0.15),
        child: Icon(sticker.icon, color: sticker.color, size: 22),
      );
    }
    if (item.category == StoreCategory.avatarColor) {
      return CircleAvatar(radius: 22, backgroundColor: item.color);
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: _kNavy,
      child: Icon(item.icon, color: Colors.white, size: 20),
    );
  }
}
