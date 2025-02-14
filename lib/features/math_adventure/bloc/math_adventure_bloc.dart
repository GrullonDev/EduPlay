import 'package:flutter/material.dart';

class MathAdventureProvider with ChangeNotifier {
  int _score = 0;

  int get score => _score;

  void increaseScore() {
    _score += 10;
    notifyListeners();
  }

  void resetScore() {
    _score = 0;
    notifyListeners();
  }
}
