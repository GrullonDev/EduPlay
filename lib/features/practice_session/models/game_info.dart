// Flutter imports:
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
    name: 'Aventura Matemática',
    description: 'Resuelve acertijos de aritmética y colecciona estrellas',
    icon: Icons.calculate_rounded,
    color: Color(0xFFFF9F43),
    route: '/math-adventure',
    emoji: '🧮',
  ),
  GameInfo(
    id: 'magic-words',
    name: 'Palabras Mágicas',
    description: 'Retos de ortografía y vocabulario',
    icon: Icons.spellcheck_rounded,
    color: Color(0xFF8E44AD),
    route: '/magic-words',
    emoji: '✨',
  ),
  GameInfo(
    id: 'fun-english',
    name: 'Inglés Divertido',
    description: 'Gramática y comprensión lectora',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF2980B9),
    route: '/fun-english',
    emoji: '📖',
  ),
  GameInfo(
    id: 'nature-explorers',
    name: 'Exploradores de la Naturaleza',
    description: 'Descubre ciencias y el mundo natural',
    icon: Icons.eco_rounded,
    color: Color(0xFF27AE60),
    route: '/nature-explorers',
    emoji: '🌿',
  ),
  GameInfo(
    id: 'time-travel',
    name: 'Viaje en el Tiempo',
    description: 'Trivia de historia a través de las épocas',
    icon: Icons.access_time_rounded,
    color: Color(0xFFE67E22),
    route: '/time-travel',
    emoji: '⏳',
  ),
  GameInfo(
    id: 'treasure-map',
    name: 'Mapa del Tesoro',
    description: 'Acertijos de geografía y lectura de mapas',
    icon: Icons.map_rounded,
    color: Color(0xFF16A085),
    route: '/treasure-map',
    emoji: '🗺️',
  ),
  GameInfo(
    id: 'artists-in-action',
    name: 'Artistas en Acción',
    description: 'Arte creativo y pensamiento visual',
    icon: Icons.palette_rounded,
    color: Color(0xFFE91E63),
    route: '/artists-in-action',
    emoji: '🎨',
  ),
  GameInfo(
    id: 'color-concert',
    name: 'Concierto de Colores',
    description: 'Juegos interactivos de música y ritmo',
    icon: Icons.music_note_rounded,
    color: Color(0xFF9B59B6),
    route: '/color-concert',
    emoji: '🎵',
  ),
  GameInfo(
    id: 'sports-challenge',
    name: 'Desafío Deportivo',
    description: 'Educación física y coordinación',
    icon: Icons.sports_soccer_rounded,
    color: Color(0xFF2ECC71),
    route: '/sports-challenge',
    emoji: '⚽',
  ),
  GameInfo(
    id: 'sticker-album',
    name: 'Álbum de Calcomanías',
    description: 'Colecciona calcomanías respondiendo cuestionarios',
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
