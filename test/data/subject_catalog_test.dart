// The subject catalog drives game routing, challenge creation and dashboard
// theming across student and teacher features. It had zero tests, so a
// mismatch between subjectCatalog and subjectGameRoutes (e.g. from a typo
// in a subject key) would only surface as a silent runtime fallback.

import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('subjectCatalog', () {
    test('is not empty', () {
      expect(subjectCatalog, isNotEmpty);
    });

    test('every subject has a unique, non-empty key', () {
      final keys = subjectCatalog.map((s) => s.key).toList();
      expect(keys.toSet().length, keys.length,
          reason: 'Duplicate subject key detected');
      for (final key in keys) {
        expect(key, isNotEmpty);
      }
    });

    test('every subject has a non-empty label', () {
      for (final subject in subjectCatalog) {
        expect(subject.label, isNotEmpty,
            reason: 'Subject "${subject.key}" has an empty label');
      }
    });
  });

  group('subjectByKey', () {
    test('returns the matching subject for a known key', () {
      final subject = subjectByKey('math');
      expect(subject.key, 'math');
      expect(subject.label, 'Matemáticas');
    });

    test('falls back to the first subject for an unknown key', () {
      final subject = subjectByKey('does-not-exist');
      expect(subject.key, subjectCatalog.first.key);
    });

    test('resolves every catalog key back to itself', () {
      for (final subject in subjectCatalog) {
        expect(subjectByKey(subject.key).key, subject.key);
      }
    });
  });

  group('subjectGameRoutes', () {
    test('has a route for every subject in the catalog', () {
      for (final subject in subjectCatalog) {
        expect(subjectGameRoutes.containsKey(subject.key), isTrue,
            reason: 'No game route registered for subject "${subject.key}"');
      }
    });

    test('every route is a non-empty path', () {
      for (final route in subjectGameRoutes.values) {
        expect(route, isNotEmpty);
      }
    });

    test('does not reference a subject key outside the catalog', () {
      final catalogKeys = subjectCatalog.map((s) => s.key).toSet();
      for (final key in subjectGameRoutes.keys) {
        expect(catalogKeys.contains(key), isTrue,
            reason: 'subjectGameRoutes has an orphaned key "$key"');
      }
    });
  });
}
