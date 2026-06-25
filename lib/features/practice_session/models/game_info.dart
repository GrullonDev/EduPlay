import 'package:flutter/material.dart';

/// Catalog entry for a game that can be assigned to a practice session.
class GameInfo {
  const GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.emoji,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  /// Named route used to open this game (e.g. RouterPaths.mathAdventure).
  final String route;

  /// Decorative emoji for the card.
  final String emoji;
}

/// Full catalog of available games. IDs match router route names (without leading `/`).
const kGameCatalog = <GameInfo>[
  GameInfo(
    id: 'math-adventure',
    name: 'Math Adventure',
    description: 'Solve arithmetic puzzles & collect stars',
    icon: Icons.calculate_rounded,
    color: Color(0xFFFF9F43),
    route: '/math-adventure',
    emoji: '🧮',
  ),
  GameInfo(
    id: 'magic-words',
    name: 'Magic Words',
    description: 'Spelling & vocabulary challenges',
    icon: Icons.spellcheck_rounded,
    color: Color(0xFF8E44AD),
    route: '/magic-words',
    emoji: '✨',
  ),
  GameInfo(
    id: 'fun-english',
    name: 'Fun English',
    description: 'Grammar & reading comprehension',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF2980B9),
    route: '/fun-english',
    emoji: '📖',
  ),
  GameInfo(
    id: 'nature-explorers',
    name: 'Nature Explorers',
    description: 'Discover science & the natural world',
    icon: Icons.eco_rounded,
    color: Color(0xFF27AE60),
    route: '/nature-explorers',
    emoji: '🌿',
  ),
  GameInfo(
    id: 'time-travel',
    name: 'Time Travel',
    description: 'History trivia across the ages',
    icon: Icons.access_time_rounded,
    color: Color(0xFFE67E22),
    route: '/time-travel',
    emoji: '⏳',
  ),
  GameInfo(
    id: 'treasure-map',
    name: 'Treasure Map',
    description: 'Geography & map reading puzzles',
    icon: Icons.map_rounded,
    color: Color(0xFF16A085),
    route: '/treasure-map',
    emoji: '🗺️',
  ),
  GameInfo(
    id: 'artists-in-action',
    name: 'Artists in Action',
    description: 'Creative arts & visual thinking',
    icon: Icons.palette_rounded,
    color: Color(0xFFE91E63),
    route: '/artists-in-action',
    emoji: '🎨',
  ),
  GameInfo(
    id: 'color-concert',
    name: 'Color Concert',
    description: 'Music & rhythm interactive games',
    icon: Icons.music_note_rounded,
    color: Color(0xFF9B59B6),
    route: '/color-concert',
    emoji: '🎵',
  ),
  GameInfo(
    id: 'sports-challenge',
    name: 'Sports Challenge',
    description: 'Physical education & coordination',
    icon: Icons.sports_soccer_rounded,
    color: Color(0xFF2ECC71),
    route: '/sports-challenge',
    emoji: '⚽',
  ),
  GameInfo(
    id: 'sticker-album',
    name: 'Sticker Album',
    description: 'Collect stickers by answering quizzes',
    icon: Icons.collections_rounded,
    color: Color(0xFFF39C12),
    route: '/sticker-album',
    emoji: '⭐',
  ),
];

GameInfo? gameById(String id) {
  try {
    return kGameCatalog.firstWhere((g) => g.id == id);
  } catch (_) {
    return null;
  }
}
