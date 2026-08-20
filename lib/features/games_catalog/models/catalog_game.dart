// Flutter imports:
import 'package:flutter/material.dart';

enum AgeRange { age6to8, age9to11, age12plus }

AgeRange ageRangeForAge(int age) {
  if (age <= 8) return AgeRange.age6to8;
  if (age <= 11) return AgeRange.age9to11;
  return AgeRange.age12plus;
}

enum Difficulty { beginner, intermediate, advanced }

enum GameSubject {
  all,
  math,
  science,
  history,
  languages,
  logic,
  art,
  music,
  sports
}

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
        return '6-8 años';
      case AgeRange.age9to11:
        return '9-11 años';
      case AgeRange.age12plus:
        return '12+ años';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Principiante';
      case Difficulty.intermediate:
        return 'Intermedio';
      case Difficulty.advanced:
        return 'Avanzado';
    }
  }
}

/// Full catalog of EduPlay games — one honest card per real, playable game.
///
/// Earlier this listed 30 cards for only 10 real routes (e.g. 5 different
/// "planets/dinosaurs/physics/cosmos" cards all opening the same generic
/// icon-matching screen). Descriptions below were verified against each
/// game's actual implementation rather than aspirational copy, so what a
/// card promises is what tapping it actually opens.
final List<CatalogGame> allCatalogGames = [
  const CatalogGame(
    id: 'math_adventure',
    title: 'Aventura Matemática',
    description:
        'Practica sumas y restas —y multiplicación/división en niños mayores— con dificultad que crece de verdad '
        'según tu nivel, y una explicación de cada error antes de seguir.',
    subject: GameSubject.math,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.intermediate,
    level: 1,
    route: '/math-adventure',
    gradientColors: [Color(0xFF1B4332), Color(0xFF40916C)],
    subjectLabel: 'MATEMÁTICAS',
    subjectColor: Color(0xFF2ECC71),
    icon: Icons.calculate_rounded,
    isFeatured: true,
    featuredTag: 'JUEGO DE LA SEMANA',
    xpProgress: 0.20,
  ),
  const CatalogGame(
    id: 'number_ninja',
    title: 'Ninja de los Números',
    description:
        'Decide en segundos si una ecuación de suma o resta es verdadera o falsa. El reloj se acorta y los números '
        'crecen a medida que acumulas puntos.',
    subject: GameSubject.math,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 2,
    route: '/number-ninja',
    gradientColors: [Color(0xFF0F3443), Color(0xFF34E89E)],
    subjectLabel: 'MATEMÁTICAS',
    subjectColor: Color(0xFF2ECC71),
    icon: Icons.bolt_rounded,
    xpProgress: 0.15,
  ),
  const CatalogGame(
    id: 'fun_english',
    title: 'Inglés Divertido',
    description:
        'Vocabulario español-inglés de colores, animales y números. Empiezas solo con colores; animales y números '
        'se desbloquean a medida que sumas puntos.',
    subject: GameSubject.languages,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 3,
    route: '/fun-english',
    gradientColors: [Color(0xFF134E5E), Color(0xFF71B280)],
    subjectLabel: 'IDIOMAS',
    subjectColor: Color(0xFF1ABC9C),
    icon: Icons.translate_rounded,
    xpProgress: 0.20,
  ),
  const CatalogGame(
    id: 'nature_explorers',
    title: 'Exploradores de la Naturaleza',
    description:
        'Encuentra el ícono correcto de un elemento de la naturaleza —animales, plantas, cielo— entre opciones '
        'cada vez más parecidas a medida que subes de nivel.',
    subject: GameSubject.science,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 4,
    route: '/nature-explorers',
    gradientColors: [Color(0xFF0F2027), Color(0xFF203A43)],
    subjectLabel: 'CIENCIAS',
    subjectColor: Color(0xFF3498DB),
    icon: Icons.forest_rounded,
    xpProgress: 0.15,
  ),
  const CatalogGame(
    id: 'treasure_map',
    title: 'Mapa del Tesoro',
    description:
        'Un laberinto de cuadrícula: planifica tu ruta y esquiva obstáculos para llegar al tesoro. El tablero '
        'crece y se llena de más obstáculos en niveles altos.',
    subject: GameSubject.logic,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 5,
    route: '/treasure-map',
    gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    subjectLabel: 'LÓGICA',
    subjectColor: Color(0xFF9B59B6),
    icon: Icons.map_rounded,
    isFeatured: true,
    featuredTag: 'NUEVO',
    xpProgress: 0.25,
  ),
  const CatalogGame(
    id: 'time_travel',
    title: 'Viaje en el Tiempo',
    description:
        'Trivia de cultura general e historia para niños —prehistoria, Egipto, Roma, piratas, inventos— con '
        'preguntas que escalan de fáciles a avanzadas en cada partida.',
    subject: GameSubject.history,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 6,
    route: '/time-travel',
    gradientColors: [Color(0xFF4A3000), Color(0xFF8B6914)],
    subjectLabel: 'HISTORIA',
    subjectColor: Color(0xFFE67E22),
    icon: Icons.explore_rounded,
    isFeatured: true,
    featuredTag: 'TENDENCIA',
    xpProgress: 0.30,
  ),
  const CatalogGame(
    id: 'color_concert',
    title: 'Concierto de Colores',
    description:
        'Memoria musical al estilo "Simón dice": repite la secuencia de notas de colores antes de que se te acabe '
        'el tiempo. Cada ronda suma una nota más y va más rápido.',
    subject: GameSubject.music,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 7,
    route: '/color-concert',
    gradientColors: [Color(0xFF1A0033), Color(0xFF6C0096)],
    subjectLabel: 'MÚSICA',
    subjectColor: Color(0xFFE91E63),
    icon: Icons.music_note_rounded,
    xpProgress: 0.15,
  ),
  const CatalogGame(
    id: 'sports_challenge',
    title: 'Desafío Deportivo',
    description:
        'Pon a prueba tus reflejos: toca los balones apenas aparezcan y evita las tarjetas rojas. La velocidad '
        'sube junto con tu puntaje.',
    subject: GameSubject.sports,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.beginner,
    level: 8,
    route: '/sports-challenge',
    gradientColors: [Color(0xFF1B0000), Color(0xFF7B0000)],
    subjectLabel: 'DEPORTES',
    subjectColor: Color(0xFFE53935),
    icon: Icons.sports_soccer_rounded,
    xpProgress: 0.20,
  ),
  const CatalogGame(
    id: 'magic_words',
    title: 'Palabras Mágicas',
    description:
        'Según tu edad: identifica la letra inicial, completa la letra que falta, o arma la palabra a partir de '
        'letras desordenadas. Desde cierto nivel, se agregan oraciones para completar y ejercitar la comprensión lectora.',
    subject: GameSubject.languages,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 9,
    route: '/magic-words',
    gradientColors: [Color(0xFF0D0D2B), Color(0xFF1A1A5E)],
    subjectLabel: 'IDIOMAS',
    subjectColor: Color(0xFF1ABC9C),
    icon: Icons.auto_stories_rounded,
    xpProgress: 0.20,
  ),
  const CatalogGame(
    id: 'artists_in_action',
    title: 'Artistas en Acción',
    description:
        'Un lienzo de dibujo libre: lápiz, colores, grosor, borrador, calcomanías y deshacer. Práctica creativa '
        'sin niveles ni puntaje, a tu propio ritmo.',
    subject: GameSubject.art,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 10,
    route: '/artists-in-action',
    gradientColors: [Color(0xFF360033), Color(0xFF0B8793)],
    subjectLabel: 'ARTE',
    subjectColor: Color(0xFFE91E63),
    icon: Icons.palette_rounded,
    xpProgress: 0.0,
  ),
];

/// The three featured games (hero + 2 side cards).
List<CatalogGame> get featuredGames =>
    allCatalogGames.where((g) => g.isFeatured).take(3).toList();
