import 'dart:math';
import 'package:flutter/material.dart';
import 'package:edu_play/features/nature_explorers/repositories/nature_explorers_repository.dart';

class NatureItem {
  final String name;
  final IconData icon;
  final Color color;

  NatureItem({required this.name, required this.icon, required this.color});
}

class NatureExplorersProvider with ChangeNotifier {
  final BuildContext context;
  final int age;

  int _score = 0;
  int _level = 1;
  String _targetName = '';
  List<NatureItem> _currentItems = [];
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  bool _isCorrect = false;

  int get score => _score;
  int get level => _level;
  String get targetName => _targetName;
  List<NatureItem> get currentItems => _currentItems;
  String get feedbackMessage => _feedbackMessage;
  Color get feedbackColor => _feedbackColor;
  bool get isCorrect => _isCorrect;

  NatureExplorersProvider({
    required this.context,
    required this.age,
    required NatureExplorersRepository repository,
  }) : _repository = repository {
    _init();
  }

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
        _startNewLevel();
      }
    } catch (e) {
      debugPrint('Error loading items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    // Shuffle and pick items
    var availableItems = List<NatureItem>.from(_allItems)..shuffle();
    _currentItems = availableItems.take(numberOfItems).toList();

    // Pick a target
    if (_currentItems.isNotEmpty) {
      _targetName = _currentItems[Random().nextInt(_currentItems.length)].name;
    }

    notifyListeners();
  }

  void checkItem(NatureItem item) {
    if (_isCorrect) return; // Prevent clicking after success

    if (item.name == _targetName) {
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
      _feedbackMessage = 'Inténtalo de nuevo';
      _feedbackColor = Colors.red;
      notifyListeners();

      // Clear error message after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (!_isCorrect) {
          _feedbackMessage = '';
          _feedbackColor = Colors.transparent;
          notifyListeners();
        }
      });
    }
  }

  void resetGame() {
    _score = 0;
    _level = 1;
    _startNewLevel();
  }
}
