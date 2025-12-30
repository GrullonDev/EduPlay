import 'dart:math';

import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';

class FunEnglishProvider with ChangeNotifier {
  FunEnglishProvider({
    required this.context,
    required this.age,
    required this.userName,
  }) {
    _generateQuestion();
  }

  final BuildContext context;
  final int age;
  final String? userName;

  int _score = 0;
  int _lives = 3;
  final int _level = 1;
  String _currentQuestion = ''; // The word to translate/match
  final String _currentImage = '';
  List<String> _currentOptions = [];
  int _correctAnswerIndex = 0;

  int get score => _score;
  int get lives => _lives;
  int get level => _level;
  String get currentQuestion => _currentQuestion;
  String get currentImage => _currentImage;
  List<String> get currentOptions => _currentOptions;

  // Vocabulary Data (Simple for MVP)
  final List<Map<String, String>> _vocabColors = [
    {'es': 'Rojo', 'en': 'Red', 'emoji': '🔴'},
    {'es': 'Azul', 'en': 'Blue', 'emoji': '🔵'},
    {'es': 'Verde', 'en': 'Green', 'emoji': '🟢'},
    {'es': 'Amarillo', 'en': 'Yellow', 'emoji': '🟡'},
  ];

  final List<Map<String, String>> _vocabAnimals = [
    {'es': 'Perro', 'en': 'Dog', 'emoji': '🐶'},
    {'es': 'Gato', 'en': 'Cat', 'emoji': '🐱'},
    {'es': 'León', 'en': 'Lion', 'emoji': '🦁'},
    {'es': 'Tigre', 'en': 'Tiger', 'emoji': '🐯'},
  ];

  final List<Map<String, String>> _vocabNumbers = [
    {'es': 'Uno', 'en': 'One', 'emoji': '1️⃣'},
    {'es': 'Dos', 'en': 'Two', 'emoji': '2️⃣'},
    {'es': 'Tres', 'en': 'Three', 'emoji': '3️⃣'},
    {'es': 'Cuatro', 'en': 'Four', 'emoji': '4️⃣'},
  ];

  void _generateQuestion() {
    final random = Random();
    Map<String, String> correctItem;
    List<Map<String, String>> category;

    // Pick Category based on random chance
    int catRoll = random.nextInt(3);
    if (catRoll == 0) {
      category = _vocabColors;
    } else if (catRoll == 1) {
      category = _vocabAnimals;
    } else {
      category = _vocabNumbers;
    }

    correctItem = category[random.nextInt(category.length)];

    // Logic based on Age
    if (age < 6) {
      // Show Emoji, Ask for English Word (Visual Association)
      _currentQuestion = "What is this? ${correctItem['emoji']}";
      _createOptions(correctItem, category, 'en');
    } else if (age >= 6 && age <= 8) {
      // Show Spanish Word, Ask for English Word (Translation)
      _currentQuestion = "¿Cómo se dice '${correctItem['es']}' en inglés?";
      _createOptions(correctItem, category, 'en');
    } else {
      // Show English Word, Ask for Spanish (Reverse Translation)
      _currentQuestion = "How do you say '${correctItem['en']}' in Spanish?";
      _createOptions(correctItem, category, 'es');
    }
  }

  void _createOptions(Map<String, String> correct,
      List<Map<String, String>> category, String targetLang) {
    final random = Random();
    Set<String> options = {correct[targetLang]!};

    while (options.length < 4) {
      var randomItem = category[random.nextInt(category.length)];
      if (randomItem != correct) {
        options.add(randomItem[targetLang]!);
      }
    }

    _currentOptions = options.toList()..shuffle();
    _correctAnswerIndex = _currentOptions.indexOf(correct[targetLang]!);
    notifyListeners();
  }

  void checkAnswer(int index) {
    if (index == _correctAnswerIndex) {
      _score += 10;
      if (_score % 50 == 0) _showReward();
    } else {
      _lives--;
      if (_lives == 0) _gameOver();
    }
    _generateQuestion(); // Next question
    notifyListeners();
  }

  // ... (Reuse Reward/GameOver logic from other blocs - ideally this should be a mixin or base class, but for speed duplicating)
  void _showReward() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Very Good! 🌟',
        content: '¡Has ganado un premio!',
        buttonText: 'Thanks',
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _gameOver() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Game Over',
        content: 'Try again!',
        buttonText: 'OK',
        onButtonPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          RouterPaths.menu,
          (route) => false,
          arguments: userName,
        ),
      ),
    );
  }
}
