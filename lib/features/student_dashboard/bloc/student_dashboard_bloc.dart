import 'package:flutter/material.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/friends/models/friend_identity.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game.dart'
    show GameSubject;
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/features/sticker_album/domain/repositories/level_progress_repository.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/points_service.dart';

class StudentDashboardBloc extends ChangeNotifier {
  StudentDashboardBloc({
    this.username,
    required this.age,
    this.childProfile,
    this.isGuest = false,
  }) {
    _load();
  }

  final String? username;
  final int age;
  final ChildProfile? childProfile;

  final bool isGuest;

  final AuthRepository _authRepository = sl<AuthRepository>();
  final StudentRepository _studentRepository = sl<StudentRepository>();
  final LevelProgressRepository _levelProgressRepository =
      sl<LevelProgressRepository>();
  final ClassroomChallengesRepository _classroomChallengesRepository =
      sl<ClassroomChallengesRepository>();

  bool isLoading = true;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> challenges = [];
  List<Map<String, dynamic>> leaderboard = [];
  String myStudentId = '';
  int _guestPoints = 0;
  int? levelUpToShow;
  List<Sticker> newlyUnlockedStickers = [];
  String get _progressKey => childProfile?.id ?? username ?? 'guest';
  List<GameRecommendation> recommendations = [];
  GameSubject? weakestSubject;
  bool get isYoungChild => childProfile != null && childProfile!.age <= 5;

  /// True for a self-registered teen (15+) with their own email/password
  /// account — as opposed to a PIN-based child under a parent, who has no
  /// login of their own. Only independent students get an account/settings
  /// entry point (e.g. to delete their own account).
  bool get isIndependentStudent =>
      childProfile != null &&
      !isGuest &&
      !_authRepository.isCurrentUserAnonymous();

  String get displayName =>
      profile?['name'] as String? ??
      childProfile?.name ??
      username ??
      'Explorador';

  FriendIdentity? get friendIdentity {
    if (isGuest) return null;
    final uid = _authRepository.getCurrentUserUid();
    if (uid == null) return null;
    return FriendIdentity(
      uid: uid,
      childId: childProfile?.id,
      role: 'student',
      name: displayName,
    );
  }

  int get points =>
      isGuest ? _guestPoints : (profile?['points'] as num?)?.toInt() ?? 0;

  int get streak => (profile?['streak'] as num?)?.toInt() ?? 0;

  /// Days since `lastPlayedDate` (yyyy-MM-dd), or a large number if that
  /// field is missing/unparseable — treated the same as "long overdue".
  int get daysSinceLastPlayed {
    final raw = profile?['lastPlayedDate'] as String?;
    if (raw == null) return 999;
    final parts = raw.split('-');
    if (parts.length != 3) return 999;
    final date = DateTime(
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 1,
      int.tryParse(parts[2]) ?? 1,
    );
    final today = DateTime.now();
    final todayAtMidnight = DateTime(today.year, today.month, today.day);
    return todayAtMidnight.difference(date).inDays;
  }

  /// True once a streak has gone 2+ days without play — the child hasn't
  /// lost it yet, but it's paused until they either play normally (which
  /// resets it to a fresh streak of 1) or recover it via the streak-recovery
  /// quiz. Guests have no persistent streak, so they're excluded.
  bool get isStreakAtRisk =>
      childProfile != null && !isGuest && streak > 0 && daysSinceLastPlayed >= 2;

  /// True if the streak-recovery dialog should be shown right now: the
  /// streak is at risk and the child hasn't already been prompted today.
  Future<bool> get shouldPromptStreakRecovery async {
    if (!isStreakAtRisk) return false;
    final prompted = await StudentSessionNavigationService
        .wasStreakRecoveryPromptedToday(childProfile!.id);
    return !prompted;
  }

  int get level => StudentRepository.levelForPoints(points);

  int get xpIntoLevel => StudentRepository.xpIntoLevel(points);

  double get xpProgress => StudentRepository.xpProgress(points);

  List<Map<String, dynamic>> get activeChallenges =>
      challenges.where((c) => c['status'] == 'active').toList();

  Map<String, dynamic>? get missionOfTheDay =>
      activeChallenges.isEmpty ? null : activeChallenges.first;

  List<String> get unlockedStickerIds =>
      stickersUnlockedAtLevel(level).map((s) => s.id).toList();

  int get unlockedStickerCount => unlockedStickerIds.length;

  int get totalStickerCount => allStickers.length;

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
      if (isGuest) {
        _guestPoints = await PointsService.getPoints();
      } else {
        if (childProfile != null) {
          await _studentRepository.setActiveStudentId(childProfile!.id);
          await _studentRepository.ensureProfileForId(
            studentId: childProfile!.id,
            name: childProfile!.name,
            age: childProfile!.age,
          );
        } else {
          await _studentRepository.ensureProfile(
            name: username ?? 'Explorador',
            age: age,
          );
        }

        final results = await Future.wait([
          _studentRepository.getMyProfile(),
          _studentRepository.getLeaderboard(),
          _studentRepository.getMyStudentId(),
        ]);

        profile = results[0] as Map<String, dynamic>?;
        leaderboard = results[1] as List<Map<String, dynamic>>;
        myStudentId = results[2] as String;
        challenges =
            (await _classroomChallengesRepository.getChallengesForStudent(
          myStudentId,
        ))
                .map((c) => c.toStudentMap())
                .toList();

        if (childProfile != null) {
          recommendations =
              await ProgressRecommendationsService.getRecommendations(
                  childProfile!.id);
          weakestSubject = await ProgressRecommendationsService.weakestSubject(
            childProfile!.id,
          );
        }
      }

      await _detectLevelUp();
    } catch (e) {
      debugPrint('StudentDashboardBloc load error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _detectLevelUp() async {
    final lastCelebrated =
        await _levelProgressRepository.getLastCelebratedLevel(_progressKey);

    if (lastCelebrated == 0) {
      await _levelProgressRepository.setLastCelebratedLevel(
          _progressKey, level);
      return;
    }

    if (level > lastCelebrated) {
      levelUpToShow = level;
      final before = stickersUnlockedAtLevel(lastCelebrated).toSet();
      newlyUnlockedStickers = stickersUnlockedAtLevel(level)
          .where((s) => !before.contains(s))
          .toList();
    }
  }

  Future<void> acknowledgeLevelUp() async {
    if (levelUpToShow == null) return;
    await _levelProgressRepository.setLastCelebratedLevel(
        _progressKey, levelUpToShow!);
    levelUpToShow = null;
    newlyUnlockedStickers = [];
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<void> completeChallenge(String challengeId) async {
    final challenge = challenges.cast<Map<String, dynamic>?>().firstWhere(
          (c) => c?['id'] == challengeId,
          orElse: () => null,
        );
    if (challenge == null) return;

    final classId = challenge['class_id'] as String?;
    final memberId = challenge['member_id'] as String?;
    if (classId == null || memberId == null) return;

    await _classroomChallengesRepository.completeChallenge(
      classId: classId,
      memberId: memberId,
      challengeId: challengeId,
    );
    challenges = (await _classroomChallengesRepository.getChallengesForStudent(
      myStudentId,
    ))
        .map((c) => c.toStudentMap())
        .toList();
    notifyListeners();
  }
}
