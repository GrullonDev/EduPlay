import 'package:flutter/material.dart';

/// What a [StoreItem] customizes once purchased.
///
/// [avatarColor] and [avatarIcon] are mutually-exclusive "equip slots" on
/// the student's own avatar circle; [sticker] items just add an entry to
/// the sticker album (no equip step — owning it is the reward).
enum StoreCategory { avatarColor, avatarIcon, sticker }

class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cost,
    this.color,
    this.icon,
  });

  final String id;
  final String name;
  final StoreCategory category;
  final int cost;

  /// Set for [StoreCategory.avatarColor] items.
  final Color? color;

  /// Set for [StoreCategory.avatarIcon] and [StoreCategory.sticker] items
  /// (stickers render via their matching entry in `allStickers`, but keep
  /// the icon here too so store cards don't need a second lookup).
  final IconData? icon;

  /// Hex string (no leading `#`/`0x`) suitable for `equippedAvatarColorHex`.
  String get colorHex =>
      color!.toARGB32().toRadixString(16).substring(2).toUpperCase();
}

/// Static store catalog — same "hardcoded list, no backend" convention as
/// `allStickers` (lib/features/sticker_album/models/sticker.dart) and
/// `catalogGames` (lib/features/games_catalog/models/catalog_game.dart).
///
/// Avatar item ids are namespaced (`avatar_color_*` / `avatar_icon_*`) so
/// they can share the same `ownedItemIds` array as sticker ids without
/// collisions. Sticker items intentionally reuse the matching `Sticker.id`
/// (see sticker.dart) so a purchase and an album unlock are the same id.
final List<StoreItem> allStoreItems = [
  // ── Avatar colors ────────────────────────────────────────────────────────
  const StoreItem(
    id: 'avatar_color_ruby',
    name: 'Rubí',
    category: StoreCategory.avatarColor,
    cost: 40,
    color: Color(0xFFE53935),
  ),
  const StoreItem(
    id: 'avatar_color_emerald',
    name: 'Esmeralda',
    category: StoreCategory.avatarColor,
    cost: 40,
    color: Color(0xFF00C853),
  ),
  const StoreItem(
    id: 'avatar_color_sapphire',
    name: 'Zafiro',
    category: StoreCategory.avatarColor,
    cost: 40,
    color: Color(0xFF2962FF),
  ),
  const StoreItem(
    id: 'avatar_color_amber',
    name: 'Ámbar',
    category: StoreCategory.avatarColor,
    cost: 40,
    color: Color(0xFFFFAB00),
  ),

  // ── Avatar icons ─────────────────────────────────────────────────────────
  const StoreItem(
    id: 'avatar_icon_star',
    name: 'Estrella',
    category: StoreCategory.avatarIcon,
    cost: 60,
    icon: Icons.star_rounded,
  ),
  const StoreItem(
    id: 'avatar_icon_rocket',
    name: 'Cohete',
    category: StoreCategory.avatarIcon,
    cost: 80,
    icon: Icons.rocket_launch_rounded,
  ),
  const StoreItem(
    id: 'avatar_icon_bolt',
    name: 'Rayo',
    category: StoreCategory.avatarIcon,
    cost: 100,
    icon: Icons.bolt_rounded,
  ),
  const StoreItem(
    id: 'avatar_icon_sparkle',
    name: 'Destello',
    category: StoreCategory.avatarIcon,
    cost: 120,
    icon: Icons.auto_awesome_rounded,
  ),

  // ── Exclusive stickers (ids match Sticker.id in sticker.dart) ───────────
  const StoreItem(
    id: 'unicorn',
    name: 'Unicornio Mágico',
    category: StoreCategory.sticker,
    cost: 150,
    icon: Icons.auto_awesome_rounded,
  ),
  const StoreItem(
    id: 'diamond',
    name: 'Diamante Brillante',
    category: StoreCategory.sticker,
    cost: 200,
    icon: Icons.diamond_rounded,
  ),
  const StoreItem(
    id: 'crown',
    name: 'Corona Real',
    category: StoreCategory.sticker,
    cost: 250,
    icon: Icons.workspace_premium_rounded,
  ),
  const StoreItem(
    id: 'dragon',
    name: 'Dragón de Fuego',
    category: StoreCategory.sticker,
    cost: 300,
    icon: Icons.local_fire_department_rounded,
  ),
];

/// Avatar icon catalog keyed by id, for rendering an equipped icon without
/// re-scanning [allStoreItems] on every avatar build.
final Map<String, IconData> avatarIconsById = {
  for (final item in allStoreItems)
    if (item.category == StoreCategory.avatarIcon) item.id: item.icon!,
};
