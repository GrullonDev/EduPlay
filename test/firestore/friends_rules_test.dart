import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String rules;

  setUpAll(() {
    rules = File('firestore.rules')
        .readAsStringSync()
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\s+'), ' ');
  });

  test('friend code documents require authentication and owner writes', () {
    expect(rules, contains('match /friend_codes/{code}'));
    expect(rules, contains('allow read: if request.auth != null;'));
    expect(
      rules,
      contains('request.resource.data.ownerUid == request.auth.uid'),
    );
    expect(rules, contains('resource.data.ownerUid == request.auth.uid'));
  });

  test('friend request creation must target the owner of the viaCode', () {
    expect(rules, contains('match /friend_requests/{requestId}'));
    expect(rules, contains("request.resource.data.status == 'pending'"));
    expect(rules, contains('request.resource.data.viaCode is string'));
    expect(
      rules,
      contains(
        'friendCode(request.resource.data.viaCode).ownerUid '
        '== request.resource.data.toUid',
      ),
    );
    expect(
      rules,
      contains(
        'friendCode(request.resource.data.viaCode).childId '
        '== request.resource.data.toChildId',
      ),
    );
  });

  test('only recipients can accept friend requests', () {
    expect(
      rules,
      contains(
        'request.auth.uid == resource.data.toUid '
        "&& request.resource.data.status in ['accepted', 'rejected']",
      ),
    );
    expect(
      rules,
      contains(
        'request.auth.uid == resource.data.fromUid '
        "&& request.resource.data.status == 'rejected'",
      ),
    );
  });

  test('notifications are scoped to recipients and sender-created requests',
      () {
    expect(rules, contains('match /notifications/{notificationId}'));
    expect(rules, contains('request.auth.uid == resource.data.recipientUid'));
    expect(
      rules,
      contains('request.auth.uid == request.resource.data.senderUid'),
    );
    expect(rules, contains("request.resource.data.type == 'friend_request'"));
    expect(rules, contains("affectedKeys() .hasOnly(['read'])"));
    expect(rules, contains('request.resource.data.read == true'));
  });
}
