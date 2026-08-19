// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientUid,
    this.recipientChildId,
    required this.recipientRole,
    required this.senderUid,
    this.senderChildId,
    required this.senderRole,
    required this.senderName,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.friendRequestId,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      recipientUid: map['recipientUid'] as String? ?? '',
      recipientChildId: map['recipientChildId'] as String?,
      recipientRole: map['recipientRole'] as String? ?? 'parent',
      senderUid: map['senderUid'] as String? ?? '',
      senderChildId: map['senderChildId'] as String?,
      senderRole: map['senderRole'] as String? ?? 'parent',
      senderName: map['senderName'] as String? ?? 'Usuario',
      type: map['type'] as String? ?? 'general',
      title: map['title'] as String? ?? 'Notificacion',
      body: map['body'] as String? ?? '',
      read: map['read'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      friendRequestId: map['friendRequestId'] as String?,
    );
  }

  final String id;
  final String recipientUid;
  final String? recipientChildId;
  final String recipientRole;
  final String senderUid;
  final String? senderChildId;
  final String senderRole;
  final String senderName;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final String? friendRequestId;
}
