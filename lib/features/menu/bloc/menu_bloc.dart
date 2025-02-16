import 'package:flutter/material.dart';
import 'package:edu_play/features/menu/models/game.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class MenuProvider with ChangeNotifier {
  MenuProvider({
    required this.context,
    required this.username,
  });

  final BuildContext context;
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
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, RouterPaths.mathAdventure),
        ),
        Game(
          title: 'Palabras Mágicas',
          color: Colors.green,
          onTap: () {},
        ),
        Game(
          title: 'Inglés Divertido',
          color: Colors.red,
          onTap: () {},
        ),
        Game(
          title: 'Exploradores de la Naturaleza',
          color: Colors.orange,
          onTap: () {},
        ),
        Game(
          title: 'Viaje en el Tiempo',
          color: Colors.purple,
          onTap: () {},
        ),
        Game(
          title: 'Mapa del Tesoro',
          color: Colors.yellow,
          onTap: () {},
        ),
        Game(
          title: 'Artistas en Acción',
          color: Colors.pink,
          onTap: () {},
        ),
        Game(
          title: 'Concierto de Colores',
          color: Colors.teal,
          onTap: () {},
        ),
        Game(
          title: 'Desafío Deportivo',
          color: Colors.brown,
          onTap: () {},
        ),
      ];
}
