import 'package:flutter/material.dart';

enum AgeRange { age6to8, age9to11, age12plus }

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

// ── NEW GAMES ─────────────────────────────────────────────────────────────────
// Beginner 6-8 (+1 → total 5)

const CatalogGame _numberNinja = CatalogGame(
  id: 'number_ninja',
  title: 'Ninja de los Números',
  description:
      'Domina las operaciones básicas con velocidad y precisión. ¡Conviértete en el maestro de los números!',
  subject: GameSubject.math,
  ageRange: AgeRange.age6to8,
  difficulty: Difficulty.beginner,
  level: 2,
  route: '/math-adventure',
  gradientColors: [Color(0xFF0F3443), Color(0xFF34E89E)],
  subjectLabel: 'MATEMÁTICAS',
  subjectColor: Color(0xFF2ECC71),
  icon: Icons.calculate_rounded,
  xpProgress: 0.30,
);

// Beginner 9-11 (+5 → total 5)

const CatalogGame _wordSafari = CatalogGame(
  id: 'word_safari',
  title: 'Safari de Palabras',
  description:
      'Explora la jungla del lenguaje, aprende vocabulario en inglés y español mientras dominas a los animales.',
  subject: GameSubject.languages,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.beginner,
  level: 4,
  route: '/fun-english',
  gradientColors: [Color(0xFF134E5E), Color(0xFF71B280)],
  subjectLabel: 'IDIOMAS',
  subjectColor: Color(0xFF1ABC9C),
  icon: Icons.translate_rounded,
  xpProgress: 0.40,
);

const CatalogGame _planetPuzzles = CatalogGame(
  id: 'planet_puzzles',
  title: 'Puzzles Planetarios',
  description:
      'Arma el sistema solar pieza a pieza mientras aprendes sobre cada planeta y sus características.',
  subject: GameSubject.science,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.beginner,
  level: 5,
  route: '/nature-explorers',
  gradientColors: [Color(0xFF0F2027), Color(0xFF203A43)],
  subjectLabel: 'CIENCIAS',
  subjectColor: Color(0xFF3498DB),
  icon: Icons.public_rounded,
  xpProgress: 0.55,
);

const CatalogGame _artStudio = CatalogGame(
  id: 'art_studio',
  title: 'Estudio de Arte',
  description:
      'Crea obras de arte usando formas geométricas y colores. Aprende sobre artistas famosos y sus técnicas.',
  subject: GameSubject.art,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.beginner,
  level: 3,
  route: '/artists-in-action',
  gradientColors: [Color(0xFF360033), Color(0xFF0B8793)],
  subjectLabel: 'ARTE',
  subjectColor: Color(0xFFE91E63),
  icon: Icons.palette_rounded,
  xpProgress: 0.25,
);

const CatalogGame _rhythmBeats = CatalogGame(
  id: 'rhythm_beats',
  title: 'Ritmos y Compases',
  description:
      'Descubre el mundo del ritmo tocando instrumentos virtuales. Aprende solfeo básico jugando.',
  subject: GameSubject.music,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.beginner,
  level: 3,
  route: '/color-concert',
  gradientColors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
  subjectLabel: 'MÚSICA',
  subjectColor: Color(0xFFE91E63),
  icon: Icons.music_note_rounded,
  xpProgress: 0.35,
);

const CatalogGame _historyTales = CatalogGame(
  id: 'history_tales',
  title: 'Cuentos de la Historia',
  description:
      'Viaja por las civilizaciones más importantes de la historia a través de historias interactivas y emocionantes.',
  subject: GameSubject.history,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.beginner,
  level: 4,
  route: '/time-travel',
  gradientColors: [Color(0xFF833AB4), Color(0xFFE1306C)],
  subjectLabel: 'HISTORIA',
  subjectColor: Color(0xFFE67E22),
  icon: Icons.menu_book_rounded,
  xpProgress: 0.45,
);

// ── Intermediate 6-8 (+5 → total 5) ──────────────────────────────────────────

const CatalogGame _fractionKitchen = CatalogGame(
  id: 'fraction_kitchen',
  title: 'La Cocina de Fracciones',
  description:
      'Aprende fracciones y proporciones cocinando recetas deliciosas. ¡Las matemáticas nunca supieron tan bien!',
  subject: GameSubject.math,
  ageRange: AgeRange.age6to8,
  difficulty: Difficulty.intermediate,
  level: 6,
  route: '/math-adventure',
  gradientColors: [Color(0xFFFF512F), Color(0xFFDD2476)],
  subjectLabel: 'MATEMÁTICAS',
  subjectColor: Color(0xFF2ECC71),
  icon: Icons.restaurant_rounded,
  xpProgress: 0.50,
);

const CatalogGame _geoExplorer = CatalogGame(
  id: 'geo_explorer',
  title: 'Explorador Geográfico',
  description:
      'Descubre continentes, países y capitales en un mapa interactivo lleno de retos y misiones.',
  subject: GameSubject.history,
  ageRange: AgeRange.age6to8,
  difficulty: Difficulty.intermediate,
  level: 7,
  route: '/time-travel',
  gradientColors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
  subjectLabel: 'HISTORIA',
  subjectColor: Color(0xFFE67E22),
  icon: Icons.map_rounded,
  xpProgress: 0.60,
);

const CatalogGame _dinoDiggers = CatalogGame(
  id: 'dino_diggers',
  title: 'Paleontólogos en Acción',
  description:
      'Excava fósiles, clasifica dinosaurios y aprende sobre la prehistoria como un verdadero científico.',
  subject: GameSubject.science,
  ageRange: AgeRange.age6to8,
  difficulty: Difficulty.intermediate,
  level: 6,
  route: '/nature-explorers',
  gradientColors: [Color(0xFF56223A), Color(0xFFC85250)],
  subjectLabel: 'CIENCIAS',
  subjectColor: Color(0xFF3498DB),
  icon: Icons.search_rounded,
  xpProgress: 0.40,
);

const CatalogGame _codeBlocks = CatalogGame(
  id: 'code_blocks',
  title: 'Bloques de Código',
  description:
      'Introduce a los niños al pensamiento computacional con bloques de programación visual y divertida.',
  subject: GameSubject.logic,
  ageRange: AgeRange.age6to8,
  difficulty: Difficulty.intermediate,
  level: 5,
  route: '/treasure-map',
  gradientColors: [Color(0xFF0F0C29), Color(0xFF302B63)],
  subjectLabel: 'LÓGICA',
  subjectColor: Color(0xFF9B59B6),
  icon: Icons.code_rounded,
  xpProgress: 0.30,
);

const CatalogGame _miniStories = CatalogGame(
  id: 'mini_stories',
  title: 'Mini Cuentos',
  description:
      'Construye cuentos creativos eligiendo personajes, escenarios y aventuras. Desarrolla la expresión escrita.',
  subject: GameSubject.languages,
  ageRange: AgeRange.age6to8,
  difficulty: Difficulty.intermediate,
  level: 5,
  route: '/fun-english',
  gradientColors: [Color(0xFF093028), Color(0xFF237A57)],
  subjectLabel: 'IDIOMAS',
  subjectColor: Color(0xFF1ABC9C),
  icon: Icons.auto_stories_rounded,
  xpProgress: 0.65,
);

// ── Intermediate 9-11 (+1 → total 5) ─────────────────────────────────────────

const CatalogGame _composerJr = CatalogGame(
  id: 'composer_jr',
  title: 'Compositor Júnior',
  description:
      'Compone tu primera canción con instrumentos reales. Aprende teoría musical de forma interactiva.',
  subject: GameSubject.music,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.intermediate,
  level: 8,
  route: '/color-concert',
  gradientColors: [Color(0xFF373B44), Color(0xFF4286F4)],
  subjectLabel: 'MÚSICA',
  subjectColor: Color(0xFFE91E63),
  icon: Icons.piano_rounded,
  xpProgress: 0.70,
);

// ── Advanced 9-11 (+2) ────────────────────────────────────────────────────────

const CatalogGame _crisisSolver = CatalogGame(
  id: 'crisis_solver',
  title: 'Resolvedor de Crisis',
  description:
      'Toma decisiones estratégicas en situaciones complejas. Desarrolla el pensamiento crítico y la lógica avanzada.',
  subject: GameSubject.logic,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.advanced,
  level: 11,
  route: '/treasure-map',
  gradientColors: [Color(0xFF200122), Color(0xFF6F0000)],
  subjectLabel: 'LÓGICA',
  subjectColor: Color(0xFF9B59B6),
  icon: Icons.psychology_rounded,
  xpProgress: 0.55,
  isFeatured: false,
);

const CatalogGame _astroPhysics = CatalogGame(
  id: 'astro_physics',
  title: 'Astrofísica Juvenil',
  description:
      'Explora los principios de la física a través del universo: gravedad, luz, relatividad y más.',
  subject: GameSubject.science,
  ageRange: AgeRange.age9to11,
  difficulty: Difficulty.advanced,
  level: 10,
  route: '/nature-explorers',
  gradientColors: [Color(0xFF0A0A0A), Color(0xFF1A237E)],
  subjectLabel: 'CIENCIAS',
  subjectColor: Color(0xFF3498DB),
  icon: Icons.rocket_launch_rounded,
  xpProgress: 0.45,
);

// ── Advanced 12+ (+7 → total 8) ───────────────────────────────────────────────

const CatalogGame _codeQuest = CatalogGame(
  id: 'code_quest',
  title: 'Code Quest',
  description:
      'Aprende programación real con Python y JavaScript resolviendo misiones épicas de hacking ético.',
  subject: GameSubject.logic,
  ageRange: AgeRange.age12plus,
  difficulty: Difficulty.advanced,
  level: 13,
  route: '/treasure-map',
  gradientColors: [Color(0xFF141E30), Color(0xFF243B55)],
  subjectLabel: 'LÓGICA',
  subjectColor: Color(0xFF9B59B6),
  icon: Icons.terminal_rounded,
  isFeatured: true,
  featuredTag: 'NUEVO',
  xpProgress: 0.25,
);

const CatalogGame _cosmosVoyage = CatalogGame(
  id: 'cosmos_voyage',
  title: 'Viaje al Cosmos',
  description:
      'Navega por galaxias, estudia agujeros negros y aprende astronomía avanzada en una simulación 3D.',
  subject: GameSubject.science,
  ageRange: AgeRange.age12plus,
  difficulty: Difficulty.advanced,
  level: 14,
  route: '/nature-explorers',
  gradientColors: [Color(0xFF000000), Color(0xFF434343)],
  subjectLabel: 'CIENCIAS',
  subjectColor: Color(0xFF3498DB),
  icon: Icons.satellite_alt_rounded,
  xpProgress: 0.40,
);

const CatalogGame _worldLeaders = CatalogGame(
  id: 'world_leaders',
  title: 'Líderes del Mundo',
  description:
      'Estrategia geopolítica a través de la historia: construye alianzas, gestiona recursos y cambia el curso de la humanidad.',
  subject: GameSubject.history,
  ageRange: AgeRange.age12plus,
  difficulty: Difficulty.advanced,
  level: 15,
  route: '/time-travel',
  gradientColors: [Color(0xFF373B44), Color(0xFF1C1C1C)],
  subjectLabel: 'HISTORIA',
  subjectColor: Color(0xFFE67E22),
  icon: Icons.flag_rounded,
  xpProgress: 0.60,
);

const CatalogGame _mathOlympiad = CatalogGame(
  id: 'math_olympiad',
  title: 'Olimpiada Matemática',
  description:
      'Retos de nivel competitivo: álgebra avanzada, geometría analítica, probabilidad y estadística.',
  subject: GameSubject.math,
  ageRange: AgeRange.age12plus,
  difficulty: Difficulty.advanced,
  level: 16,
  route: '/math-adventure',
  gradientColors: [Color(0xFF0F2027), Color(0xFF2C5364)],
  subjectLabel: 'MATEMÁTICAS',
  subjectColor: Color(0xFF2ECC71),
  icon: Icons.functions_rounded,
  xpProgress: 0.35,
);

const CatalogGame _linguisticsLab = CatalogGame(
  id: 'linguistics_lab',
  title: 'Laboratorio de Lingüística',
  description:
      'Analiza estructuras gramaticales, descifra lenguas antiguas y aprende los fundamentos de la comunicación humana.',
  subject: GameSubject.languages,
  ageRange: AgeRange.age12plus,
  difficulty: Difficulty.advanced,
  level: 14,
  route: '/fun-english',
  gradientColors: [Color(0xFF005C97), Color(0xFF363795)],
  subjectLabel: 'IDIOMAS',
  subjectColor: Color(0xFF1ABC9C),
  icon: Icons.language_rounded,
  xpProgress: 0.50,
);

const CatalogGame _symphonyMaster = CatalogGame(
  id: 'symphony_master',
  title: 'Maestro de la Sinfonía',
  description:
      'Dirige tu propia orquesta sinfónica: estudia partituras, armonía y aprende sobre los grandes compositores.',
  subject: GameSubject.music,
  ageRange: AgeRange.age12plus,
  difficulty: Difficulty.advanced,
  level: 15,
  route: '/color-concert',
  gradientColors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
  subjectLabel: 'MÚSICA',
  subjectColor: Color(0xFFE91E63),
  icon: Icons.queue_music_rounded,
  xpProgress: 0.30,
);

const CatalogGame _artHistory = CatalogGame(
  id: 'art_history',
  title: 'Historia del Arte',
  description:
      'Del arte rupestre al modernismo: analiza obras maestras, estudia movimientos y crea en el estilo de los grandes.',
  subject: GameSubject.art,
  ageRange: AgeRange.age12plus,
  difficulty: Difficulty.advanced,
  level: 13,
  route: '/artists-in-action',
  gradientColors: [Color(0xFF4B0082), Color(0xFF800080)],
  subjectLabel: 'ARTE',
  subjectColor: Color(0xFFE91E63),
  icon: Icons.brush_rounded,
  xpProgress: 0.45,
);

/// Full catalog of EduPlay games, enriched for the catalog UI.
final List<CatalogGame> allCatalogGames = [
  // ── Original 9 ───────────────────────────────────────────────────────────
  const CatalogGame(
    id: 'math_adventure',
    title: 'Aventura Matemática',
    description:
        'Derrota a los monstruos con el poder de los números. Álgebra, fracciones y más en una épica aventura.',
    subject: GameSubject.math,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 5,
    route: '/math-adventure',
    gradientColors: [Color(0xFF1B4332), Color(0xFF40916C)],
    subjectLabel: 'MATEMÁTICAS',
    subjectColor: Color(0xFF2ECC71),
    icon: Icons.calculate_rounded,
    xpProgress: 0.45,
  ),
  const CatalogGame(
    id: 'cell_explorer',
    title: 'Cell Explorer 3D',
    description:
        'Viaja al interior de una célula y descubre los secretos de la vida. Ciencias nunca fue tan emocionante.',
    subject: GameSubject.science,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 8,
    route: '/nature-explorers',
    gradientColors: [Color(0xFF0D1B2A), Color(0xFF1B4F72)],
    subjectLabel: 'CIENCIAS',
    subjectColor: Color(0xFF3498DB),
    icon: Icons.biotech_rounded,
    xpProgress: 0.30,
  ),
  const CatalogGame(
    id: 'empire_builder',
    title: 'Empire Builder',
    description:
        'Construye civilizaciones desde la Antigüedad hasta la era moderna. Historia en tus manos.',
    subject: GameSubject.history,
    ageRange: AgeRange.age12plus,
    difficulty: Difficulty.advanced,
    level: 12,
    route: '/time-travel',
    gradientColors: [Color(0xFF3D2B1F), Color(0xFF7B4F2E)],
    subjectLabel: 'HISTORIA',
    subjectColor: Color(0xFFE67E22),
    icon: Icons.account_balance_rounded,
    isFeatured: true,
    featuredTag: 'JUEGO DE LA SEMANA',
    xpProgress: 0.70,
  ),
  const CatalogGame(
    id: 'polyglot_island',
    title: 'Polyglot Island',
    description:
        'Aprende inglés, francés y más idiomas explorando una isla mágica llena de personajes fascinantes.',
    subject: GameSubject.languages,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 4,
    route: '/fun-english',
    gradientColors: [Color(0xFF0B3D2E), Color(0xFF1A6B50)],
    subjectLabel: 'IDIOMAS',
    subjectColor: Color(0xFF1ABC9C),
    icon: Icons.translate_rounded,
    xpProgress: 0.20,
  ),
  const CatalogGame(
    id: 'logic_maze',
    title: 'Logic Maze',
    description:
        'Resuelve intrincados puzzles espaciales en 3D que desafían tu razonamiento lógico.',
    subject: GameSubject.logic,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 7,
    route: '/treasure-map',
    gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    subjectLabel: 'LÓGICA',
    subjectColor: Color(0xFF9B59B6),
    icon: Icons.extension_rounded,
    isFeatured: true,
    featuredTag: 'NUEVO',
    xpProgress: 0.55,
  ),
  const CatalogGame(
    id: 'history_hunters',
    title: 'History Hunters',
    description:
        'Viaja en el tiempo a la Antigua Roma y resuelve misterios históricos como un verdadero arqueólogo.',
    subject: GameSubject.history,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 9,
    route: '/time-travel',
    gradientColors: [Color(0xFF4A3000), Color(0xFF8B6914)],
    subjectLabel: 'HISTORIA',
    subjectColor: Color(0xFFE67E22),
    icon: Icons.explore_rounded,
    isFeatured: true,
    featuredTag: 'TENDENCIA',
    xpProgress: 0.60,
  ),
  const CatalogGame(
    id: 'color_concert',
    title: 'Concierto de Colores',
    description:
        'Aprende teoría musical creando melodías y composiciones únicas con colores y sonidos.',
    subject: GameSubject.music,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 3,
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
        'Compite en diferentes deportes mientras aprendes física, trabajo en equipo y estrategia.',
    subject: GameSubject.sports,
    ageRange: AgeRange.age9to11,
    difficulty: Difficulty.intermediate,
    level: 6,
    route: '/sports-challenge',
    gradientColors: [Color(0xFF1B0000), Color(0xFF7B0000)],
    subjectLabel: 'DEPORTES',
    subjectColor: Color(0xFFE53935),
    icon: Icons.sports_soccer_rounded,
    xpProgress: 0.40,
  ),
  const CatalogGame(
    id: 'magic_words',
    title: 'Palabras Mágicas',
    description:
        'Construye vocabulario y comprensión lectora a través de hechizos y conjuros literarios.',
    subject: GameSubject.languages,
    ageRange: AgeRange.age6to8,
    difficulty: Difficulty.beginner,
    level: 2,
    route: '/magic-words',
    gradientColors: [Color(0xFF0D0D2B), Color(0xFF1A1A5E)],
    subjectLabel: 'IDIOMAS',
    subjectColor: Color(0xFF1ABC9C),
    icon: Icons.auto_stories_rounded,
    xpProgress: 0.85,
  ),
  // ── Beginner additions ────────────────────────────────────────────────────
  _numberNinja,
  _wordSafari,
  _planetPuzzles,
  _artStudio,
  _rhythmBeats,
  _historyTales,
  // ── Intermediate additions ────────────────────────────────────────────────
  _fractionKitchen,
  _geoExplorer,
  _dinoDiggers,
  _codeBlocks,
  _miniStories,
  _composerJr,
  // ── Advanced additions ────────────────────────────────────────────────────
  _crisisSolver,
  _astroPhysics,
  _codeQuest,
  _cosmosVoyage,
  _worldLeaders,
  _mathOlympiad,
  _linguisticsLab,
  _symphonyMaster,
  _artHistory,
];

/// The three featured games (hero + 2 side cards).
List<CatalogGame> get featuredGames =>
    allCatalogGames.where((g) => g.isFeatured).take(3).toList();
