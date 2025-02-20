import 'dart:math';
import 'package:edu_play/features/math_adventure/models/question.dart';
import 'package:flutter/material.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class MathAdventureProvider with ChangeNotifier {
  MathAdventureProvider({
    required this.context,
    required this.userName,
  }) {
    _loadNextQuestion();
  }

  final BuildContext context;
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
    final questionIndex = random.nextInt(_questions.length);
    final questionData = _questions[questionIndex];

    _currentQuestion = questionData.question;
    _currentAnswers = List<String>.from(questionData.options);
    _correctAnswerIndex = questionData.answer;
  }

  void checkAnswer(int answerIndex) {
    if (answerIndex == _correctAnswerIndex) {
      _increaseScore();
      _nextLevel();
    } else {
      _loseLife();
    }
    _loadNextQuestion();
    notifyListeners();
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
