// Flutter imports:
import 'package:flutter/material.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart'
    show AgeRange, Difficulty;

/// Static, const-constructible description of a game module.
///
/// [subjectKey] must match a key in [subjectCatalog]
/// (lib/shared/data/subject_catalog.dart) — it is passed verbatim to
/// `StudentRepository.recordScore`, which resolves the label/icon/color
/// from that catalog. It intentionally does NOT reuse `GameSubject` from
/// games_catalog/catalog_game.dart: that enum's values (e.g. `languages`)
/// don't line up 1:1 with subjectCatalog's keys (e.g. `language`), and a
/// silent mismatch there would misfile a student's score under the wrong
/// subject.
class GameMetadata {
  const GameMetadata({
    required this.id,
    required this.title,
    required this.route,
    required this.subjectKey,
    required this.ageRange,
    required this.difficulty,
    required this.icon,
    required this.gradientColors,
  });

  final String id;
  final String title;
  final String route;
  final String subjectKey;
  final AgeRange ageRange;
  final Difficulty difficulty;
  final IconData icon;
  final List<Color> gradientColors;
}
