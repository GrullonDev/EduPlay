import 'package:edu_play/shared/data/skill_catalog.dart';

/// Correct/total tally for one skill, accumulated during a single game
/// session and persisted alongside the score so reports can show mastery
/// per skill instead of just raw points.
class SkillTally {
  const SkillTally({required this.correct, required this.total});

  final int correct;
  final int total;

  double get accuracy => total == 0 ? 0 : correct / total;

  Map<String, dynamic> toMap() => {'correct': correct, 'total': total};

  static SkillTally fromMap(Map<String, dynamic> map) => SkillTally(
        correct: (map['correct'] as num?)?.toInt() ?? 0,
        total: (map['total'] as num?)?.toInt() ?? 0,
      );
}

/// Accumulates per-skill correct/total tallies as a player answers
/// questions, so a game controller can pass a single summary to
/// `StudentRepository.recordScore(skills: ...)` at game over.
class SkillTracker {
  final Map<String, SkillTally> _tallies = {};

  void record(String skillId, {required bool correct}) {
    final prev = _tallies[skillId] ?? const SkillTally(correct: 0, total: 0);
    _tallies[skillId] = SkillTally(
      correct: prev.correct + (correct ? 1 : 0),
      total: prev.total + 1,
    );
  }

  Map<String, SkillTally> get tallies => Map.unmodifiable(_tallies);

  bool get isEmpty => _tallies.isEmpty;

  void reset() => _tallies.clear();

  Map<String, dynamic> toFirestoreMap() =>
      _tallies.map((key, value) => MapEntry(key, value.toMap()));
}

/// Formats a session's skill tallies as "Suma: 4/5 · Resta: 2/5", for the
/// game-over dialog. Empty tallies (nothing graded yet) are skipped.
/// Returns '' when there's nothing to show.
String skillSummaryText(Map<String, SkillTally> tallies) {
  final parts = tallies.entries
      .where((entry) => entry.value.total > 0)
      .map((entry) =>
          '${skillByKey(entry.key).label}: ${entry.value.correct}/${entry.value.total}');
  return parts.join(' · ');
}
