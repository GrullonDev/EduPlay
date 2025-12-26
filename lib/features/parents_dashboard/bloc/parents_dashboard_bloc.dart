import 'package:flutter/material.dart';
import 'package:edu_play/data/datasources/local/database_helper.dart';

class ParentsDashboardBloc with ChangeNotifier {
  ParentsDashboardBloc() {
    _loadData();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _children = [];
  Map<int, List<Map<String, dynamic>>> _scores = {};
  bool _isLoading = true;

  List<Map<String, dynamic>> get children => _children;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> getScoresForChild(int childId) {
    return _scores[childId] ?? [];
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Children
      _children = await _dbHelper.getChildren();

      // 2. Fetch Scores for each child
      for (var child in _children) {
        int id = child['id'];
        final childScores = await _dbHelper.getScores(id);
        _scores[id] = childScores;
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
