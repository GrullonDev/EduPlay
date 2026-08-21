// Flutter imports:
import 'package:flutter/material.dart';

class Sticker {
  const Sticker({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    this.isPremium = false,
  });
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  /// True for store-exclusive stickers (only obtainable via a Tienda
  /// purchase, id matches the corresponding StoreItem.id).
  final bool isPremium;
}

// Static list of all available stickers
final List<Sticker> allStickers = [
  const Sticker(
      id: 'dino',
      name: 'Dino Rex',
      icon: Icons.pets,
      color: Colors.green,
      description: 'Rey de los dinos'),
  const Sticker(
      id: 'rocket',
      name: 'Cohete Veloz',
      icon: Icons.rocket_launch,
      color: Colors.red,
      description: 'Viaja a las estrellas'),
  const Sticker(
      id: 'treasure',
      name: 'Cofre de Oro',
      icon: Icons.inventory_2,
      color: Colors.amber,
      description: '¡Riquezas piratas!'),
  const Sticker(
      id: 'star',
      name: 'Super Estrella',
      icon: Icons.star,
      color: Colors.yellow,
      description: 'Brillas mucho'),
  const Sticker(
      id: 'music',
      name: 'Nota Musical',
      icon: Icons.music_note,
      color: Colors.blue,
      description: 'Do Re Mi Fa Sol'),
  const Sticker(
      id: 'ball',
      name: 'Balón de Oro',
      icon: Icons.sports_soccer,
      color: Colors.white,
      description: 'Goleador nato'),
  const Sticker(
      id: 'painter',
      name: 'Pincel Mágico',
      icon: Icons.brush,
      color: Colors.purple,
      description: 'Artista creativo'),
  const Sticker(
      id: 'book',
      name: 'Libro Sabio',
      icon: Icons.menu_book,
      color: Colors.brown,
      description: 'Lector experto'),
  // ── Premium (Tienda-only) ──────────────────────────────────────────────
  const Sticker(
      id: 'unicorn',
      name: 'Unicornio Mágico',
      icon: Icons.auto_awesome_rounded,
      color: Colors.pinkAccent,
      description: 'Brilla con magia',
      isPremium: true),
  const Sticker(
      id: 'diamond',
      name: 'Diamante Brillante',
      icon: Icons.diamond_rounded,
      color: Colors.cyan,
      description: 'El tesoro más raro',
      isPremium: true),
  const Sticker(
      id: 'crown',
      name: 'Corona Real',
      icon: Icons.workspace_premium_rounded,
      color: Colors.amber,
      description: 'Para todo un campeón',
      isPremium: true),
  const Sticker(
      id: 'dragon',
      name: 'Dragón de Fuego',
      icon: Icons.local_fire_department_rounded,
      color: Colors.deepOrange,
      description: 'Guardián legendario',
      isPremium: true),
];

/// Stickers unlock one per level gained past level 1, capped at the list
/// length. Level 1 (0 pts) = 0 stickers. Do not reorder/remove entries in
/// [allStickers] — that would silently change which stickers a child at a
/// given level has "earned".
List<Sticker> stickersUnlockedAtLevel(int level) =>
    allStickers.take((level - 1).clamp(0, allStickers.length)).toList();
