import 'package:flutter/material.dart';

enum AgeRange { age6to8, age9to11, age12plus }

enum Difficulty { beginner, intermediate, advanced }

enum GameSubject { all, math, science, history, languages, logic, art, music, sports }

/// Rich game model used by the catalog page.
class CatalogGame {
  const CatalogGame({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.ageRange,
    required this.difficulty,
    required this.level,
    required this.route,
    required this.gradientColors,
    required this.subjectLabel,
    required this.subjectColor,
    required this.icon,
    this.isFeatured = false,
    this.featuredTag,
    this.xpProgress = 0.0,
  });

  final String id;
  final String title;
  final String description;
  final GameSubject subject;
  final AgeRange ageRange;
  final Difficulty difficulty;
  final int level;
  final String route;
  final List<Color> gradientColors;
  final String subjectLabel;
  final Color subjectColor;
  final IconData icon;
  final bool isFeatured;
  final String? featuredTag; // 'GAME OF THE WEEK', 'NEW ARRIVAL', 'TRENDING'
  final double xpProgress; // 0–1

  String get ageLabel {
    switch (ageRange) {
      case AgeRange.age6to8:
        return 'Age 6-8';
      case AgeRange.age9to11:
        return 'Age 9-11';
      case AgeRange.age12plus:
        return 'Age 12+';
    }
  }
}

const _navy = Color(0xFF1E1B6A);
const _red = Color(0xFFC0392B);

/// Full catalog of EduPlay games, enriched for the catalog UI.
final List<CatalogGame> allCatalogGames = [
  CatalogGame(
    id: 'math_adventure',
    title: 'Aventura Matemática',
    description:
        'Derrota a los monstruos con el poder de los números. Álgebra, fracciones y más en una épica aventura.',
    subject: GameSubject.math,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 5,
    route: '/math-adventure',
    gradientColors: [const Color(0xFF1B4332), const Color(0xFF40916C)],
    subjectLabel: 'MATH',
    subjectColor: const Color(0xFF2ECC71),
    icon: Icons.calculate_rounded,
    xpProgress: 0.45,
  ),
  CatalogGame(
    id: 'cell_explorer',
    title: 'Cell Explorer 3D',
    description:
        'Viaja al interior de una célula y descubre los secretos de la vida. Ciencias nunca fue tan emocionante.',
    subject: GameSubject.science,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 8,
    route: '/nature-explorers',
    gradientColors: [const Color(0xFF0D1B2A), const Color(0xFF1B4F72)],
    subjectLabel: 'SCIENCE',
    subjectColor: const Color(0xFF3498DB),
    icon: Icons.biotech_rounded,
    xpProgress: 0.30,
  ),
  CatalogGame(
    id: 'empire_builder',
    title: 'Empire Builder',
    description:
        'Construye civilizaciones desde la Antigüedad hasta la era moderna. Historia en tus manos.',
    subject: GameSubject.history,
    ageRange: AgeRange.age12plus,
    difficulty: Difficulty.advanced,
    level: 12,
    route: '/time-travel',
    gradientColors: [const Color(0xFF3D2B1F), const Color(0xFF7B4F2E)],
    subjectLabel: 'HISTORY',
    subjectColor: const Color(0xFFE67E22),
    icon: Icons.account_balance_rounded,
    isFeatured: true,
    featuredTag: 'GAME OF THE WEEK',
    xpProgress: 0.70,
  ),
  CatalogGame(
    id: 'polyglot_island',
    title: 'Polyglot Island',
    description:
        'Aprende inglés, francés y más idiomas explorando una isla mágica llena de personajes fascinantes.',
    subject: GameSubject.languages,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 4,
    route: '/fun-english',
    gradientColors: [const Color(0xFF0B3D2E), const Color(0xFF1A6B50)],
    subjectLabel: 'LANGUAGES',
    subjectColor: const Color(0xFF1ABC9C),
    icon: Icons.translate_rounded,
    xpProgress: 0.20,
  ),
  CatalogGame(
    id: 'logic_maze',
    title: 'Logic Maze',
    description:
        'Resuelve intrincados puzzles espaciales en 3D que desafían tu razonamiento lógico.',
    subject: GameSubject.logic,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 7,
    route: '/treasure-map',
    gradientColors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
    subjectLabel: 'LOGIC',
    subjectColor: const Color(0xFF9B59B6),
    icon: Icons.extension_rounded,
    isFeatured: true,
    featuredTag: 'NEW ARRIVAL',
    xpProgress: 0.55,
  ),
  CatalogGame(
    id: 'history_hunters',
    title: 'History Hunters',
    description:
        'Viaja en el tiempo a la Antigua Roma y resuelve misterios históricos como un verdadero arqueólogo.',
    subject: GameSubject.history,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 9,
    route: '/time-travel',
    gradientColors: [const Color(0xFF4A3000), const Color(0xFF8B6914)],
    subjectLabel: 'HISTORY',
    subjectColor: const Color(0xFFE67E22),
    icon: Icons.explore_rounded,
    isFeatured: true,
    featuredTag: 'TRENDING',
    xpProgress: 0.60,
  ),
  CatalogGame(
    id: 'color_concert',
    title: 'Concierto de Colores',
    description:
        'Aprende teoría musical creando melodías y composiciones únicas con colores y sonidos.',
    subject: GameSubject.music,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 3,
    route: '/color-concert',
    gradientColors: [const Color(0xFF1A0033), const Color(0xFF6C0096)],
    subjectLabel: 'MUSIC',
    subjectColor: const Color(0xFFE91E63),
    icon: Icons.music_note_rounded,
    xpProgress: 0.15,
  ),
  CatalogGame(
    id: 'sports_challenge',
    title: 'Desafío Deportivo',
    description:
        'Compite en diferentes deportes mientras aprendes física, trabajo en equipo y estrategia.',
    subject: GameSubject.sports,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 6,
    route: '/sports-challenge',
    gradientColors: [const Color(0xFF1B0000), const Color(0xFF7B0000)],
    subjectLabel: 'SPORTS',
    subjectColor: const Color(0xFFE53935),
    icon: Icons.sports_soccer_rounded,
    xpProgress: 0.40,
  ),
  CatalogGame(
    id: 'magic_words',
    title: 'Palabras Mágicas',
    description:
        'Construye vocabulario y comprensión lectora a través de hechizos y conjuros literarios.',
    subject: GameSubject.languages,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 2,
    route: '/magic-words',
    gradientColors: [const Color(0xFF0D0D2B), const Color(0xFF1A1A5E)],
    subjectLabel: 'LANGUAGES',
    subjectColor: const Color(0xFF1ABC9C),
    icon: Icons.auto_stories_rounded,
    xpProgress: 0.85,
  ),
];

/// The three featured games (hero + 2 side cards).
List<CatalogGame> get featuredGames =>
    allCatalogGames.where((g) => g.isFeatured).take(3).toList();
