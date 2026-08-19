import 'dart:math';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:edu_play/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const String _kSkillId = 'vocabulario_ingles';

class FunEnglishProvider with ChangeNotifier {
  FunEnglishProvider({
    required this.context,
    required this.age,
    required this.userName,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  final BuildContext context;
  final int age;
  final String? userName;

  /// Per-skill correct/total tally for the current session, passed to
  /// `recordScore` at game over so reports can show real mastery instead of
  /// just points.
  final SkillTracker skillTracker = SkillTracker();

  int _score = 0;
  int _lives = 3;
  int _level = 1;
  bool _playedTodayMarked = false;
  String _currentQuestion = ''; // The word to translate/match
  final String _currentImage = '';
  List<String> _currentOptions = [];
  int _correctAnswerIndex = 0;

  // The full vocab item (es/en/emoji) and language the player was asked to
  // answer in for the *current* question — kept around so checkAnswer can
  // build a real translation explanation after a wrong answer, before the
  // next question overwrites it.
  Map<String, String> _currentItem = const {};
  String _targetLang = 'en';

  int get score => _score;
  int get lives => _lives;
  int get level => _level;
  String get currentQuestion => _currentQuestion;
  String get currentImage => _currentImage;
  List<String> get currentOptions => _currentOptions;

  /// Difficulty grows with score: more categories are mixed in as the
  /// player proves they know the smaller pool, instead of throwing all
  /// vocabulary at them from question one.
  List<List<Map<String, String>>> get _availableCategories {
    if (_level <= 1) return [_vocabColors];
    if (_level == 2) return [_vocabColors, _vocabAnimals];
    return [_vocabColors, _vocabAnimals, _vocabNumbers];
  }

  String get _difficultyLabel {
    switch (_level) {
      case 1:
        return 'Principiante';
      case 2:
        return 'Intermedio';
      default:
        return 'Avanzado';
    }
  }

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

  /// Shows the objective dialog first, then generates the opening question —
  /// so the player knows what they're about to practice before questions
  /// start, instead of being dropped straight into the game.
  Future<void> _init() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Inglés Divertido',
      objective:
          'Vas a ampliar tu vocabulario en inglés: colores, animales y números',
      difficultyLabel: _difficultyLabel,
    );
    if (!context.mounted) return;
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    Map<String, String> correctItem;
    List<Map<String, String>> category;

    // Pick a category from the pool unlocked at the current difficulty
    // level, instead of always mixing every category from question one.
    final pools = _availableCategories;
    category = pools[random.nextInt(pools.length)];

    correctItem = category[random.nextInt(category.length)];

    final l10n = AppLocalizations.of(context)!;

    // Logic based on Age
    String targetLang;
    if (age < 6) {
      // Show Emoji, Ask for English Word (Visual Association)
      _currentQuestion = l10n.funEnglishAskEmoji(correctItem['emoji']!);
      targetLang = 'en';
    } else if (age >= 6 && age <= 8) {
      // Show Spanish Word, Ask for English Word (Translation)
      _currentQuestion = l10n.funEnglishAskEnglish(correctItem['es']!);
      targetLang = 'en';
    } else {
      // Show English Word, Ask for Spanish (Reverse Translation)
      _currentQuestion = l10n.funEnglishAskSpanish(correctItem['en']!);
      targetLang = 'es';
    }

    _currentItem = correctItem;
    _targetLang = targetLang;
    _createOptions(correctItem, category, targetLang);
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

  Future<void> checkAnswer(int index) async {
    final isCorrect = index == _correctAnswerIndex;
    skillTracker.record(_kSkillId, correct: isCorrect);

    if (isCorrect) {
      _score += 10;
      _updateLevel();
      if (_score % 50 == 0) _showReward();
      // First correct answer of the session keeps the streak alive right
      // away — don't make the child wait until they run out of lives.
      if (!_playedTodayMarked) {
        _playedTodayMarked = true;
        sl<StudentRepository>().markPlayedToday();
      }
    } else {
      final correctText = _currentItem[_targetLang] ??
          _currentOptions[_correctAnswerIndex];
      final es = _currentItem['es'] ?? '';
      final en = _currentItem['en'] ?? '';
      // Explain the mistake before the life is lost / game-over dialog (if
      // any) appears, so the player isn't left wondering why they failed
      // while a dialog is already stacking on top.
      await showAnswerExplanation(
        context,
        isCorrect: false,
        correctAnswerText: correctText,
        explanation: "'$es' se dice '$en' en inglés.",
        skillLabel: skillByKey(_kSkillId).label,
      );
      if (!context.mounted) return;
      _lives--;
      if (_lives == 0) {
        _gameOver();
        return;
      }
    }
    _generateQuestion(); // Next question
    notifyListeners();
  }

  /// Real difficulty progression: as the score grows, wider categories of
  /// vocabulary get mixed into the question pool (see
  /// [_availableCategories]) instead of just showing a congratulatory
  /// dialog with no change in content.
  void _updateLevel() {
    final newLevel = _score >= 100 ? 3 : (_score >= 40 ? 2 : 1);
    if (newLevel != _level) {
      _level = newLevel;
    }
  }

  // ... (Reuse Reward/GameOver logic from other blocs - ideally this should be a mixin or base class, but for speed duplicating)
  void _showReward() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: '¡Muy bien! 🌟',
        content: '¡Has ganado puntos extra!',
        buttonText: '¡Continuar! →',
        type: DialogType.reward,
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _gameOver() {
    // Capture before any reset — dialog builder runs on the next frame
    final finalScore = _score;
    final finalSkills = skillTracker.tallies;

    sl<StudentRepository>().recordScore(
      subjectKey: 'english',
      gameTitle: 'Inglés Divertido',
      score: finalScore,
      skills: finalSkills,
      gameRoute: '/fun-english',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: '¡Buen intento!',
        content: [
          'Puntuación: $finalScore pts',
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
}
