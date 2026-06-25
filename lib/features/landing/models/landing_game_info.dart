import 'package:flutter/material.dart';

/// Lightweight description of a game/subject used to showcase the EduPlay
/// catalog on the public landing page.
class LandingGameInfo {
  const LandingGameInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

/// Catalog of EduPlay games shown on the landing page, mirroring the games
/// available in [MenuProvider].
const List<LandingGameInfo> landingGames = [
  LandingGameInfo(
    title: 'Aventura Matemática',
    description:
        'Domina sumas, restas y multiplicaciones en retos progresivos.',
    icon: Icons.calculate_rounded,
    color: Color(0xFF4CAF50),
  ),
  LandingGameInfo(
    title: 'Palabras Mágicas',
    description: 'Mejora la ortografía y el vocabulario con anagramas.',
    icon: Icons.abc_rounded,
    color: Color(0xFF2196F3),
  ),
  LandingGameInfo(
    title: 'Inglés Divertido',
    description: 'Aprende vocabulario básico con apoyo visual y auditivo.',
    icon: Icons.language_rounded,
    color: Color(0xFFF44336),
  ),
  LandingGameInfo(
    title: 'Exploradores de la Naturaleza',
    description: 'Descubre la biodiversidad y cuida el medio ambiente.',
    icon: Icons.forest_rounded,
    color: Color(0xFFFF9800),
  ),
  LandingGameInfo(
    title: 'Viaje en el Tiempo',
    description: 'Recorre la historia y sus eventos más importantes.',
    icon: Icons.access_time_filled_rounded,
    color: Color(0xFF9C27B0),
  ),
  LandingGameInfo(
    title: 'Mapa del Tesoro',
    description: 'Resuelve acertijos de lógica para encontrar recompensas.',
    icon: Icons.map_rounded,
    color: Color(0xFFFFC107),
  ),
  LandingGameInfo(
    title: 'Artistas en Acción',
    description: 'Desata la creatividad con herramientas de dibujo libre.',
    icon: Icons.palette_rounded,
    color: Color(0xFFE91E63),
  ),
  LandingGameInfo(
    title: 'Concierto de Colores',
    description: 'Experimenta con la música y los colores sin parar.',
    icon: Icons.music_note_rounded,
    color: Color(0xFF009688),
  ),
  LandingGameInfo(
    title: 'Desafío Deportivo',
    description: 'Trivias y retos rápidos sobre deportes del mundo.',
    icon: Icons.sports_soccer_rounded,
    color: Color(0xFF795548),
  ),
];
