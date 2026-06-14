import 'dart:math';

/// A parent-created practice session that locks a child into a curated
/// set of exercises. Stored locally via SharedPreferences (no backend).
class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.childProfileId,
    required this.childName,
    required this.pin,
    required this.assignedGameIds,
    required this.createdAt,
    this.isActive = true,
    this.completedGameIds = const [],
    this.scoreMap = const {},
  });

  final String id;
  final String childProfileId;
  final String childName;

  /// 6-digit session PIN (separate from the child profile PIN).
  final String pin;

  /// IDs of games from the catalog that the parent assigned.
  final List<String> assignedGameIds;

  final DateTime createdAt;

  /// Whether the session is still open (parent hasn't closed it).
  final bool isActive;

  /// Game IDs the child has completed at least once.
  final List<String> completedGameIds;

  /// gameId → last score achieved
  final Map<String, int> scoreMap;

  // ── Derived ─────────────────────────────────────────────────────────────────

  bool get isCompleted =>
      assignedGameIds.isNotEmpty &&
      assignedGameIds
          .every((id) => completedGameIds.contains(id));

  int get completedCount => completedGameIds.length;
  int get totalCount => assignedGameIds.length;

  double get progressFraction =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  /// Deep URL the child opens to join this session.
  String sessionUrl(String baseUrl) =>
      '$baseUrl/practice-session?pin=$pin';

  // ── Serialisation ────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'childProfileId': childProfileId,
        'childName': childName,
        'pin': pin,
        'assignedGameIds': assignedGameIds,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'completedGameIds': completedGameIds,
        'scoreMap': scoreMap.map((k, v) => MapEntry(k, v)),
      };

  factory PracticeSession.fromJson(Map<String, dynamic> j) => PracticeSession(
        id: j['id'] as String,
        childProfileId: j['childProfileId'] as String,
        childName: j['childName'] as String? ?? '',
        pin: j['pin'] as String,
        assignedGameIds:
            (j['assignedGameIds'] as List<dynamic>).cast<String>(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        isActive: j['isActive'] as bool? ?? true,
        completedGameIds:
            (j['completedGameIds'] as List<dynamic>? ?? []).cast<String>(),
        scoreMap: (j['scoreMap'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
      );

  PracticeSession copyWith({
    bool? isActive,
    List<String>? completedGameIds,
    Map<String, int>? scoreMap,
  }) =>
      PracticeSession(
        id: id,
        childProfileId: childProfileId,
        childName: childName,
        pin: pin,
        assignedGameIds: assignedGameIds,
        createdAt: createdAt,
        isActive: isActive ?? this.isActive,
        completedGameIds: completedGameIds ?? this.completedGameIds,
        scoreMap: scoreMap ?? this.scoreMap,
      );

  // ── Generators ───────────────────────────────────────────────────────────────

  /// Unique 6-digit session PIN (different from the child profile PIN).
  static String generatePin() {
    final rng = Random();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
