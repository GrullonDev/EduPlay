import 'package:flutter/material.dart';
import 'package:edu_play/features/menu/models/game.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class MenuProvider with ChangeNotifier {
  MenuProvider({
    required this.context,
    required this.age,
    required this.username,
  });

  final BuildContext context;
  final int age;
  final String? username;

  String _selectedGame = '';

  String get selectedGame => _selectedGame;

  void selectGame(String game) {
    _selectedGame = game;
    notifyListeners();
  }

  double getFontSize(BuildContext context) {
    return MediaQuery.of(context).size.width > 900
        ? 24
        : MediaQuery.of(context).size.width > 600
            ? 22
            : 20;
  }

  int getCrossAxisCount(BuildContext context) {
    return MediaQuery.of(context).size.width > 900
        ? 4
        : MediaQuery.of(context).size.width > 600
            ? 3
            : 2;
  }

  List<Game> get games => [
        Game(
          title: 'Aventura Matemática',
          color: const Color(0xFF4CAF50), // Fresh Green
          icon: Icons.calculate_rounded,
          onTap: () => Navigator.pushNamed(context, RouterPaths.mathAdventure),
        ),
        Game(
          title: 'Palabras Mágicas',
          color: const Color(0xFF2196F3), // Bright Blue
          icon: Icons.abc_rounded,
          onTap: () => Navigator.pushNamed(context, RouterPaths.magicWords),
        ),
        Game(
          title: 'Inglés Divertido',
          color: const Color(0xFFF44336), // Vibrant Red
          icon: Icons.language_rounded,
          onTap: () => Navigator.pushNamed(context, RouterPaths.funEnglish),
        ),
        Game(
          title: 'Exploradores de la Naturaleza',
          color: const Color(0xFFFF9800), // Orange
          icon: Icons.forest_rounded,
          onTap: () {},
        ),
        Game(
          title: 'Viaje en el Tiempo',
          color: const Color(0xFF9C27B0), // Purple
          icon: Icons.access_time_filled_rounded,
          onTap: () {},
        ),
        Game(
          title: 'Mapa del Tesoro',
          color: const Color(0xFFFFEB3B), // Yellow
          icon: Icons.map_rounded,
          onTap: () {},
        ),
        Game(
          title: 'Artistas en Acción',
          color: const Color(0xFFE91E63), // Pink
          icon: Icons.palette_rounded,
          onTap: () {},
        ),
        Game(
          title: 'Concierto de Colores',
          color: const Color(0xFF009688), // Teal
          icon: Icons.music_note_rounded,
          onTap: () {},
        ),
        Game(
          title: 'Desafío Deportivo',
          color: const Color(0xFF795548), // Brown
          icon: Icons.sports_soccer_rounded,
          onTap: () {},
        ),
      ];
}
