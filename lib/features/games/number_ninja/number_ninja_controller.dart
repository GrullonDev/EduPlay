import 'dart:async';
import 'dart:math';

import 'package:edu_play/features/games/core/game_metadata.dart';
import 'package:edu_play/features/games/core/game_session_controller.dart';
import 'package:edu_play/features/games/number_ninja/number_ninja_module.dart';

/// Number Ninja: a math equation flashes on screen (e.g. "7 + 5 = 13") and
/// the player has a few seconds to judge whether it's true or false.
/// Correct answers score points; wrong answers (including letting the
/// timer run out) cost a life.
class NumberNinjaController extends GameSessionController {
  NumberNinjaController() : super(initialLives: 3);

  static const _questionDuration = Duration(seconds: 5);
  static const _tick = Duration(milliseconds: 100);
  static const _pointsPerCorrectAnswer = 10;

  final Random _random = Random();
  Timer? _timer;

  String _equationText = '';
  bool _isEquationTrue = false;
  Duration _timeRemaining = _questionDuration;

  @override
  GameMetadata get metadata => numberNinjaMetadata;

  /// The equation currently on screen, e.g. "7 + 5 = 13".
  String get equationText => _equationText;

  @override
  Duration? get timeRemaining => _timeRemaining;

  @override
  void startGame() {
    super.startGame();
    _nextQuestion();
  }

  @override
  void resetGame() {
    _timer?.cancel();
    startGame();
  }

  /// Called by the board UI when the player taps "Verdadero" / "Falso".
  void answer(bool userSaysTrue) {
    if (lives == 0) return;
    _timer?.cancel();
    if (userSaysTrue == _isEquationTrue) {
      addScore(_pointsPerCorrectAnswer);
    } else {
      loseLife();
    }
    if (lives > 0) _nextQuestion();
  }

  void _nextQuestion() {
    final a = _random.nextInt(10) + 1;
    final b = _random.nextInt(10) + 1;
    final useAddition = _random.nextBool();
    final first = useAddition ? a : (a > b ? a : b);
    final second = useAddition ? b : (a > b ? b : a);
    final correctResult = useAddition ? first + second : first - second;

    _isEquationTrue = _random.nextBool();
    final offset = (_random.nextInt(4) + 1) * (_random.nextBool() ? 1 : -1);
    final shownResult =
        _isEquationTrue ? correctResult : correctResult + offset;

    _equationText = '$first ${useAddition ? '+' : '-'} $second = $shownResult';
    _timeRemaining = _questionDuration;
    notifyListeners();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) {
      final remainingMs = _timeRemaining.inMilliseconds - _tick.inMilliseconds;
      if (remainingMs <= 0) {
        _timer?.cancel();
        _timeRemaining = Duration.zero;
        notifyListeners();
        loseLife();
        if (lives > 0) _nextQuestion();
        return;
      }
      _timeRemaining = Duration(milliseconds: remainingMs);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
