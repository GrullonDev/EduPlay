import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

class StreakRecoveryQuestion {
  StreakRecoveryQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  final String question;
  final List<String> options;
  final int answerIndex;
}

/// Drives the 10-question streak-recovery quiz: answer at least 9 out of 10
/// correctly to keep a lapsed streak alive. Deliberately standalone (not a
/// [GameSessionController]) — there's no lives/score concept here, just a
/// pass/fail tally over a fixed number of questions.
class StreakRecoveryController extends ChangeNotifier {
  StreakRecoveryController({required this.age}) {
    _generateQuestion();
  }

  static const totalQuestions = 10;
  static const passThreshold = 9;

  final int age;
  final Random _random = Random();

  int _questionIndex = 0;
  int _correctCount = 0;
  bool _finished = false;
  late StreakRecoveryQuestion _current;

  int get questionNumber => _questionIndex + 1;
  int get correctCount => _correctCount;
  bool get isFinished => _finished;
  bool get passed => _correctCount >= passThreshold;
  StreakRecoveryQuestion get current => _current;

  void submitAnswer(int optionIndex) {
    if (_finished) return;

    if (optionIndex == _current.answerIndex) {
      _correctCount++;
    }
    _questionIndex++;

    if (_questionIndex >= totalQuestions) {
      _finished = true;
      _submitResult();
    } else {
      _generateQuestion();
    }
    notifyListeners();
  }

  Future<void> _submitResult() {
    return passed
        ? sl<StudentRepository>().recoverStreak()
        : sl<StudentRepository>().resetStreak();
  }

  void _generateQuestion() {
    int num1, num2, result;
    String operator;

    if (age < 6) {
      num1 = _random.nextInt(6);
      num2 = _random.nextInt(6) + 1;
      result = num1 + num2;
      operator = '+';
    } else if (age >= 6 && age <= 8) {
      if (_random.nextBool()) {
        num1 = _random.nextInt(15) + 1;
        num2 = _random.nextInt(15) + 1;
        result = num1 + num2;
        operator = '+';
      } else {
        num1 = _random.nextInt(20) + 5;
        num2 = _random.nextInt(min(num1, 10)) + 1;
        result = num1 - num2;
        operator = '-';
      }
    } else {
      if (_random.nextBool()) {
        num1 = _random.nextInt(9) + 1;
        num2 = _random.nextInt(9) + 1;
        result = num1 * num2;
        operator = '×';
      } else {
        num2 = _random.nextInt(6) + 2;
        result = _random.nextInt(8) + 1;
        num1 = result * num2;
        operator = '÷';
      }
    }

    final options = <int>{result};
    while (options.length < 4) {
      final wrong = result + _random.nextInt(10) - 5;
      if (wrong >= 0 && wrong != result) options.add(wrong);
    }
    final shuffled = options.toList()..shuffle(_random);

    _current = StreakRecoveryQuestion(
      question: '¿Cuánto es $num1 $operator $num2?',
      options: shuffled.map((o) => o.toString()).toList(),
      answerIndex: shuffled.indexOf(result),
    );
  }
}
