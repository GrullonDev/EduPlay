import 'package:edu_play/features/practice_session/models/practice_session.dart';

abstract class PracticeSessionsRepository {
  Future<List<PracticeSession>> getAllSessions();

  Future<List<PracticeSession>> getActiveSessions();

  Stream<List<PracticeSession>> watchCompletedSessions();

  Stream<List<PracticeSession>> watchActiveSessions();

  Future<List<PracticeSession>> getActiveSessionsByChildId(
    String childProfileId,
  );

  Stream<List<PracticeSession>> watchAllSessionsByChild(String childProfileId);

  Future<PracticeSession?> findByPin(String pin);

  Future<PracticeSession> createSession({
    required String childProfileId,
    required String childName,
    required List<String> assignedGameIds,
  });

  Future<void> recordGameCompletion(
    String sessionId,
    String gameId, {
    int score = 100,
  });

  Future<void> endSession(String sessionId);

  Future<void> deleteSession(String sessionId);
}
