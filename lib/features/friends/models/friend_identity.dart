/// Identifies "who is asking" for the Friends feature.
///
/// A parent/teacher identity is just their Firebase Auth [uid]. A student
/// identity is scoped to one child profile ([childId]) under the parent's
/// [uid], since children don't have their own Firebase Auth account — they
/// share the signed-in parent's session (see `child_profiles` in Firestore).
class FriendIdentity {
  const FriendIdentity({
    required this.uid,
    this.childId,
    required this.role,
    required this.name,
  });

  final String uid;
  final String? childId;
  final String role; // 'student' | 'parent' | 'teacher'
  final String name;

  /// Stable key used to match "me" against a request's from/to side.
  String get key => childId == null ? uid : '${uid}_$childId';
}
