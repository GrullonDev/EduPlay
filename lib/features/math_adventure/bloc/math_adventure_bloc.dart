import 'dart:math';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:flutter/material.dart';

class MathAdventureProvider with ChangeNotifier {
  MathAdventureProvider({
    required this.context,
    required this.age,
    required this.userName,
    this.onScoreUpdate,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  final BuildContext context;
  final int age;
  final String? userName;

  /// Called every time the score changes. Used by the kiosk wrapper to
  /// track the real score without needing to access internals.
  final void Function(int score)? onScoreUpdate;

  /// Per-skill correct/total tally for the current session, sent alongside
  /// the score when the game ends.
  final SkillTracker skillTracker = SkillTracker();

  int _score = 0;
  int _lives = 3;
  int _level = 1;
  String _currentQuestion = '';
  List<String> _currentAnswers = [];
  int _correctAnswerIndex = 0;
  String _currentSkillId = 'suma';
  String _currentExplanation = '';

  int get score => _score;
  int get lives => _lives;
  int get level => _level;
  String get currentQuestion => _currentQuestion;
  List<String> get currentAnswers => _currentAnswers;

  /// Shows the learning objective for this session, then generates the
  /// first question — called once, after the first frame, so the dialog is
  /// shown before any gameplay content appears.
  Future<void> _startGame() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Aventura Matemática',
      objective: _objectiveForAge(),
      difficultyLabel: _difficultyLabel(),
    );
    if (!context.mounted) return;
    _generateQuestion();
  }

  String _objectiveForAge() {
    if (age < 6) {
      return 'Vas a practicar sumas sencillas con resultados hasta 10.';
    } else if (age >= 6 && age <= 8) {
      return 'Vas a practicar sumas y restas con números hasta 20.';
    }
    return 'Vas a practicar multiplicaciones y divisiones básicas.';
  }

  String _difficultyLabel() {
    if (age < 6) return 'Principiante';
    if (age >= 6 && age <= 8) return 'Intermedio';
    return 'Avanzado';
  }

  void _generateQuestion() {
    final random = Random();
    int num1, num2, result;
    String operator;
    String skillId;

    // Logic based on age AND current level, so difficulty actually scales
    // as the player progresses instead of only showing a "level up" dialog.
    if (age < 6) {
      // Simple addition, numbers grow slightly with level (max sum ~10-16).
      final cap = 5 + min(_level - 1, 3) * 2; // 5, 7, 9, 11...
      num1 = random.nextInt(cap ~/ 2 + 1);
      num2 = random.nextInt(cap ~/ 2 + 1) + 1;
      result = num1 + num2;
      operator = '+';
      skillId = 'suma';
    } else if (age >= 6 && age <= 8) {
      // Addition/subtraction up to 20 at low levels; once the player is
      // doing well (level 3+) start mixing in basic multiplication.
      final introduceMultiplication = _level >= 3 && random.nextInt(3) == 0;
      if (introduceMultiplication) {
        num1 = random.nextInt(5) + 1; // 1-5
        num2 = random.nextInt(5) + 1; // 1-5
        result = num1 * num2;
        operator = '×';
        skillId = 'multiplicacion';
      } else if (random.nextBool()) {
        final maxAddend = 10 + min(_level - 1, 4) * 3; // grows with level
        num1 = random.nextInt(maxAddend + 1);
        num2 = random.nextInt(maxAddend) + 1;
        result = num1 + num2;
        operator = '+';
        skillId = 'suma';
      } else {
        final base = 15 + min(_level - 1, 4) * 5; // grows with level
        num1 = random.nextInt(base) + 5;
        num2 = random.nextInt(min(num1, 10)) + 1;
        result = num1 - num2;
        operator = '-';
        skillId = 'resta';
      }
    } else {
      // Multiplication and division, ranges widen with level.
      final maxFactor = 9 + min(_level - 1, 4) * 2; // 9, 11, 13...
      if (random.nextBool()) {
        num1 = random.nextInt(maxFactor) + 1;
        num2 = random.nextInt(maxFactor) + 1;
        result = num1 * num2;
        operator = '×';
        skillId = 'multiplicacion';
      } else {
        // Division (ensure integer result), divisor range grows with level.
        num2 = random.nextInt(4 + min(_level - 1, 4)) + 2;
        result = random.nextInt(5 + min(_level - 1, 4)) + 1;
        num1 = result * num2;
        operator = '÷';
        skillId = 'division';
      }
    }

    _currentQuestion = '¿Cuánto es $num1 $operator $num2?';
    _currentSkillId = skillId;
    _currentExplanation = '$num1 $operator $num2 = $result';

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

  Future<void> checkAnswer(int answerIndex) async {
    final isCorrect = answerIndex == _correctAnswerIndex;
    final correctAnswerText = _currentAnswers[_correctAnswerIndex];
    final explanation = _currentExplanation;
    final skillId = _currentSkillId;

    skillTracker.record(skillId, correct: isCorrect);

    if (isCorrect) {
      _increaseScore();
      _nextLevel();
    } else {
      // Explain the mistake before the life is lost / game-over dialog
      // (if any) appears, so the player isn't left wondering why they
      // failed while a dialog is already stacking on top.
      await showAnswerExplanation(
        context,
        isCorrect: false,
        correctAnswerText: correctAnswerText,
        explanation: explanation,
        skillLabel: skillByKey(skillId).label,
      );
      if (!context.mounted) return;
      _loseLife();
    }
    _generateQuestion(); // Generate next question
  }

  void _increaseScore() {
    _score += 10;
    onScoreUpdate?.call(_score);
    if (_score % 50 == 0) {
      _showReward();
    }
  }

  void _showReward() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: '¡Felicidades!',
        content: '¡Has ganado puntos extra! 🎁',
        buttonText: '¡Continuar! →',
        type: DialogType.reward,
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _nextLevel() {
    if (_score % 100 == 0) {
      _level++;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CustomDialog(
          title: '¡Nivel $level!',
          content: '¡Estás avanzando muy bien! ⚡',
          buttonText: '¡Continuar! →',
          type: DialogType.levelUp,
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
    // Capture before reset — dialog builder runs on the next frame
    final finalScore = _score;
    final finalSkills = skillTracker.tallies;

    sl<StudentRepository>().recordScore(
      subjectKey: 'math',
      gameTitle: 'Aventura Matemática',
      score: finalScore,
      skills: finalSkills,
      gameRoute: '/math-adventure',
    );

    _score = 0;
    _lives = 3;
    _level = 1;
    skillTracker.reset();
    notifyListeners(); // reset state first

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: '¡Buen intento!',
        content: [
          'Puntuación final: $finalScore pts',
          if (skillSummaryText(finalSkills).isNotEmpty)
            skillSummaryText(finalSkills),
          '¡Sigue practicando!',
        ].join('\n'),
        buttonText: 'Volver al inicio',
        type: DialogType.gameOver,
        onButtonPressed: () =>
            StudentSessionNavigationService.returnAfterGameOver(context),
      ),
    );
  }

  void resetScore() {
    _score = 0;
    _lives = 3;
    skillTracker.reset();
    notifyListeners();
  }
}

class Question {
  Question({
    required this.question,
    required this.options,
    required this.answer,
  });
  final String question;
  final List<String> options;
  final int answer;
}
