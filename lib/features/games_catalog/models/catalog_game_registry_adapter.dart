import 'package:flutter/material.dart';

import 'package:edu_play/features/games/core/game_metadata.dart';
import 'package:edu_play/features/games/core/game_registry.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game.dart';

List<CatalogGame> get effectiveCatalogGames {
  final existingIds = allCatalogGames.map((game) => game.id).toSet();
  final registryOnlyGames = GameRegistry.catalog
      .where((metadata) => !existingIds.contains(metadata.id))
      .map(_catalogGameFromMetadata);

  return [
    ...allCatalogGames,
    ...registryOnlyGames,
  ];
}

CatalogGame _catalogGameFromMetadata(GameMetadata metadata) {
  final subject = _subjectFromKey(metadata.subjectKey);
  final subjectColor = _subjectColor(subject);

  return CatalogGame(
    id: metadata.id,
    title: metadata.title,
    description:
        'Practica ${_subjectName(subject).toLowerCase()} con un reto interactivo de EduPlay.',
    subject: subject,
    ageRange: metadata.ageRange,
    difficulty: metadata.difficulty,
    level: _levelFor(metadata.difficulty),
    route: metadata.route,
    gradientColors: metadata.gradientColors,
    subjectLabel: _subjectName(subject).toUpperCase(),
    subjectColor: subjectColor,
    icon: metadata.icon,
    isFeatured: true,
    featuredTag: 'NUEVO',
    xpProgress: 0.0,
  );
}

GameSubject _subjectFromKey(String key) {
  switch (key) {
    case 'math':
      return GameSubject.math;
    case 'science':
      return GameSubject.science;
    case 'history':
      return GameSubject.history;
    case 'language':
    case 'languages':
    case 'english':
      return GameSubject.languages;
    case 'logic':
      return GameSubject.logic;
    case 'art':
      return GameSubject.art;
    case 'music':
      return GameSubject.music;
    case 'sports':
      return GameSubject.sports;
    default:
      return GameSubject.logic;
  }
}

String _subjectName(GameSubject subject) {
  switch (subject) {
    case GameSubject.all:
      return 'Todos';
    case GameSubject.math:
      return 'Matematicas';
    case GameSubject.science:
      return 'Ciencias';
    case GameSubject.history:
      return 'Historia';
    case GameSubject.languages:
      return 'Idiomas';
    case GameSubject.logic:
      return 'Logica';
    case GameSubject.art:
      return 'Arte';
    case GameSubject.music:
      return 'Musica';
    case GameSubject.sports:
      return 'Deportes';
  }
}

Color _subjectColor(GameSubject subject) {
  switch (subject) {
    case GameSubject.math:
      return const Color(0xFF2ECC71);
    case GameSubject.science:
      return const Color(0xFF3498DB);
    case GameSubject.history:
      return const Color(0xFFE67E22);
    case GameSubject.languages:
      return const Color(0xFF1ABC9C);
    case GameSubject.logic:
      return const Color(0xFF9B59B6);
    case GameSubject.art:
    case GameSubject.music:
      return const Color(0xFFE91E63);
    case GameSubject.sports:
      return const Color(0xFFE53935);
    case GameSubject.all:
      return const Color(0xFF1E1B6A);
  }
}

int _levelFor(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.beginner:
      return 2;
    case Difficulty.intermediate:
      return 7;
    case Difficulty.advanced:
      return 12;
  }
}
