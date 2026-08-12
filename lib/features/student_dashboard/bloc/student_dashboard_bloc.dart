import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_play/data/datasources/student_datasource.dart'
    show PurchaseResult;
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game.dart'
    show GameSubject;
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/features/sticker_album/domain/repositories/level_progress_repository.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/points_service.dart';

/// Loads and exposes everything the student dashboard ("Panel de Control")
/// needs: the Firestore gamification profile (points, streak, level), the
/// locally-stored teacher challenges, the class leaderboard and the
/// sticker collection progress.
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

  /// True for a zero-write, zero-Firestore-read visitor (no PIN, no shared
  /// link, no cached session). Points come from [PointsService] instead of
  /// the gamification profile, and nothing is ensured/written on load.
  final bool isGuest;

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
  Set<String> _guestOwnedItemIds = {};
  String? _guestEquippedAvatarColorHex;
  String? _guestEquippedAvatarIcon;

  static const _guestOwnedItemsKey = 'edu_play_guest_owned_item_ids';
  static const _guestAvatarColorKey = 'edu_play_guest_avatar_color_hex';
  static const _guestAvatarIconKey = 'edu_play_guest_avatar_icon';

  /// Set (once) after [_load] detects the student's level increased since
  /// the last time the dashboard celebrated one — consumed by the UI via
  /// [acknowledgeLevelUp].
  int? levelUpToShow;
  List<Sticker> newlyUnlockedStickers = [];

  /// Scopes locally-persisted per-child state (level-celebration tracking).
  /// Guests share a single device-wide key, matching how [PointsService]
  /// already treats guest points as device-global rather than per-guest.
  String get _progressKey => childProfile?.id ?? username ?? 'guest';

  /// Up to 4 games the parent flagged for practice (never-played first, then
  /// lowest score). Only populated when [childProfile] is known.
  List<GameRecommendation> recommendations = [];

  /// Fallback when there are no specific recommendations yet: the subject
  /// with the lowest average score across all played games.
  GameSubject? weakestSubject;

  /// Kindergarten-age children (the minimum registrable age, 5) get a
  /// simplified experience with no "Panel de Control" — only the games tab.
  bool get isYoungChild => childProfile != null && childProfile!.age <= 5;

  String get displayName =>
      profile?['name'] as String? ?? username ?? 'Explorador';

  int get points =>
      isGuest ? _guestPoints : (profile?['points'] as num?)?.toInt() ?? 0;

  int get streak => (profile?['streak'] as num?)?.toInt() ?? 0;

  int get level => StudentRepository.levelForPoints(points);

  int get xpIntoLevel => StudentRepository.xpIntoLevel(points);

  double get xpProgress => StudentRepository.xpProgress(points);

  List<Map<String, dynamic>> get activeChallenges =>
      challenges.where((c) => c['status'] == 'active').toList();

  Map<String, dynamic>? get missionOfTheDay =>
      activeChallenges.isEmpty ? null : activeChallenges.first;

  Set<String> get ownedItemIds => isGuest
      ? _guestOwnedItemIds
      : Set<String>.from(profile?['ownedItemIds'] as List? ?? const []);

  String? get equippedAvatarColorHex => isGuest
      ? _guestEquippedAvatarColorHex
      : profile?['equippedAvatarColorHex'] as String?;

  String? get equippedAvatarIcon => isGuest
      ? _guestEquippedAvatarIcon
      : profile?['equippedAvatarIcon'] as String?;

  List<String> get unlockedStickerIds => {
        ...stickersUnlockedAtLevel(level).map((s) => s.id),
        ...ownedItemIds,
      }.toList();

  int get unlockedStickerCount => unlockedStickerIds.length;

  int get totalStickerCount => allStickers.length;

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
      if (isGuest) {
        _guestPoints = await PointsService.getPoints();
        await _loadGuestStore();
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
      // First-ever load for this child — record silently, no popup for
      // simply "reaching" level 1.
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

  /// Persists that [levelUpToShow] has been shown to the child, so it isn't
  /// shown again on the next load. Call only after the celebration UI has
  /// actually been displayed.
  Future<void> acknowledgeLevelUp() async {
    if (levelUpToShow == null) return;
    await _levelProgressRepository.setLastCelebratedLevel(
        _progressKey, levelUpToShow!);
    levelUpToShow = null;
    newlyUnlockedStickers = [];
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<void> _loadGuestStore() async {
    final prefs = await SharedPreferences.getInstance();
    _guestOwnedItemIds =
        prefs.getStringList(_guestOwnedItemsKey)?.toSet() ?? {};
    _guestEquippedAvatarColorHex = prefs.getString(_guestAvatarColorKey);
    _guestEquippedAvatarIcon = prefs.getString(_guestAvatarIconKey);
  }

  Future<PurchaseResult> purchaseGuestItem(StoreItem item) async {
    if (!isGuest) return PurchaseResult.error;
    if (_guestOwnedItemIds.contains(item.id)) {
      return PurchaseResult.alreadyOwned;
    }
    if (_guestPoints < item.cost) return PurchaseResult.insufficientPoints;

    _guestPoints -= item.cost;
    _guestOwnedItemIds = {..._guestOwnedItemIds, item.id};

    final prefs = await SharedPreferences.getInstance();
    await PointsService.setPoints(_guestPoints);
    await prefs.setStringList(_guestOwnedItemsKey, _guestOwnedItemIds.toList());
    notifyListeners();
    return PurchaseResult.success;
  }

  Future<void> equipGuestItem(StoreItem item) async {
    if (!isGuest || item.category == StoreCategory.sticker) return;
    if (!_guestOwnedItemIds.contains(item.id)) return;

    final prefs = await SharedPreferences.getInstance();
    if (item.category == StoreCategory.avatarColor) {
      _guestEquippedAvatarColorHex = item.colorHex;
      await prefs.setString(_guestAvatarColorKey, item.colorHex);
    } else {
      _guestEquippedAvatarIcon = item.id;
      await prefs.setString(_guestAvatarIconKey, item.id);
    }
    notifyListeners();
  }

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
