import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    required this.fromUid,
    this.fromChildId,
    required this.fromRole,
    required this.fromName,
    required this.toUid,
    this.toChildId,
    required this.toRole,
    required this.toName,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromMap(Map<String, dynamic> m, String id) =>
      FriendRequestModel(
        id: id,
        fromUid: m['fromUid'] as String,
        fromChildId: m['fromChildId'] as String?,
        fromRole: m['fromRole'] as String? ?? 'parent',
        fromName: m['fromName'] as String? ?? 'Usuario',
        toUid: m['toUid'] as String,
        toChildId: m['toChildId'] as String?,
        toRole: m['toRole'] as String? ?? 'parent',
        toName: m['toName'] as String? ?? 'Usuario',
        status: m['status'] as String? ?? 'pending',
        createdAt: m['createdAt'] is Timestamp
            ? (m['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  final String id;
  final String fromUid;
  final String? fromChildId;
  final String fromRole;
  final String fromName;
  final String toUid;
  final String? toChildId;
  final String toRole;
  final String toName;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final DateTime createdAt;

  String get fromKey => fromChildId == null ? fromUid : '${fromUid}_$fromChildId';
  String get toKey => toChildId == null ? toUid : '${toUid}_$toChildId';

  /// The other participant's display info, relative to [myKey].
  ({String uid, String? childId, String role, String name}) other(String myKey) {
    if (fromKey == myKey) {
      return (uid: toUid, childId: toChildId, role: toRole, name: toName);
    }
    return (uid: fromUid, childId: fromChildId, role: fromRole, name: fromName);
  }

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'fromChildId': fromChildId,
        'fromRole': fromRole,
        'fromName': fromName,
        'toUid': toUid,
        'toChildId': toChildId,
        'toRole': toRole,
        'toName': toName,
        'participants': [fromKey, toKey],
        'participantUids': [fromUid, toUid],
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
