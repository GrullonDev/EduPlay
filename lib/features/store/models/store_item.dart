import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';

/// What a [StoreItem] customizes once purchased.
///
/// [avatarColor] and [avatarIcon] are mutually-exclusive "equip slots" on
/// the student's own avatar circle; [sticker] items just add an entry to
/// the sticker album (no equip step — owning it is the reward).
enum StoreCategory { avatarColor, avatarIcon, sticker }

/// Fixed registry of icon glyphs the store can reference by a short string
/// key instead of a raw [IconData] code point. Firestore-driven catalog
/// items (admin-edited or seeded) store [StoreItem.iconKey] as plain text
/// and look the glyph up here at render time — no `IconData(codePoint, …)`
/// reconstruction, so the app no longer needs `--no-tree-shake-icons`: every
/// icon that can ever appear is a compile-time constant referenced right
/// here, which the tree shaker can see.
///
/// Adding a new store item with a new glyph means adding an entry here too.
const Map<String, IconData> kStoreIconRegistry = {
  'star': Icons.star_rounded,
  'rocket': Icons.rocket_launch_rounded,
  'bolt': Icons.bolt_rounded,
  'sparkle': Icons.auto_awesome_rounded,
  'diamond': Icons.diamond_rounded,
  'crown': Icons.workspace_premium_rounded,
  'dragon_fire': Icons.local_fire_department_rounded,
};

/// Shown for an [StoreItem.iconKey] not present in [kStoreIconRegistry] —
/// e.g. an admin-entered key with a typo, or a key added by a newer app
/// version that this build doesn't know yet — so the store still renders
/// something instead of crashing on a null icon.
const IconData kStoreIconFallback = Icons.card_giftcard_rounded;

/// Resolves a stored icon key to its glyph, falling back to
/// [kStoreIconFallback] for an unknown/missing key.
IconData? iconForKey(String? iconKey) {
  if (iconKey == null) return null;
  return kStoreIconRegistry[iconKey] ?? kStoreIconFallback;
}

/// Reads a Firestore [Timestamp] (the format [StoreItem.toJson] writes) or
/// falls back to parsing an ISO string, for any doc written before this
/// field switched from an RFC3339 string to a native Timestamp.
DateTime? _parseDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cost,
    this.color,
    this.iconKey,
    this.isProOnly = false,
    this.minLevel = 1,
    this.isFeatured = false,
    this.availableFrom,
    this.availableUntil,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: StoreCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => StoreCategory.avatarIcon,
      ),
      cost: (json['cost'] as num).toInt(),
      color:
          json['colorValue'] != null ? Color(json['colorValue'] as int) : null,
      iconKey: json['iconKey'] as String?,
      isProOnly: json['isProOnly'] as bool? ?? false,
      minLevel: (json['minLevel'] as num?)?.toInt() ?? 1,
      isFeatured: json['isFeatured'] as bool? ?? false,
      availableFrom: _parseDate(json['availableFrom']),
      availableUntil: _parseDate(json['availableUntil']),
    );
  }

  final String id;
  final String name;
  final StoreCategory category;
  final int cost;

  /// Set for [StoreCategory.avatarColor] items.
  final Color? color;

  /// Set for [StoreCategory.avatarIcon] and [StoreCategory.sticker] items.
  /// Looked up in [kStoreIconRegistry]; see [icon].
  final String? iconKey;

  /// The resolved glyph for [iconKey] (stickers render via their matching
  /// entry in `allStickers`, but keep the icon here too so store cards
  /// don't need a second lookup).
  IconData? get icon => iconForKey(iconKey);

  /// Whether a PRO subscription is required to buy this item. Authoritative
  /// per-item flag (mirrored into the `storeCatalog` Firestore collection
  /// and re-checked server-side by firestore.rules) rather than a hardcoded
  /// "all stickers" rule, so an admin can mark individual items PRO-only.
  final bool isProOnly;

  /// Minimum student level required to see/buy this item as unlocked.
  /// Level 1 (everyone) by default.
  final int minLevel;

  /// Shown in the "Destacados" highlight strip at the top of the Tienda.
  final bool isFeatured;

  /// Optional seasonal window. Null means "always available" for that
  /// bound. An item outside its window is hidden from the catalog grid.
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  bool get isSeasonal => availableFrom != null || availableUntil != null;

  bool isAvailableAt(DateTime now) {
    if (availableFrom != null && now.isBefore(availableFrom!)) return false;
    if (availableUntil != null && now.isAfter(availableUntil!)) return false;
    return true;
  }

  /// Hex string (no leading `#`/`0x`) suitable for `equippedAvatarColorHex`.
  String get colorHex =>
      color!.toARGB32().toRadixString(16).substring(2).toUpperCase();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'cost': cost,
        if (color != null) 'colorValue': color!.toARGB32(),
        if (iconKey != null) 'iconKey': iconKey,
        'isProOnly': isProOnly,
        'minLevel': minLevel,
        'isFeatured': isFeatured,
        // Stored as a real Firestore Timestamp (not an ISO string) so
        // firestore.rules' isCatalogItemAvailable() can compare it against
        // request.time directly — the rules language has no function to
        // parse a timestamp out of a string.
        if (availableFrom != null)
          'availableFrom': Timestamp.fromDate(availableFrom!.toUtc()),
        if (availableUntil != null)
          'availableUntil': Timestamp.fromDate(availableUntil!.toUtc()),
      };
}

/// Default/seed store catalog — same "hardcoded list" convention as
/// `allStickers` (lib/features/sticker_album/models/sticker.dart) and
/// `catalogGames` (lib/features/games_catalog/models/catalog_game.dart).
/// This list now doubles as the **seed data** for the Firestore
/// `storeCatalog` collection (see `StoreCatalogRepository`): the first time
/// the catalog is read and the collection is empty, these items are written
/// to Firestore so an admin can edit them from then on. If Firestore is
/// unreachable, this static list is also the offline fallback.
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
  const StoreItem(
    id: 'avatar_color_gold',
    name: 'Oro Real',
    category: StoreCategory.avatarColor,
    cost: 90,
    color: Color(0xFFFFC107),
    minLevel: 3,
    isFeatured: true,
  ),

  // ── Avatar icons ─────────────────────────────────────────────────────────
  const StoreItem(
    id: 'avatar_icon_star',
    name: 'Estrella',
    category: StoreCategory.avatarIcon,
    cost: 60,
    iconKey: 'star',
  ),
  const StoreItem(
    id: 'avatar_icon_rocket',
    name: 'Cohete',
    category: StoreCategory.avatarIcon,
    cost: 80,
    iconKey: 'rocket',
    isFeatured: true,
  ),
  const StoreItem(
    id: 'avatar_icon_bolt',
    name: 'Rayo',
    category: StoreCategory.avatarIcon,
    cost: 100,
    iconKey: 'bolt',
  ),
  const StoreItem(
    id: 'avatar_icon_sparkle',
    name: 'Destello',
    category: StoreCategory.avatarIcon,
    cost: 120,
    iconKey: 'sparkle',
    minLevel: 2,
  ),

  // ── Exclusive stickers (ids match Sticker.id in sticker.dart) ───────────
  const StoreItem(
    id: 'unicorn',
    name: 'Unicornio Mágico',
    category: StoreCategory.sticker,
    cost: 150,
    iconKey: 'sparkle',
    isProOnly: true,
  ),
  const StoreItem(
    id: 'diamond',
    name: 'Diamante Brillante',
    category: StoreCategory.sticker,
    cost: 200,
    iconKey: 'diamond',
    isProOnly: true,
    isFeatured: true,
  ),
  const StoreItem(
    id: 'crown',
    name: 'Corona Real',
    category: StoreCategory.sticker,
    cost: 250,
    iconKey: 'crown',
    isProOnly: true,
    minLevel: 4,
  ),
  const StoreItem(
    id: 'dragon',
    name: 'Dragón de Fuego',
    category: StoreCategory.sticker,
    cost: 300,
    iconKey: 'dragon_fire',
    isProOnly: true,
    minLevel: 5,
  ),
];

/// Avatar icon catalog keyed by id, for rendering an equipped icon without
/// re-scanning [allStoreItems] on every avatar build. Built from the static
/// seed list — sufficient for icon lookup even when the live catalog comes
/// from Firestore, since avatar icon ids/glyphs are not expected to change
/// per-admin (only cost/availability are).
final Map<String, IconData> avatarIconsById = {
  for (final item in allStoreItems)
    if (item.category == StoreCategory.avatarIcon) item.id: item.icon!,
};
