// Project imports:
import 'package:edu_play/features/practice_session/data/datasources/practice_sessions_datasource.dart';
import 'package:edu_play/features/practice_session/domain/repositories/practice_sessions_repository.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';

class FirestorePracticeSessionsRepository
    implements PracticeSessionsRepository {
  const FirestorePracticeSessionsRepository({required this.datasource});

  final PracticeSessionsDatasource datasource;

  @override
  Future<List<PracticeSession>> getAllSessions() {
    return datasource.getAllSessions();
  }

  @override
  Future<List<PracticeSession>> getActiveSessions() {
    return datasource.getActiveSessions();
  }

  @override
  Stream<List<PracticeSession>> watchCompletedSessions() {
    return datasource.watchCompletedSessions();
  }

  @override
  Stream<List<PracticeSession>> watchActiveSessions() {
    return datasource.watchActiveSessions();
  }

  @override
  Future<List<PracticeSession>> getActiveSessionsByChildId(
    String childProfileId,
  ) {
    return datasource.getActiveSessionsByChildId(childProfileId);
  }

  @override
  Stream<List<PracticeSession>> watchAllSessionsByChild(
    String childProfileId,
  ) {
    return datasource.watchAllSessionsByChild(childProfileId);
  }

  @override
  Future<PracticeSession?> findByPin(String pin) {
    return datasource.findByPin(pin);
  }

  @override
  Future<PracticeSession> createSession({
    required String childProfileId,
    required String childName,
    required List<String> assignedGameIds,
  }) {
    return datasource.createSession(
      childProfileId: childProfileId,
      childName: childName,
      assignedGameIds: assignedGameIds,
    );
  }

  @override
  Future<void> recordGameCompletion(
    String sessionId,
    String gameId, {
    int score = 100,
  }) {
    return datasource.recordGameCompletion(sessionId, gameId, score: score);
  }

  @override
  Future<void> endSession(String sessionId) {
    return datasource.endSession(sessionId);
  }

  @override
  Future<void> deleteSession(String sessionId) {
    return datasource.deleteSession(sessionId);
  }
}
