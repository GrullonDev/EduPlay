// Dart imports:
import 'dart:async';
import 'dart:math';

// Project imports:
import 'package:edu_play/features/games/core/game_metadata.dart';
import 'package:edu_play/features/games/core/game_session_controller.dart';
import 'package:edu_play/features/games/number_ninja/number_ninja_module.dart';

/// Number Ninja: a math equation flashes on screen (e.g. "7 + 5 = 13") and
/// the player has a few seconds to judge whether it's true or false.
/// Correct answers score points; wrong answers (including letting the
/// timer run out) cost a life.
class NumberNinjaController extends GameSessionController {
  NumberNinjaController() : super(initialLives: 3);

  static const _baseQuestionDuration = Duration(seconds: 5);
  static const _minQuestionDuration = Duration(milliseconds: 2000);
  static const _tick = Duration(milliseconds: 100);
  static const _pointsPerCorrectAnswer = 10;

  /// Every game is cálculo mental (mental math with addition/subtraction),
  /// so a single constant skillId covers all rounds.
  static const _skillId = 'calculo_mental';

  final Random _random = Random();
  Timer? _timer;

  String _equationText = '';
  bool _isEquationTrue = false;
  Duration _timeRemaining = _baseQuestionDuration;

  /// Correct response label ('Verdadero'/'Falso') and explanation for the
  /// equation currently on screen — precomputed alongside the question so
  /// they're ready to show immediately if the player answers wrong.
  String _correctAnswerLabel = 'Verdadero';
  String _explanationForCurrentQuestion = '';

  /// Non-null right after an incorrect answer (or a timeout) is graded.
  /// The page shows [showAnswerExplanation] while this is set, then calls
  /// [acknowledgeExplanation] to lose the life and move on — mirrors the
  /// pattern used by [GameSessionController.loseLife] but delays the actual
  /// life loss/game-over dialog until the player has read why they failed.
  String? _pendingExplanation;
  String? get pendingExplanation => _pendingExplanation;
  String? _pendingCorrectAnswerLabel;
  String? get pendingCorrectAnswerLabel => _pendingCorrectAnswerLabel;

  @override
  GameMetadata get metadata => numberNinjaMetadata;

  /// The equation currently on screen, e.g. "7 + 5 = 13".
  String get equationText => _equationText;

  @override
  Duration? get timeRemaining => _timeRemaining;

  /// Difficulty tier derived from the score earned this session (0-5): the
  /// number range widens and the time limit tightens as the player racks
  /// up points, so difficulty actually scales instead of staying fixed at
  /// 1-10 for the whole session.
  int get _tier => (score ~/ 50).clamp(0, 5);

  Duration get _questionDurationForTier => Duration(
        milliseconds: (_baseQuestionDuration.inMilliseconds - _tier * 400)
            .clamp(_minQuestionDuration.inMilliseconds,
                _baseQuestionDuration.inMilliseconds),
      );

  @override
  void startGame() {
    super.startGame();
    _pendingExplanation = null;
    _pendingCorrectAnswerLabel = null;
    _nextQuestion();
  }

  @override
  void resetGame() {
    _timer?.cancel();
    startGame();
  }

  /// Called by the board UI when the player taps "Verdadero" / "Falso".
  void answer(bool userSaysTrue) {
    if (lives == 0 || _pendingExplanation != null) return;
    _timer?.cancel();
    final isCorrect = userSaysTrue == _isEquationTrue;
    skillTracker.record(_skillId, correct: isCorrect);
    if (isCorrect) {
      addScore(_pointsPerCorrectAnswer);
      _nextQuestion();
    } else {
      _failCurrentQuestion();
    }
  }

  /// Freezes the round on a wrong answer (or timeout) and surfaces the
  /// explanation for the page to show. Life loss / game over is deferred to
  /// [acknowledgeExplanation] so the player reads *why* before anything
  /// else happens.
  void _failCurrentQuestion() {
    _timer?.cancel();
    _timeRemaining = Duration.zero;
    _pendingExplanation = _explanationForCurrentQuestion;
    _pendingCorrectAnswerLabel = _correctAnswerLabel;
    notifyListeners();
  }

  /// Called by the page once it has shown the explanation sheet for the
  /// last wrong answer and the player tapped "Siguiente".
  void acknowledgeExplanation() {
    if (_pendingExplanation == null) return;
    _pendingExplanation = null;
    _pendingCorrectAnswerLabel = null;
    loseLife();
    if (lives > 0) _nextQuestion();
  }

  void _nextQuestion() {
    final range = 10 + _tier * 4;
    final a = _random.nextInt(range) + 1;
    final b = _random.nextInt(range) + 1;
    final useAddition = _random.nextBool();
    final first = useAddition ? a : (a > b ? a : b);
    final second = useAddition ? b : (a > b ? b : a);
    final correctResult = useAddition ? first + second : first - second;
    final operatorSymbol = useAddition ? '+' : '-';

    _isEquationTrue = _random.nextBool();
    final offset = (_random.nextInt(4) + 1) * (_random.nextBool() ? 1 : -1);
    final shownResult =
        _isEquationTrue ? correctResult : correctResult + offset;

    _equationText = '$first $operatorSymbol $second = $shownResult';
    _correctAnswerLabel = _isEquationTrue ? 'Verdadero' : 'Falso';
    _explanationForCurrentQuestion = _isEquationTrue
        ? '$first $operatorSymbol $second = $shownResult, ¡la operación sí es correcta!'
        : '$first $operatorSymbol $second = $correctResult, no $shownResult.';

    _timeRemaining = _questionDurationForTier;
    notifyListeners();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) {
      final remainingMs = _timeRemaining.inMilliseconds - _tick.inMilliseconds;
      if (remainingMs <= 0) {
        skillTracker.record(_skillId, correct: false);
        _failCurrentQuestion();
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
