import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChildProfile.generatePin', () {
    test('produces a 4-character string', () {
      final pin = ChildProfile.generatePin();
      expect(pin.length, 4);
    });

    test('contains only digits', () {
      for (var i = 0; i < 50; i++) {
        final pin = ChildProfile.generatePin();
        expect(RegExp(r'^\d{4}$').hasMatch(pin), isTrue,
            reason: 'PIN "$pin" is not 4 digits');
      }
    });

    test('generates varied values across many calls', () {
      final pins = {for (var i = 0; i < 100; i++) ChildProfile.generatePin()};
      // 10,000 possible 4-digit PINs — expect reasonable entropy in 100 draws.
      expect(pins.length, greaterThan(50));
    });
  });

  group('ChildProfile.avatarColorForIndex', () {
    test('returns a 6-char hex string (no # prefix)', () {
      for (var i = 0; i < 10; i++) {
        final hex = ChildProfile.avatarColorForIndex(i);
        expect(hex.length, 6,
            reason: 'avatarColorForIndex($i) returned "$hex" (expected 6 chars)');
        expect(RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex), isTrue,
            reason: 'avatarColorForIndex($i) returned "$hex"');
      }
    });

    test('cycles through the palette — index 0 and index (palette.length) match', () {
      // The palette has 6 entries; index 6 should equal index 0.
      final first = ChildProfile.avatarColorForIndex(0);
      final wrapped = ChildProfile.avatarColorForIndex(6);
      expect(wrapped, first);
    });

    test('does not throw for very large indices', () {
      expect(() => ChildProfile.avatarColorForIndex(999999), returnsNormally);
    });
  });

  group('ChildProfile JSON round-trip', () {
    final profile = ChildProfile(
      id: 'test-id-123',
      name: 'Sofía',
      age: 8,
      level: 3,
      pin: '4213',
      focusSubject: 'math',
      levelProgress: 0.65,
      avatarColorHex: 'E67E22',
    );

    test('toJson → fromJson preserves all fields', () {
      final json = profile.toJson();
      final restored = ChildProfile.fromJson(json);

      expect(restored.id, profile.id);
      expect(restored.name, profile.name);
      expect(restored.age, profile.age);
      expect(restored.level, profile.level);
      expect(restored.pin, profile.pin);
      expect(restored.focusSubject, profile.focusSubject);
      expect(restored.levelProgress, closeTo(profile.levelProgress, 1e-9));
      expect(restored.avatarColorHex, profile.avatarColorHex);
    });

    test('toJson includes all required keys', () {
      final json = profile.toJson();
      for (final key in [
        'id', 'name', 'age', 'level', 'pin', 'focusSubject',
        'levelProgress', 'avatarColorHex',
      ]) {
        expect(json.containsKey(key), isTrue, reason: 'Missing key: $key');
      }
    });
  });

  group('ChildProfile.levelLabel', () {
    test('pads single-digit levels to two digits', () {
      final p = ChildProfile(
        id: 'x', name: 'Test', age: 6, level: 1, pin: '0000',
        focusSubject: 'math', levelProgress: 0, avatarColorHex: 'E67E22',
      );
      expect(p.levelLabel, 'Nivel 01');
    });

    test('does not pad double-digit levels', () {
      final p = ChildProfile(
        id: 'x', name: 'Test', age: 10, level: 12, pin: '0000',
        focusSubject: 'science', levelProgress: 0.5, avatarColorHex: '9B59B6',
      );
      expect(p.levelLabel, 'Nivel 12');
    });
  });

  group('ChildProfile.copyWith', () {
    final original = ChildProfile(
      id: 'abc', name: 'Miguel', age: 9, level: 2, pin: '1234',
      focusSubject: 'english', levelProgress: 0.3, avatarColorHex: '2ECC71',
    );

    test('overrides only specified fields', () {
      final updated = original.copyWith(name: 'Miguel Ángel', level: 3);
      expect(updated.name, 'Miguel Ángel');
      expect(updated.level, 3);
      expect(updated.id, original.id);          // unchanged
      expect(updated.age, original.age);         // unchanged
      expect(updated.pin, original.pin);         // unchanged
    });
  });
}
