import 'package:flutter/foundation.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/game_metadata.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Shared gameplay state machine every minigame's controller extends.
///
/// Centralizes the score/lives bookkeeping and score persistence that,
/// before this engine, every game (math_adventure, etc.) reimplemented by
/// hand. Subclasses own their own domain state (current question, board
/// layout, timers…) and call [addScore] / [loseLife] to drive this base.
///
/// Kept free of Flutter widget-building code on purpose: this is a
/// ChangeNotifier consumed by a page/`Consumer`, not a widget factory —
/// keeping UI out of it makes it trivially unit-testable.
abstract class GameSessionController extends ChangeNotifier {
  GameSessionController({this.initialLives = 3});

  /// Lives the game starts (and resets) with. Use 0 for games that don't
  /// track lives — [lives] will then just stay 0 and the header hides it.
  final int initialLives;

  int _score = 0;
  int _lives = 0;

  /// Per-skill correct/total tally for the current session. Subclasses call
  /// `skillTracker.record(skillId, correct: ...)` after grading each answer
  /// so [submitScore] can report concrete skill mastery, not just points.
  final SkillTracker skillTracker = SkillTracker();

  int get score => _score;
  int get lives => _lives;

  /// Null hides the timer chip in [GameHeader]. Override in subclasses
  /// that run a countdown (per-question or per-round).
  Duration? get timeRemaining => null;

  GameMetadata get metadata;

  /// (Re)starts a fresh round: resets score/lives. Subclasses override to
  /// also generate their first question/board, calling super first.
  @mustCallSuper
  void startGame() {
    _score = 0;
    _lives = initialLives;
    skillTracker.reset();
    notifyListeners();
  }

  /// Alias kept distinct from [startGame] so call sites read intent
  /// clearly ("the player asked to reset" vs "the page just opened").
  void resetGame() => startGame();

  void addScore(int points) {
    _score += points;
    notifyListeners();
    onScoreChanged();
  }

  void loseLife() {
    if (initialLives <= 0 || _lives <= 0) return;
    _lives--;
    notifyListeners();
    if (_lives == 0) onGameOver();
  }

  /// Hook for reward dialogs / level-ups. No-op by default.
  void onScoreChanged() {}

  /// Called once when lives hit 0. Always persists the score — subclasses
  /// that add UI reactions (e.g. showing a dialog) must call super so the
  /// score isn't lost.
  @mustCallSuper
  void onGameOver() {
    submitScore();
  }

  Future<void> submitScore() {
    return sl<StudentRepository>().recordScore(
      subjectKey: metadata.subjectKey,
      gameTitle: metadata.title,
      score: _score,
      skills: skillTracker.tallies,
      gameRoute: metadata.route,
    );
  }
}
