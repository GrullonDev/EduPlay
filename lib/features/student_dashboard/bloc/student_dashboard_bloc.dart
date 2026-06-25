import 'package:flutter/material.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/teacher_dashboard/services/classroom_challenges_service.dart';
import 'package:edu_play/features/sticker_album/data/sticker_repository.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Loads and exposes everything the student dashboard ("Panel de Control")
/// needs: the Firestore gamification profile (points, streak, level), the
/// locally-stored teacher challenges, the class leaderboard and the
/// sticker collection progress.
class StudentDashboardBloc extends ChangeNotifier {
  StudentDashboardBloc({
    required this.username,
    required this.age,
    this.childProfile,
  }) {
    _load();
  }

  final String? username;
  final int age;
  final ChildProfile? childProfile;

  final StudentRepository _studentRepository = sl<StudentRepository>();
  final StickerRepository _stickerRepository = StickerRepository();

  bool isLoading = true;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> challenges = [];
  List<Map<String, dynamic>> leaderboard = [];
  List<String> unlockedStickerIds = [];
  String myStudentId = '';

  String get displayName =>
      profile?['name'] as String? ?? username ?? 'Explorador';

  int get points => (profile?['points'] as num?)?.toInt() ?? 0;

  int get streak => (profile?['streak'] as num?)?.toInt() ?? 0;

  int get level => StudentRepository.levelForPoints(points);

  int get xpIntoLevel => StudentRepository.xpIntoLevel(points);

  double get xpProgress => StudentRepository.xpProgress(points);

  List<Map<String, dynamic>> get activeChallenges =>
      challenges.where((c) => c['status'] == 'active').toList();

  Map<String, dynamic>? get missionOfTheDay =>
      activeChallenges.isEmpty ? null : activeChallenges.first;

  int get unlockedStickerCount => unlockedStickerIds.length;

  int get totalStickerCount => allStickers.length;

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
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
        _stickerRepository.getUnlockedStickers(),
        _studentRepository.getMyStudentId(),
      ]);

      profile = results[0] as Map<String, dynamic>?;
      leaderboard = results[1] as List<Map<String, dynamic>>;
      unlockedStickerIds = results[2] as List<String>;
      myStudentId = results[3] as String;
      challenges = (await ClassroomChallengesService.getChallengesForStudent(
        myStudentId,
      ))
          .map((c) => c.toStudentMap())
          .toList();
    } catch (e) {
      debugPrint('StudentDashboardBloc load error: $e');
    }

    isLoading = false;
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

    await ClassroomChallengesService.completeChallenge(
      classId: classId,
      memberId: memberId,
      challengeId: challengeId,
    );
    challenges = (await ClassroomChallengesService.getChallengesForStudent(
      myStudentId,
    ))
        .map((c) => c.toStudentMap())
        .toList();
    notifyListeners();
  }
}
