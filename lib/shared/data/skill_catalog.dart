// Flutter imports:
import 'package:flutter/material.dart';

/// A concrete, gradeable skill practiced by one or more games — used to turn
/// raw scores into "masters addition, struggles with subtraction" reports
/// instead of just points. Mirrors the shape of [Subject] in
/// `subject_catalog.dart` on purpose, since both feed the same kind of
/// aggregation (`_subjectPerformanceFromScores`-style bucketing) in
/// `StudentRepository`.
class Skill {
  const Skill({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

const List<Skill> skillCatalog = [
  Skill(key: 'suma', label: 'Suma', icon: Icons.add_rounded),
  Skill(key: 'resta', label: 'Resta', icon: Icons.remove_rounded),
  Skill(
      key: 'multiplicacion',
      label: 'Multiplicación',
      icon: Icons.close_rounded),
  Skill(key: 'division', label: 'División', icon: Icons.percent_rounded),
  Skill(
      key: 'calculo_mental',
      label: 'Cálculo mental',
      icon: Icons.bolt_rounded),
  Skill(
      key: 'vocabulario_ingles',
      label: 'Vocabulario en inglés',
      icon: Icons.translate_rounded),
  Skill(key: 'vocabulario', label: 'Vocabulario', icon: Icons.abc_rounded),
  Skill(
      key: 'comprension_lectora',
      label: 'Comprensión lectora',
      icon: Icons.menu_book_rounded),
  Skill(
      key: 'ciencias_naturales',
      label: 'Ciencias naturales',
      icon: Icons.forest_rounded),
  Skill(key: 'historia', label: 'Historia', icon: Icons.public_rounded),
  Skill(
      key: 'logica_espacial',
      label: 'Lógica espacial',
      icon: Icons.extension_rounded),
  Skill(
      key: 'reflejos',
      label: 'Reflejos y coordinación',
      icon: Icons.sports_rounded),
  Skill(
      key: 'teoria_musical',
      label: 'Teoría musical',
      icon: Icons.music_note_rounded),
  Skill(
      key: 'artes_visuales',
      label: 'Artes visuales',
      icon: Icons.palette_rounded),
];

Skill skillByKey(String key) => skillCatalog.firstWhere(
      (s) => s.key == key,
      orElse: () => Skill(key: key, label: key, icon: Icons.star_rounded),
    );
