import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game_registry_adapter.dart';
import 'package:edu_play/features/practice_session/domain/repositories/practice_sessions_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

// ── Game catalog metadata ─────────────────────────────────────────────────────
// Keep in sync with the games listed in games_catalog_page.dart

const _kGameNames = {
  'math_adventure': 'Aventura Matemática',
  'magic_words': 'Palabras Mágicas',
  'fun_english': 'Inglés Divertido',
  'nature_explorers': 'Exploradores de la Naturaleza',
  'time_travel': 'Viaje en el Tiempo',
  'treasure_map': 'Mapa del Tesoro',
  'artists_in_action': 'Artistas en Acción',
  'color_concert': 'Concierto de Colores',
  'sports_challenge': 'Desafío Deportivo',
};

// ── Recommendation model ──────────────────────────────────────────────────────

class GameRecommendation {
  const GameRecommendation({
    required this.gameId,
    required this.gameName,
    required this.avgScore,
    required this.timesPlayed,
    required this.reason,
  });

  final String gameId;
  final String gameName;
  final int avgScore; // 0–100, or -1 if never played
  final int timesPlayed;
  final String reason; // human-readable reason e.g. "Puntuación baja (45/100)"

  bool get neverPlayed => timesPlayed == 0;
  bool get needsPractice => neverPlayed || avgScore < 70;
}

// ── Service ───────────────────────────────────────────────────────────────────

class ProgressRecommendationsService {
  static PracticeSessionsRepository get _sessionsRepository {
    init();
    return sl<PracticeSessionsRepository>();
  }

  /// Analyses all completed sessions for [childProfileId] and returns games
  /// that need practice (never played OR average score < 70).
  static Future<List<GameRecommendation>> getRecommendations(
      String childProfileId) async {
    final allSessions = await _sessionsRepository.getAllSessions();

    // Filter to this child's completed sessions
    final childSessions = allSessions
        .where((s) => s.childProfileId == childProfileId && !s.isActive)
        .toList();

    // Aggregate scores per game
    final Map<String, List<int>> scoresByGame = {};
    final Map<String, int> playCountByGame = {};

    for (final session in childSessions) {
      for (final gameId in session.assignedGameIds) {
        playCountByGame[gameId] = (playCountByGame[gameId] ?? 0) + 1;
        final score = session.scoreMap[gameId];
        if (score != null) {
          scoresByGame.putIfAbsent(gameId, () => []).add(score);
        }
      }
    }

    // Collect all assigned games across all sessions
    final allAssigned = allSessions
        .where((s) => s.childProfileId == childProfileId)
        .expand((s) => s.assignedGameIds)
        .toSet();

    final recommendations = <GameRecommendation>[];

    for (final gameId in allAssigned) {
      final scores = scoresByGame[gameId] ?? [];
      final timesPlayed = playCountByGame[gameId] ?? 0;
      final avgScore = scores.isEmpty
          ? -1
          : (scores.reduce((a, b) => a + b) / scores.length).round();

      final gameName = _kGameNames[gameId] ?? gameId;

      String reason;
      if (timesPlayed == 0) {
        reason = 'Nunca jugado';
      } else if (avgScore < 50) {
        reason = 'Necesita refuerzo ($avgScore/100)';
      } else if (avgScore < 70) {
        reason = 'Puede mejorar ($avgScore/100)';
      } else {
        continue; // Good score — skip
      }

      recommendations.add(GameRecommendation(
        gameId: gameId,
        gameName: gameName,
        avgScore: avgScore,
        timesPlayed: timesPlayed,
        reason: reason,
      ));
    }

    // Sort: never played first, then lowest score
    recommendations.sort((a, b) {
      if (a.neverPlayed && !b.neverPlayed) return -1;
      if (!a.neverPlayed && b.neverPlayed) return 1;
      return a.avgScore.compareTo(b.avgScore);
    });

    return recommendations.take(4).toList(); // top 4 recommendations
  }

  /// Returns the [GameSubject] with the lowest average score among games the
  /// child has actually played, or null if no scored sessions exist yet.
  static Future<GameSubject?> weakestSubject(String childProfileId) async {
    final allSessions = await _sessionsRepository.getAllSessions();
    final childSessions = allSessions
        .where((s) => s.childProfileId == childProfileId && !s.isActive);

    final Map<GameSubject, List<int>> scoresBySubject = {};
    final gamesById = {for (final g in effectiveCatalogGames) g.id: g};

    for (final session in childSessions) {
      for (final gameId in session.assignedGameIds) {
        final score = session.scoreMap[gameId];
        final subject = gamesById[gameId]?.subject;
        if (score != null && subject != null) {
          scoresBySubject.putIfAbsent(subject, () => []).add(score);
        }
      }
    }

    if (scoresBySubject.isEmpty) return null;

    GameSubject? weakest;
    double lowestAvg = 101;
    scoresBySubject.forEach((subject, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg < lowestAvg) {
        lowestAvg = avg;
        weakest = subject;
      }
    });
    return weakest;
  }
}
