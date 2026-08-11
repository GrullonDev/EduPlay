import 'package:edu_play/features/friends/models/friend_identity.dart';
import 'package:edu_play/features/friends/models/friend_request.dart';
import 'package:edu_play/features/friends/services/friends_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  const parent = FriendIdentity(
    uid: 'parent-1',
    role: 'parent',
    name: 'Ana',
  );
  const student = FriendIdentity(
    uid: 'parent-2',
    childId: 'child-2',
    role: 'student',
    name: 'Sofia',
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    FriendsService.useFirestoreForTest(firestore);
  });

  tearDown(() {
    FriendsService.useFirestoreForTest(null);
  });

  group('FriendIdentity', () {
    test('uses role and child profile in its stable key', () {
      expect(parent.key, 'parent:parent-1');
      expect(student.key, 'student:parent-2_child-2');
    });
  });

  group('FriendRequestModel', () {
    test('serializes participants and participant uids for Firestore queries',
        () {
      final request = FriendRequestModel(
        id: 'request-1',
        fromUid: parent.uid,
        fromRole: parent.role,
        fromName: parent.name,
        toUid: student.uid,
        toChildId: student.childId,
        toRole: student.role,
        toName: student.name,
        status: 'pending',
        createdAt: DateTime(2026, 1, 1),
        viaCode: 'ABC123',
      );

      final map = request.toMap();

      expect(map['participants'], [parent.key, student.key]);
      expect(map['participantUids'], [parent.uid, student.uid]);
      expect(map['viaCode'], 'ABC123');
    });

    test('returns the other participant relative to my key', () {
      final request = FriendRequestModel(
        id: 'request-1',
        fromUid: parent.uid,
        fromRole: parent.role,
        fromName: parent.name,
        toUid: student.uid,
        toChildId: student.childId,
        toRole: student.role,
        toName: student.name,
        status: 'accepted',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(request.other(parent.key).name, student.name);
      expect(request.other(student.key).name, parent.name);
    });
  });

  group('FriendsService', () {
    test('creates one reusable friend code per identity', () async {
      final first = await FriendsService.getOrCreateMyCode(student);
      final second = await FriendsService.getOrCreateMyCode(student);
      final codes = await firestore.collection('friend_codes').get();

      expect(first, second);
      expect(codes.docs, hasLength(1));
      expect(codes.docs.single.data()['ownerUid'], student.uid);
      expect(codes.docs.single.data()['childId'], student.childId);
      expect(codes.docs.single.data()['role'], student.role);
    });

    test('sends a pending request to the owner of a friend code', () async {
      final code = await FriendsService.getOrCreateMyCode(student);

      await FriendsService.sendRequestByCode(me: parent, code: code);

      final requests = await firestore.collection('friend_requests').get();
      expect(requests.docs, hasLength(1));

      final request = FriendRequestModel.fromMap(
        requests.docs.single.data(),
        requests.docs.single.id,
      );
      expect(request.fromKey, parent.key);
      expect(request.toKey, student.key);
      expect(request.status, 'pending');
      expect(request.viaCode, code);
    });

    test('rejects unknown codes and self requests', () async {
      await expectLater(
        FriendsService.sendRequestByCode(me: parent, code: 'NOPE99'),
        throwsA(isA<Exception>()),
      );

      final myCode = await FriendsService.getOrCreateMyCode(parent);
      await expectLater(
        FriendsService.sendRequestByCode(me: parent, code: myCode),
        throwsA(isA<Exception>()),
      );
    });

    test('prevents duplicate pending or accepted connections', () async {
      final code = await FriendsService.getOrCreateMyCode(student);

      await FriendsService.sendRequestByCode(me: parent, code: code);

      await expectLater(
        FriendsService.sendRequestByCode(me: parent, code: code),
        throwsA(isA<Exception>()),
      );
    });

    test('streams incoming requests and accepted friends for an identity',
        () async {
      final code = await FriendsService.getOrCreateMyCode(student);
      await FriendsService.sendRequestByCode(me: parent, code: code);

      final incoming =
          await FriendsService.watchIncomingRequests(student).first;
      expect(incoming, hasLength(1));
      expect(incoming.single.fromKey, parent.key);

      await FriendsService.respondToRequest(incoming.single.id, accept: true);

      final friends = await FriendsService.watchFriends(parent).first;
      expect(friends, hasLength(1));
      expect(friends.single.status, 'accepted');
    });

    test('removes an accepted connection', () async {
      final code = await FriendsService.getOrCreateMyCode(student);
      await FriendsService.sendRequestByCode(me: parent, code: code);
      final incoming =
          await FriendsService.watchIncomingRequests(student).first;
      await FriendsService.respondToRequest(incoming.single.id, accept: true);

      await FriendsService.removeRequest(incoming.single.id);

      final friends = await FriendsService.watchFriends(parent).first;
      expect(friends, isEmpty);
    });
  });
}
