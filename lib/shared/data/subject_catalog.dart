import 'package:flutter/material.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

/// A school subject, used to classify games and challenges across both
/// the student and teacher dashboards.
class Subject {
  const Subject({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String key;
  final String label;
  final IconData icon;
  final Color color;
}

const List<Subject> subjectCatalog = [
  Subject(
    key: 'math',
    label: 'Matemáticas',
    icon: Icons.calculate_rounded,
    color: Color(0xFF4CAF50),
  ),
  Subject(
    key: 'language',
    label: 'Lengua',
    icon: Icons.abc_rounded,
    color: Color(0xFF2196F3),
  ),
  Subject(
    key: 'english',
    label: 'Idiomas',
    icon: Icons.translate_rounded,
    color: Color(0xFFF44336),
  ),
  Subject(
    key: 'science',
    label: 'Ciencias',
    icon: Icons.forest_rounded,
    color: Color(0xFFFF9800),
  ),
  Subject(
    key: 'history',
    label: 'Historia',
    icon: Icons.public_rounded,
    color: Color(0xFF9C27B0),
  ),
  Subject(
    key: 'logic',
    label: 'Lógica',
    icon: Icons.extension_rounded,
    color: Color(0xFFFFC107),
  ),
  Subject(
    key: 'music',
    label: 'Música',
    icon: Icons.music_note_rounded,
    color: Color(0xFF009688),
  ),
  Subject(
    key: 'sports',
    label: 'Deportes',
    icon: Icons.sports_soccer_rounded,
    color: Color(0xFF795548),
  ),
];

Subject subjectByKey(String key) => subjectCatalog.firstWhere(
      (s) => s.key == key,
      orElse: () => subjectCatalog.first,
    );

/// Route used by the "Misión del Día" CTA to jump straight into the game
/// associated with a subject.
const Map<String, String> subjectGameRoutes = {
  'math': RouterPaths.mathAdventure,
  'language': RouterPaths.magicWords,
  'english': RouterPaths.funEnglish,
  'science': RouterPaths.natureExplorers,
  'history': RouterPaths.timeTravel,
  'logic': RouterPaths.treasureMap,
  'music': RouterPaths.colorConcert,
  'sports': RouterPaths.sportsChallenge,
};
