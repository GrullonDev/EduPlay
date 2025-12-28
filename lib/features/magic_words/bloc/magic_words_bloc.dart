import 'dart:math';

import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';

class MagicWordsProvider with ChangeNotifier {
  MagicWordsProvider({
    required this.context,
    required this.age,
  }) {
    _generateLevel();
  }

  final BuildContext context;
  final int age;

  int _score = 0;
  int _lives = 3;
  int _level = 1;

  // Game State
  String _targetWord = '';
  IconData _targetIcon = Icons.error;
  List<String> _options = [];
  String _displayWord = '';
  String _correctOption = '';
  List<String> _scrambledLetters = [];

  int get score => _score;
  int get lives => _lives;
  int get level => _level;
  String get targetWord => _targetWord;
  IconData get targetIcon => _targetIcon;
  List<String> get options => _options;
  String get displayWord => _displayWord;
  List<String> get scrambledLetters => _scrambledLetters;

  final List<Map<String, dynamic>> _wordData = [
    {'word': 'SOL', 'icon': Icons.wb_sunny_rounded},
    {'word': 'LUNA', 'icon': Icons.nightlight_round},
    {'word': 'CASA', 'icon': Icons.home_rounded},
    {'word': 'FLOR', 'icon': Icons.local_florist_rounded},
    {'word': 'GATO', 'icon': Icons.pets_rounded},
    {'word': 'AUTO', 'icon': Icons.directions_car_rounded},
    {'word': 'BOLA', 'icon': Icons.sports_soccer_rounded},
    {'word': 'ARBOL', 'icon': Icons.park_rounded},
    {'word': 'AVION', 'icon': Icons.airplanemode_active_rounded},
    {'word': 'LIBRO', 'icon': Icons.menu_book_rounded},
  ];

  void _generateLevel() {
    final random = Random();
    final data = _wordData[random.nextInt(_wordData.length)];
    _targetWord = data['word'];
    _targetIcon = data['icon'];
    _options = [];
    _scrambledLetters = [];

    if (age < 6) {
      // Logic: Identify First Letter
      // Display: _ O L
      // Options: Single letters
      _displayWord = _targetWord.substring(1); // Hide first char
      _correctOption = _targetWord[0];

      _options.add(_correctOption);
      while (_options.length < 3) {
        String randomChar = String.fromCharCode(random.nextInt(26) + 65); // A-Z
        if (!_options.contains(randomChar) && randomChar != _correctOption) {
          _options.add(randomChar);
        }
      }
      _options.shuffle();
    } else if (age >= 6 && age <= 8) {
      // Logic: Missing Letter in random pos
      // Display: G _ T O
      int missingIndex = random.nextInt(_targetWord.length);
      _correctOption = _targetWord[missingIndex];

      List<String> chars = _targetWord.split('');
      chars[missingIndex] = '_';
      _displayWord = chars.join(' ');

      _options.add(_correctOption);
      while (_options.length < 4) {
        String randomChar = String.fromCharCode(random.nextInt(26) + 65);
        if (!_options.contains(randomChar) && randomChar != _correctOption) {
          _options.add(randomChar);
        }
      }
      _options.shuffle();
    } else {
      // Logic: Full Word Selection (Scramble visualized, pick correct word)
      // Visuals showing scrambled letters? Yes.
      // Options: Full Words.
      _scrambledLetters = _targetWord.split('')..shuffle();
      _correctOption = _targetWord;

      _options.add(_targetWord);
      while (_options.length < 4) {
        final randomData = _wordData[random.nextInt(_wordData.length)];
        String randomWord = randomData['word'];
        if (!_options.contains(randomWord) && randomWord != _targetWord) {
          _options.add(randomWord);
        } else if (_options.length < 4) {
          // Fallback unique word generator
          String jargon = String.fromCharCodes(Iterable.generate(
              _targetWord.length, (_) => random.nextInt(26) + 65));
          _options.add(jargon);
        }
      }
      _options.shuffle();
    }
    notifyListeners();
  }

  void checkAnswer(String answer) {
    if (answer == _correctOption) {
      _increaseScore();
      _nextLevel();
    } else {
      _loseLife();
    }
    _generateLevel();
  }

  void _increaseScore() {
    _score += 10;
    if (_score % 50 == 0) {
      _showReward('¡Excelente!', '¡Has ganado puntos extras!');
    }
  }

  void _nextLevel() {
    if (_score % 100 == 0) {
      _level++;
      _showReward('¡Nivel $_level!', '¡Sigue así!');
    }
  }

  void _loseLife() {
    _lives--;
    if (_lives == 0) {
      _gameOver();
    }
  }

  void _showReward(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        buttonText: 'Continuar',
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _gameOver() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: '¡Juego terminado!',
        content: 'Puntuación final: $_score',
        buttonText: 'Menú',
        onButtonPressed: () {
          Navigator.of(context).pop();
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouterPaths.menu,
            (route) => false,
          );
        },
      ),
    );
    _score = 0;
    _lives = 3;
    _level = 1;
    notifyListeners();
  }

  void resetScore() {
    _score = 0;
    _lives = 3;
    notifyListeners();
  }
}
