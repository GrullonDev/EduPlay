// Package imports:
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/core/auth/auth_gate.dart';

// Regression coverage for the role-resolution logic behind the "parent
// dashboard silently logs out on navigation" fix: AuthGate._resolveRole must
// distinguish "authenticated user with no role" from "we couldn't check" —
// only the former is a genuine dead end, and only a genuine dead end may
// ever trigger AuthGate.build()'s sign-out path. These tests exercise the
// resolver directly (via the @visibleForTesting wrapper) rather than pumping
// the full dashboard widget trees, since those pull in live Firestore-backed
// services outside this unit's concern.
void main() {
  setUp(AuthGate.resetCacheForTest);

  AuthGate gateFor(FakeFirebaseFirestore firestore) =>
      AuthGate(auth: MockFirebaseAuth(), firestore: firestore);

  test('resolves to parent when a parents/{uid} doc exists', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('parents').doc('uid1').set({'name': 'Ana'});

    final role = await gateFor(firestore).resolveRoleForTest('uid1');

    expect(role, 'parent');
  });

  test('resolves to teacher when a teachers/{uid} doc exists', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('teachers').doc('uid2').set({'name': 'Luis'});

    final role = await gateFor(firestore).resolveRoleForTest('uid2');

    expect(role, 'teacher');
  });

  test('resolves to null when neither doc exists', () async {
    final firestore = FakeFirebaseFirestore();

    final role = await gateFor(firestore).resolveRoleForTest('uid3');

    expect(role, isNull);
  });

  test('a successful lookup is cached and skips Firestore on the next call',
      () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('parents').doc('uid4').set({'name': 'Ana'});
    final gate = gateFor(firestore);

    expect(await gate.resolveRoleForTest('uid4'), 'parent');

    // Delete the backing doc — if the second call were hitting Firestore
    // again instead of the cache, it would now resolve to null.
    await firestore.collection('parents').doc('uid4').delete();

    expect(await gate.resolveRoleForTest('uid4'), 'parent');
  });
}
