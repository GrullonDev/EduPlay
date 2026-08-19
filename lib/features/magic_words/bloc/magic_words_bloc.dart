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

/// Which mechanic the current round uses. Drives both which skill gets
/// credited and how [MagicWordsLayout] renders the prompt.
enum MagicWordMode {
  /// Identify the first letter of a word shown via its icon (age < 6).
  firstLetter,

  /// Fill in a missing letter inside the word (age 6-8).
  missingLetter,

  /// Unscramble letters and pick the matching full word (age > 8, lower
  /// levels) — word recognition without any sentence context.
  scramble,

  /// Read a short sentence with a blank and pick the word that completes it
  /// (age > 8, higher levels) — genuine reading comprehension, not just
  /// letter/word recognition.
  sentence,
}

class MagicWordsProvider with ChangeNotifier {
  MagicWordsProvider({
    required this.context,
    required this.age,
    this.onScoreUpdate,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  final BuildContext context;
  final int age;
  final void Function(int score)? onScoreUpdate;

  /// Per-skill correct/total tally for the current session, passed to
  /// `recordScore` at game over so reports can show real mastery instead of
  /// just points.
  final SkillTracker skillTracker = SkillTracker();

  int _score = 0;
  int _lives = 3;
  int _level = 1;
  bool _playedTodayMarked = false;

  // Game State
  String _targetWord = '';
  IconData _targetIcon = Icons.error;
  List<String> _options = [];
  String _displayWord = '';
  String _correctOption = '';
  List<String> _scrambledLetters = [];
  MagicWordMode _mode = MagicWordMode.firstLetter;
  String _sentenceText = '';
  String _wordMeaning = '';

  int get score => _score;
  int get lives => _lives;
  int get level => _level;
  String get targetWord => _targetWord;
  IconData get targetIcon => _targetIcon;
  List<String> get options => _options;
  String get displayWord => _displayWord;
  List<String> get scrambledLetters => _scrambledLetters;
  MagicWordMode get mode => _mode;
  String get sentenceText => _sentenceText;

  /// The skill the *current* round exercises. Letter-identification and
  /// word-recognition rounds practice vocabulary; sentence rounds require
  /// reading and understanding a full sentence, so they credit reading
  /// comprehension instead.
  String get _currentSkillId => _mode == MagicWordMode.sentence
      ? 'comprension_lectora'
      : 'vocabulario';

  String get _difficultyLabel {
    if (_level <= 1) return 'Principiante';
    if (_level == 2) return 'Intermedio';
    return 'Avanzado';
  }

  // Word bank, ordered roughly from shorter/more common to longer/less
  // common so difficulty can scale by widening the pool with [_wordPool]
  // instead of just incrementing a cosmetic counter. Each entry also
  // carries a fill-in-the-blank sentence and a short meaning, used by the
  // sentence-comprehension mode and by wrong-answer explanations.
  final List<Map<String, dynamic>> _wordData = [
    {
      'word': 'SOL',
      'icon': Icons.wb_sunny_rounded,
      'sentence': 'De día, el ___ ilumina el cielo.',
      'meaning': 'la estrella que da luz y calor a la Tierra durante el día',
    },
    {
      'word': 'LUNA',
      'icon': Icons.nightlight_round,
      'sentence': 'Por la noche, la ___ brilla en el cielo.',
      'meaning': 'el astro que vemos brillar en el cielo durante la noche',
    },
    {
      'word': 'CASA',
      'icon': Icons.home_rounded,
      'sentence': 'Mi familia y yo vivimos en una ___.',
      'meaning': 'el lugar donde vive una familia',
    },
    {
      'word': 'FLOR',
      'icon': Icons.local_florist_rounded,
      'sentence': 'La abeja vuela hacia la ___ para tomar su néctar.',
      'meaning': 'la parte colorida de una planta que atrae a las abejas',
    },
    {
      'word': 'GATO',
      'icon': Icons.pets_rounded,
      'sentence': 'El ___ maúlla y persigue ratones.',
      'meaning': 'un animal doméstico que maúlla',
    },
    {
      'word': 'AUTO',
      'icon': Icons.directions_car_rounded,
      'sentence': 'Viajamos a la playa en ___.',
      'meaning': 'un vehículo con ruedas que sirve para transportarse',
    },
    {
      'word': 'BOLA',
      'icon': Icons.sports_soccer_rounded,
      'sentence': 'Los niños juegan con una ___ en el parque.',
      'meaning': 'un objeto redondo que se usa para jugar',
    },
    {
      'word': 'ARBOL',
      'icon': Icons.park_rounded,
      'sentence': 'Los pájaros hacen su nido en el ___.',
      'meaning': 'una planta grande con tronco, ramas y hojas',
    },
    {
      'word': 'AVION',
      'icon': Icons.airplanemode_active_rounded,
      'sentence': 'Para cruzar el océano, viajamos en ___.',
      'meaning': 'una máquina voladora que transporta personas por el aire',
    },
    {
      'word': 'LIBRO',
      'icon': Icons.menu_book_rounded,
      'sentence': 'Antes de dormir, leo un ___.',
      'meaning': 'un conjunto de páginas con historias o información',
    },
    {
      'word': 'ESTRELLA',
      'icon': Icons.star_rounded,
      'sentence': 'En una noche despejada se ven muchas ___ en el cielo.',
      'meaning': 'un cuerpo celeste que brilla en el cielo nocturno',
    },
    {
      'word': 'MONTAÑA',
      'icon': Icons.terrain_rounded,
      'sentence': 'Escalamos la ___ más alta de la región.',
      'meaning': 'una gran elevación natural del terreno',
    },
    {
      'word': 'BICICLETA',
      'icon': Icons.directions_bike_rounded,
      'sentence': 'Pedaleo mi ___ todos los días hasta el parque.',
      'meaning': 'un vehículo de dos ruedas que se mueve pedaleando',
    },
  ];

  /// Word pool available at the current level: short/common words only at
  /// level 1, widening to include longer, less common words as the player
  /// scores more. This is what makes the rising `_level` counter actually
  /// change the content instead of just triggering a congratulation dialog.
  List<Map<String, dynamic>> get _wordPool {
    if (_level <= 1) return _wordData.sublist(0, 5);
    if (_level == 2) return _wordData.sublist(0, 8);
    return _wordData;
  }

  /// Shows the objective dialog first, then generates the opening round —
  /// so the player knows what they're about to practice before questions
  /// start, instead of being dropped straight into the game.
  Future<void> _init() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Palabras Mágicas',
      objective: 'Vas a ampliar tu vocabulario y tu comprensión lectora',
      difficultyLabel: _difficultyLabel,
    );
    if (!context.mounted) return;
    _generateLevel();
  }

  void _generateLevel() {
    final random = Random();
    final pool = _wordPool;
    final data = pool[random.nextInt(pool.length)];
    _targetWord = data['word'];
    _targetIcon = data['icon'];
    _wordMeaning = data['meaning'] as String? ?? '';
    _options = [];
    _scrambledLetters = [];
    _sentenceText = '';

    if (age < 6) {
      // Logic: Identify First Letter
      // Display: _ O L
      // Options: Single letters
      _mode = MagicWordMode.firstLetter;
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
      _mode = MagicWordMode.missingLetter;
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
    } else if (_level >= 3) {
      // Logic: Sentence comprehension — read a sentence and pick the word
      // that completes it. Only unlocked once the player has proven they
      // know their words in isolation (levels 1-2).
      _mode = MagicWordMode.sentence;
      _sentenceText = data['sentence'] as String? ?? '';
      _correctOption = _targetWord;

      _options.add(_targetWord);
      while (_options.length < 4) {
        final randomWord = pool[random.nextInt(pool.length)]['word'] as String;
        if (!_options.contains(randomWord)) {
          _options.add(randomWord);
        }
      }
      _options.shuffle();
    } else {
      // Logic: Full Word Selection (Scramble visualized, pick correct word)
      // Visuals showing scrambled letters? Yes.
      // Options: Full Words.
      _mode = MagicWordMode.scramble;
      _scrambledLetters = _targetWord.split('')..shuffle();
      _correctOption = _targetWord;

      _options.add(_targetWord);
      while (_options.length < 4) {
        final randomData = pool[random.nextInt(pool.length)];
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

  Future<void> checkAnswer(String answer) async {
    final isCorrect = answer == _correctOption;
    skillTracker.record(_currentSkillId, correct: isCorrect);

    if (isCorrect) {
      _increaseScore();
      _nextLevel();
    } else {
      final gameOver = await _loseLife();
      if (gameOver) return;
    }
    _generateLevel();
  }

  void _increaseScore() {
    _score += 10;
    onScoreUpdate?.call(_score);
    if (_score % 50 == 0) {
      _showReward('¡Excelente!', '¡Has ganado puntos extras!');
    }
    // First correct answer of the session keeps the streak alive right
    // away — don't make the child wait until they run out of lives.
    if (!_playedTodayMarked) {
      _playedTodayMarked = true;
      sl<StudentRepository>().markPlayedToday();
    }
  }

  void _nextLevel() {
    if (_score % 100 == 0) {
      _level++;
      _showReward('¡Nivel $_level!', '¡Sigue así!');
    }
  }

  /// Explains why the answer was wrong, then loses a life — the piece the
  /// game was missing (it used to just decrement a life and silently
  /// regenerate the next question). Returns `true` if this ended the game
  /// (caller must not regenerate a round behind the game-over dialog).
  Future<bool> _loseLife() async {
    final correctAnswerText = _mode == MagicWordMode.firstLetter ||
            _mode == MagicWordMode.missingLetter
        ? _correctOption
        : _targetWord;

    await showAnswerExplanation(
      context,
      isCorrect: false,
      correctAnswerText: correctAnswerText,
      explanation: _explanationText,
      skillLabel: skillByKey(_currentSkillId).label,
    );
    if (!context.mounted) return true;

    _lives--;
    if (_lives == 0) {
      _gameOver();
      return true;
    }
    return false;
  }

  String get _explanationText {
    switch (_mode) {
      case MagicWordMode.firstLetter:
        return "La palabra es '$_targetWord' y empieza con la letra "
            "'$_correctOption'.";
      case MagicWordMode.missingLetter:
        return "La palabra es '$_targetWord'.";
      case MagicWordMode.scramble:
        return "La palabra es '$_targetWord': $_wordMeaning.";
      case MagicWordMode.sentence:
        return "'$_targetWord' completa la oración: $_wordMeaning.";
    }
  }

  void _showReward(String title, String content) {
    final isLevelUp = title.contains('Nivel');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        buttonText: '¡Continuar! →',
        type: isLevelUp ? DialogType.levelUp : DialogType.reward,
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _gameOver() {
    // Capture before reset — dialog builder runs on the next frame
    final finalScore = _score;
    final finalSkills = skillTracker.tallies;

    sl<StudentRepository>().recordScore(
      subjectKey: 'language',
      gameTitle: 'Palabras Mágicas',
      score: finalScore,
      skills: finalSkills,
      gameRoute: '/magic-words',
    );

    _score = 0;
    _lives = 3;
    _level = 1;
    _playedTodayMarked = false;
    skillTracker.reset();
    notifyListeners(); // reset state first so UI reflects new game

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
    notifyListeners();
  }
}
