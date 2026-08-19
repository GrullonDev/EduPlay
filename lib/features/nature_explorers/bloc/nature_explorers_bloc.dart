import 'dart:math';
import 'package:flutter/material.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/features/nature_explorers/repositories/nature_explorers_repository.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';
import 'package:edu_play/utils/injection_container.dart';

class NatureItem {
  NatureItem({
    required this.name,
    required this.icon,
    required this.color,
    this.category = 'naturaleza',
    this.funFact = '',
  });
  final String name;
  final IconData icon;
  final Color color;

  /// Conceptual category (e.g. "cielo", "animales") used to pick
  /// harder-to-tell-apart distractors as the level goes up.
  final String category;

  /// Short factual note shown when the player misses this item.
  final String funFact;
}

class NatureExplorersProvider with ChangeNotifier {
  NatureExplorersProvider({
    required this.context,
    required this.age,
    required NatureExplorersRepository repository,
  }) : _repository = repository {
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }
  final BuildContext context;
  final int age;

  /// Per-skill correct/total tally for the current session, sent alongside
  /// the score when the game ends.
  final SkillTracker skillTracker = SkillTracker();

  static const String _skillId = 'ciencias_naturales';

  int _score = 0;
  int _level = 1;
  String _targetName = '';
  List<NatureItem> _currentItems = [];
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  bool _isCorrect = false;
  bool _isBusy = false;

  int get score => _score;
  int get level => _level;
  String get targetName => _targetName;
  List<NatureItem> get currentItems => _currentItems;
  String get feedbackMessage => _feedbackMessage;
  Color get feedbackColor => _feedbackColor;
  bool get isCorrect => _isCorrect;

  final NatureExplorersRepository _repository;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // List of nature items (fetched from DB)
  List<NatureItem> _allItems = [];

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allItems = await _repository.getItems();
      if (_allItems.isNotEmpty) {
        if (!context.mounted) return;
        await showGameObjectiveIntro(
          context,
          gameTitle: 'Exploradores de la Naturaleza',
          objective:
              'Vas a identificar elementos de la naturaleza: se te dirá un '
              'nombre (un animal, una planta, algo del cielo o un '
              'elemento) y deberás tocar el ícono que le corresponde entre '
              'varias opciones parecidas.',
          difficultyLabel: _difficultyLabel(),
        );
        if (!context.mounted) return;
        _startNewLevel();
      }
    } catch (e) {
      debugPrint('Error loading items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _difficultyLabel() {
    if (age < 6) return 'Principiante';
    if (age <= 8) return 'Intermedio';
    return 'Avanzado';
  }

  void _startNewLevel() {
    if (_allItems.isEmpty) return;

    _feedbackMessage = '';
    _feedbackColor = Colors.transparent;
    _isCorrect = false;

    // Determine number of items based on level/age (simplified for now)
    int numberOfItems = min(4 + (_level ~/ 2), 12);

    // Ensure we don't try to take more items than available
    numberOfItems = min(numberOfItems, _allItems.length);

    // Pick a target first, then build the grid around it so distractor
    // difficulty (not just grid size) can scale with the level.
    final target = _allItems[Random().nextInt(_allItems.length)];
    _targetName = target.name;
    _currentItems = _pickItemsForLevel(target, numberOfItems);

    notifyListeners();
  }

  /// Builds the grid shown to the player: the target plus distractors.
  /// As the level rises, distractors are increasingly drawn from the
  /// target's own category (e.g. confusing "Sol" with "Luna" and
  /// "Estrella") instead of random unrelated items, so telling the right
  /// icon apart gets genuinely harder — not just more crowded.
  List<NatureItem> _pickItemsForLevel(NatureItem target, int count) {
    final sameCategory = _allItems
        .where((i) => i.category == target.category && i.name != target.name)
        .toList()
      ..shuffle();
    final otherCategory = _allItems
        .where((i) => i.category != target.category)
        .toList()
      ..shuffle();

    // Similarity bias grows from ~17% at level 1 to 100% at level 6+.
    final similarityBias = min(_level, 6) / 6;
    final desiredSimilar = ((count - 1) * similarityBias).round();

    final chosen = <NatureItem>[target];
    chosen.addAll(sameCategory.take(desiredSimilar));
    final remainingSlots = count - chosen.length;
    if (remainingSlots > 0) {
      chosen.addAll(otherCategory.take(remainingSlots));
    }

    // Small category pools may leave the grid short; top up with whatever
    // items haven't been used yet.
    if (chosen.length < count) {
      final used = chosen.map((i) => i.name).toSet();
      final leftover =
          _allItems.where((i) => !used.contains(i.name)).toList()..shuffle();
      chosen.addAll(leftover.take(count - chosen.length));
    }

    chosen.shuffle();
    return chosen;
  }

  Future<void> checkItem(NatureItem item) async {
    if (_isCorrect || _isBusy) return; // Prevent clicking mid-round

    if (item.name == _targetName) {
      skillTracker.record(_skillId, correct: true);
      _score += 10;
      _level++;
      _feedbackMessage = '¡Correcto! ¡Muy bien!';
      _feedbackColor = Colors.green;
      _isCorrect = true;
      notifyListeners();

      // Delay to show feedback before next level
      Future.delayed(const Duration(seconds: 2), () {
        _startNewLevel();
      });
    } else {
      skillTracker.record(_skillId, correct: false);
      _isBusy = true;
      NatureItem? target;
      for (final candidate in _allItems) {
        if (candidate.name == _targetName) {
          target = candidate;
          break;
        }
      }
      notifyListeners();

      await showAnswerExplanation(
        context,
        isCorrect: false,
        correctAnswerText: _targetName,
        explanation: (target != null && target.funFact.isNotEmpty)
            ? target.funFact
            : 'Ese no era el elemento correcto. ¡Sigue buscando!',
        skillLabel: skillByKey(_skillId).label,
      );
      if (!context.mounted) return;

      _isBusy = false;
      _feedbackMessage = '';
      _feedbackColor = Colors.transparent;
      notifyListeners();
    }
  }

  void resetGame() {
    _score = 0;
    _level = 1;
    skillTracker.reset();
    _startNewLevel();
  }

  @override
  void dispose() {
    sl<StudentRepository>().recordScore(
      subjectKey: 'science',
      gameTitle: 'Exploradores de la Naturaleza',
      score: _score,
      skills: skillTracker.tallies,
      gameRoute: '/nature-explorers',
    );
    super.dispose();
  }
}

