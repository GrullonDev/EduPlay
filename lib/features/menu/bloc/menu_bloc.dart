import 'package:flutter/material.dart';
import 'package:edu_play/features/menu/models/game.dart';

class MenuProvider with ChangeNotifier {
  MenuProvider({
    required this.context,
  });

  final BuildContext context;

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
        Game(title: 'Aventura Matemática', color: Colors.blue),
        Game(title: 'Palabras Mágicas', color: Colors.green),
        Game(title: 'Inglés Divertido', color: Colors.red),
        Game(title: 'Exploradores de la Naturaleza', color: Colors.orange),
        Game(title: 'Viaje en el Tiempo', color: Colors.purple),
        Game(title: 'Mapa del Tesoro', color: Colors.yellow),
        Game(title: 'Artistas en Acción', color: Colors.pink),
        Game(title: 'Concierto de Colores', color: Colors.teal),
        Game(title: 'Desafío Deportivo', color: Colors.brown),
      ];
}
