import 'package:edu_play/features/practice_session/domain/repositories/practice_sessions_repository.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Compatibility facade for practice sessions.
///
/// Firebase access lives in `data/datasources`; new code should depend on
/// [PracticeSessionsRepository] directly through dependency injection.
class PracticeSessionsService {
  static PracticeSessionsRepository get _repository =>
      sl<PracticeSessionsRepository>();

  static Future<List<PracticeSession>> getAllSessions() {
    return _repository.getAllSessions();
  }

  static Future<List<PracticeSession>> getActiveSessions() {
    return _repository.getActiveSessions();
  }

  static Stream<List<PracticeSession>> watchCompletedSessions() {
    return _repository.watchCompletedSessions();
  }

  static Stream<List<PracticeSession>> watchActiveSessions() {
    return _repository.watchActiveSessions();
  }

  static Future<List<PracticeSession>> getActiveSessionsByChildId(
    String childProfileId,
  ) {
    return _repository.getActiveSessionsByChildId(childProfileId);
  }

  static Stream<List<PracticeSession>> watchAllSessionsByChild(
    String childProfileId,
  ) {
    return _repository.watchAllSessionsByChild(childProfileId);
  }

  static Future<PracticeSession?> findByPin(String pin) {
    return _repository.findByPin(pin);
  }

  static Future<PracticeSession> createSession({
    required String childProfileId,
    required String childName,
    required List<String> assignedGameIds,
  }) {
    return _repository.createSession(
      childProfileId: childProfileId,
      childName: childName,
      assignedGameIds: assignedGameIds,
    );
  }

  static Future<void> recordGameCompletion(
    String sessionId,
    String gameId, {
    int score = 100,
  }) {
    return _repository.recordGameCompletion(sessionId, gameId, score: score);
  }

  static Future<void> endSession(String sessionId) {
    return _repository.endSession(sessionId);
  }

  static Future<void> deleteSession(String sessionId) {
    return _repository.deleteSession(sessionId);
  }
}
