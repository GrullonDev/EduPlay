import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_play/data/datasources/student_datasource.dart'
    show PurchaseResult;
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game.dart'
    show GameSubject;
import 'package:edu_play/features/parents_dashboard/domain/repositories/parent_dashboard_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/features/store/models/purchase_transaction.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/store/services/store_catalog_cache.dart';
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/features/sticker_album/domain/repositories/level_progress_repository.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
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
  final SubscriptionRepository _subscriptionRepository =
      sl<SubscriptionRepository>();
  final ParentDashboardRepository _parentDashboardRepository =
      sl<ParentDashboardRepository>();
  final StoreCatalogCache _catalogCache = sl<StoreCatalogCache>();

  bool isLoading = true;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> challenges = [];
  List<Map<String, dynamic>> leaderboard = [];
  String myStudentId = '';
  int _guestPoints = 0;
  Set<String> _guestOwnedItemIds = {};
  String? _guestEquippedAvatarColorHex;
  String? _guestEquippedAvatarIcon;
  Map<String, DateTime> _guestPurchaseDates = {};
  List<PurchaseTransaction> _guestTransactions = [];

  static const guestPurchaseLimit = 3;
  static const _guestOwnedItemsKey = 'edu_play_guest_owned_item_ids';
  static const _guestAvatarColorKey = 'edu_play_guest_avatar_color_hex';
  static const _guestAvatarIconKey = 'edu_play_guest_avatar_icon';
  static const _guestPurchaseDatesKey = 'edu_play_guest_purchase_dates';
  static const _guestTransactionsKey = 'edu_play_guest_transactions';
  static const _guestSyncedKey = 'edu_play_guest_synced';

  bool isProSubscriber = false;

  /// Loaded (for non-guest students only) from the parent's Quick Controls —
  /// drives [requiresPurchaseApproval] and the spend-limit getters below.
  /// Null until [_load] resolves it, or if the lookup failed.
  ParentQuickControls? _parentControls;

  /// When true, [StoreBloc.purchase] must hold the purchase for approval
  /// instead of spending points immediately.
  bool get requiresPurchaseApproval =>
      !isGuest && (_parentControls?.requirePurchaseApproval ?? false);

  /// Points already spent within the current spend-limit window (see
  /// [spendLimitPeriod]) — computed from the transaction ledger, not a
  /// mutable counter, so it can't drift out of sync. Only loaded when a
  /// limit is actually enabled, to avoid an extra read otherwise.
  int spentInWindow = 0;

  bool get spendLimitEnabled =>
      !isGuest && (_parentControls?.spendLimitEnabled ?? false);

  int get spendLimitAmount => _parentControls?.spendLimitAmount ?? 0;

  SpendLimitPeriod get spendLimitPeriod =>
      _parentControls?.spendLimitPeriod ?? SpendLimitPeriod.weekly;

  bool get spendLimitReached =>
      spendLimitEnabled && spentInWindow >= spendLimitAmount;

  int get spendLimitRemaining =>
      (spendLimitAmount - spentInWindow).clamp(0, spendLimitAmount);

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

  /// Purchase date per owned item id, keyed the same way as [ownedItemIds]
  /// (avatar items and stickers share the id namespace). Registered
  /// students read Firestore's `purchasedAt` map (server timestamps);
  /// guests read the local `_guestPurchaseDates` map instead. Items bought
  /// before this feature shipped simply have no entry.
  Map<String, DateTime> get purchaseDates {
    if (isGuest) return _guestPurchaseDates;
    final raw = profile?['purchasedAt'] as Map?;
    if (raw == null) return {};
    return {
      for (final entry in raw.entries)
        if (entry.value is Timestamp)
          entry.key as String: (entry.value as Timestamp).toDate(),
    };
  }

  /// Item ids awaiting parent approval (see [requiresPurchaseApproval]).
  /// Always empty for guests — there is no parent to approve a guest's
  /// purchase, so guest purchases are never held for approval.
  Set<String> get pendingPurchaseItemIds {
    if (isGuest) return {};
    final raw = profile?['pendingPurchases'] as Map?;
    return raw?.keys.cast<String>().toSet() ?? {};
  }

  int get guestPurchasedItemCount => isGuest ? _guestOwnedItemIds.length : 0;

  bool get hasGuestPurchasesRemaining =>
      !isGuest || guestPurchasedItemCount < guestPurchaseLimit;

  int get guestPurchasesRemaining => isGuest
      ? (guestPurchaseLimit - guestPurchasedItemCount)
          .clamp(0, guestPurchaseLimit)
      : guestPurchaseLimit;

  bool isProOnlyItem(StoreItem item) => item.isProOnly;

  bool isLevelLocked(StoreItem item) => level < item.minLevel;

  bool canAccessItem(StoreItem item) =>
      (!isProOnlyItem(item) || isProSubscriber) && !isLevelLocked(item);

  List<String> get unlockedStickerIds {
    final proStickerIds = _catalogCache.items
        .where((item) => item.category == StoreCategory.sticker)
        .where((item) => item.isProOnly)
        .map((item) => item.id)
        .toSet();
    final eligibleOwnedIds = ownedItemIds.where(
      (id) => isProSubscriber || !proStickerIds.contains(id),
    );

    return {
      ...stickersUnlockedAtLevel(level).map((s) => s.id),
      ...eligibleOwnedIds,
    }.toList();
  }

  int get unlockedStickerCount => unlockedStickerIds.length;

  int get totalStickerCount => allStickers.length;

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
      await _catalogCache.ensureLoaded();

      if (isGuest) {
        isProSubscriber = false;
        _guestPoints = await PointsService.getPoints();
        await _loadGuestStore();
      } else {
        await _loadSubscriptionStatus();
        await _loadPurchaseApprovalSetting();
        final parentUid = childProfile?.parentUid;
        if (childProfile != null) {
          await _studentRepository.setActiveStudentId(childProfile!.id);
          await _studentRepository.ensureProfileForId(
            studentId: childProfile!.id,
            name: childProfile!.name,
            age: childProfile!.age,
            parentUid: parentUid,
          );
        } else {
          await _studentRepository.ensureProfile(
            name: username ?? 'Explorador',
            age: age,
            parentUid: parentUid,
          );
        }

        final resolvedStudentId =
            childProfile?.id ?? await _studentRepository.getMyStudentId();
        await _maybeSyncGuestPurchases(resolvedStudentId);

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

        if (spendLimitEnabled) {
          spentInWindow = await _studentRepository.getSpentInWindow(
            myStudentId,
            days: spendLimitPeriod.windowDays,
          );
        }

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

    final rawDates = prefs.getString(_guestPurchaseDatesKey);
    if (rawDates == null) {
      _guestPurchaseDates = {};
    } else {
      try {
        final decoded = jsonDecode(rawDates) as Map<String, dynamic>;
        _guestPurchaseDates = decoded.map(
          (id, iso) => MapEntry(id, DateTime.parse(iso as String)),
        );
      } catch (_) {
        _guestPurchaseDates = {};
      }
    }

    final rawTransactions = prefs.getStringList(_guestTransactionsKey);
    _guestTransactions = rawTransactions == null
        ? []
        : rawTransactions
            .map((raw) {
              try {
                return PurchaseTransaction.fromJson(
                    jsonDecode(raw) as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<PurchaseTransaction>()
            .toList();
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final parentUid = childProfile?.parentUid;
      final subscription = parentUid != null && parentUid.isNotEmpty
          ? await _subscriptionRepository.getSubscriptionForUser(parentUid)
          : await _subscriptionRepository.getSubscription();
      isProSubscriber = subscription.isPro;
    } catch (_) {
      isProSubscriber = false;
    }
  }

  Future<void> _loadPurchaseApprovalSetting() async {
    try {
      final parentUid = childProfile?.parentUid;
      _parentControls = parentUid != null && parentUid.isNotEmpty
          ? await _parentDashboardRepository.getQuickControlsForUser(parentUid)
          : await _parentDashboardRepository.getQuickControls();
    } catch (_) {
      _parentControls = null;
    }
  }

  /// One-time merge of a guest's locally-accumulated points into a
  /// freshly-registered Firestore profile — e.g. after a guest taps
  /// "Registrarse" from the Tienda and later links this device with a PIN.
  /// Gated by [_guestSyncedKey] so it only ever runs once per device.
  ///
  /// Points-only, not items — see the doc comment on
  /// `StudentDatasource.syncGuestPoints` for why: a guest's owned items have
  /// no server-side validation while in guest mode, so carrying them over
  /// would let a manipulated guest client smuggle a free PRO item past
  /// firestore.rules' purchase checks. Any avatar cosmetics/stickers picked
  /// before registering are cleared, not carried over.
  Future<void> _maybeSyncGuestPurchases(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_guestSyncedKey) ?? false) return;

    final guestPoints = await PointsService.getPoints();
    if (guestPoints > 0) {
      await _studentRepository.syncGuestPoints(
        studentId: studentId,
        points: guestPoints,
      );
    }

    await PointsService.reset();
    await prefs.remove(_guestOwnedItemsKey);
    await prefs.remove(_guestAvatarColorKey);
    await prefs.remove(_guestAvatarIconKey);
    await prefs.remove(_guestPurchaseDatesKey);
    await prefs.remove(_guestTransactionsKey);
    await prefs.setBool(_guestSyncedKey, true);
  }

  Future<PurchaseResult> purchaseGuestItem(StoreItem item) async {
    if (!isGuest || !canAccessItem(item)) return PurchaseResult.error;
    if (_guestOwnedItemIds.contains(item.id)) {
      return PurchaseResult.alreadyOwned;
    }
    if (!hasGuestPurchasesRemaining) return PurchaseResult.error;
    if (_guestPoints < item.cost) return PurchaseResult.insufficientPoints;

    final balanceBefore = _guestPoints;
    _guestPoints -= item.cost;
    _guestOwnedItemIds = {..._guestOwnedItemIds, item.id};
    _guestPurchaseDates = {..._guestPurchaseDates, item.id: DateTime.now()};
    _guestTransactions = [
      PurchaseTransaction(
        itemId: item.id,
        itemName: item.name,
        cost: item.cost,
        balanceBefore: balanceBefore,
        balanceAfter: _guestPoints,
        createdAt: DateTime.now(),
        type: PurchaseTransactionType.guestPurchase,
      ),
      ..._guestTransactions,
    ];

    final prefs = await SharedPreferences.getInstance();
    await PointsService.setPoints(_guestPoints);
    await prefs.setStringList(_guestOwnedItemsKey, _guestOwnedItemIds.toList());
    await prefs.setString(
      _guestPurchaseDatesKey,
      jsonEncode(_guestPurchaseDates.map(
        (id, date) => MapEntry(id, date.toIso8601String()),
      )),
    );
    await prefs.setStringList(
      _guestTransactionsKey,
      _guestTransactions.take(50).map((t) => jsonEncode(t.toJson())).toList(),
    );
    notifyListeners();
    return PurchaseResult.success;
  }

  /// Submits [item] for parent approval instead of spending points right
  /// away. Only meaningful for registered (non-guest) students — see
  /// [requiresPurchaseApproval] and [pendingPurchaseItemIds].
  Future<PurchaseResult> requestPurchaseItem(StoreItem item) async {
    if (isGuest || !canAccessItem(item)) return PurchaseResult.error;
    if (ownedItemIds.contains(item.id)) return PurchaseResult.alreadyOwned;

    final result = await _studentRepository.requestPurchase(
      studentId: myStudentId,
      itemId: item.id,
      cost: item.cost,
    );
    if (result == PurchaseResult.pendingApproval) await refresh();
    return result;
  }

  /// Spending history, newest first. Reads the local guest ledger for
  /// guests, the Firestore `transactions` subcollection otherwise.
  Future<List<PurchaseTransaction>> getTransactions() async {
    if (isGuest) return _guestTransactions;
    return _studentRepository.getTransactions(myStudentId);
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

  /// Clears the equipped avatar color and/or icon, reverting to the default
  /// avatar. Works for both guests (local prefs) and registered students
  /// (Firestore).
  Future<void> unequipItem({bool color = false, bool icon = false}) async {
    if (!color && !icon) return;

    if (isGuest) {
      final prefs = await SharedPreferences.getInstance();
      if (color) {
        _guestEquippedAvatarColorHex = null;
        await prefs.remove(_guestAvatarColorKey);
      }
      if (icon) {
        _guestEquippedAvatarIcon = null;
        await prefs.remove(_guestAvatarIconKey);
      }
      notifyListeners();
      return;
    }

    await _studentRepository.unequipAvatar(
      myStudentId,
      clearColor: color,
      clearIcon: icon,
    );
    await refresh();
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
