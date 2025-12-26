import 'dart:math';

import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';

class MathAdventureProvider with ChangeNotifier {
  MathAdventureProvider({
    
    required this.context,
    required this.age,
  ,
    required this.userName,
  }) {
    _generateQuestion();
  }

  final BuildContext context;
  final int age;
  final String? userName;

  int _score = 0;
  int _lives = 3;
  int _level = 1;
  String _currentQuestion = '';
  List<String> _currentAnswers = [];
  int _correctAnswerIndex = 0;

  int get score => _score;
  int get lives => _lives;
  int get level => _level;
  String get currentQuestion => _currentQuestion;
  List<String> get currentAnswers => _currentAnswers;

  final List<Question> _questions = [
    Question(
      question: '¿Cuánto es 2 + 2?',
      options: ['3', '4', '5', '6'],
      answer: 1,
    ),
    Question(
      question: '¿Cuánto es 3 + 5?',
      options: ['7', '8', '9', '10'],
      answer: 1,
    ),
    Question(
      question: '¿Cuánto es 7 - 3?',
      options: ['3', '4', '5', '6'],
      answer: 1,
    ),
    // Agrega más preguntas aquí
    Question(
      question: '¿Cuánto es 10 / 2?',
      options: ['3', '4', '5', '6'],
      answer: 2,
    ),
    Question(
      question: '¿Cuánto es 6 * 3?',
      options: ['18', '16', '20', '22'],
      answer: 0,
    ),
    Question(
      question: '¿Cuánto es 9 + 10?',
      options: ['19', '20', '21', '22'],
      answer: 0,
    ),
  ];

  void _loadNextQuestion() {
    final random = Random();
    int num1, num2, result;
    String operator;

    // Logic based on age
    if (age < 6) {
      // Simple Addition (Sum up to 10)
      num1 = random.nextInt(6); // 0-5
      num2 = random.nextInt(5) + 1; // 1-5
      result = num1 + num2;
      operator = '+';
    } else if (age >= 6 && age <= 8) {
      // Addition and Subtraction (Up to 20)
      if (random.nextBool()) {
        num1 = random.nextInt(11); // 0-10
        num2 = random.nextInt(10) + 1; // 1-10
        result = num1 + num2;
        operator = '+';
      } else {
        num1 = random.nextInt(11) + 5; // 5-15
        num2 = random.nextInt(5) + 1; // 1-5
        result = num1 - num2;
        operator = '-';
      }
    } else {
      // Simple Multiplication and Division
      if (random.nextBool()) {
        num1 = random.nextInt(9) + 1; // 1-9
        num2 = random.nextInt(9) + 1; // 1-9
        result = num1 * num2;
        operator = '×';
      } else {
        // Division (Ensure integer result)
        num2 = random.nextInt(5) + 2; // 2-6
        result = random.nextInt(5) + 1; // 1-5
        num1 = result * num2;
        operator = '÷';
      }
    }

    _currentQuestion = '¿Cuánto es $num1 $operator $num2?';

    // Generate answers
    Set<String> answers = {};
    answers.add(result.toString());

    while (answers.length < 4) {
      int wrongAnswer = result + random.nextInt(10) - 5;
      if (wrongAnswer >= 0 && wrongAnswer != result) {
        answers.add(wrongAnswer.toString());
      }
    }

    _currentAnswers = answers.toList()..shuffle();
    _correctAnswerIndex = _currentAnswers.indexOf(result.toString());
    notifyListeners();
  }

  void checkAnswer(int answerIndex) {
    if (answerIndex == _correctAnswerIndex) {
      _increaseScore();
      _nextLevel();
    } else {
      _loseLife();
    }
    _generateQuestion(); // Generate next question immediately
  }

  void _increaseScore() {
    _score += 10;
    if (_score % 50 == 0) {
      _showReward();
    }
  }

  void _showReward() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: '¡Felicidades!',
        content: 'Has ganado un premio 🎁',
        buttonText: 'Aceptar',
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _nextLevel() {
    if (_score % 100 == 0) {
      _level++;
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: '¡Nivel alcanzado!',
          content: '¡Nivel $level alcanzado!',
          buttonText: 'Aceptar',
          onButtonPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  void _loseLife() {
    _lives--;
    if (_lives == 0) {
      _gameOver();
    }
  }

  void _gameOver() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: '¡Juego terminado!',
        content: 'Volverás a comenzar.',
        buttonText: 'Aceptar',
        onButtonPressed: () => Navigator.pushNamed(
          context,
          RouterPaths.menu,
          arguments: userName,
        ),
      ),
    );

    _score = 0;
    _lives = 3;
    _level = 1;
    notifyListeners();
  }

  void resetScore() {
    _score = 0;
    notifyListeners();
  }
}
