// First real widget test in the suite (previous widget_test.dart is a
// trivial smoke test with no pumpWidget). PlaceholderSection is presentational
// only — no Firebase or provider dependency — so it's a safe starting point
// for widget-testing conventions in this repo.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/shared/widgets/placeholder_section.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the title and message it is given', (tester) async {
    await tester.pumpWidget(
      wrap(
        const PlaceholderSection(
          icon: Icons.people_alt_rounded,
          title: 'Amigos',
          message: 'Estamos construyendo esta sección.',
        ),
      ),
    );

    expect(find.text('Amigos'), findsOneWidget);
    expect(
        find.text('Estamos construyendo esta sección.'), findsOneWidget);
  });

  testWidgets('always shows the "Muy pronto" badge', (tester) async {
    await tester.pumpWidget(
      wrap(
        const PlaceholderSection(
          icon: Icons.storefront_rounded,
          title: 'Tienda',
          message: 'Próximamente podrás canjear tus puntos.',
        ),
      ),
    );

    expect(find.text('Muy pronto'), findsOneWidget);
  });

  testWidgets('renders the provided icon', (tester) async {
    await tester.pumpWidget(
      wrap(
        const PlaceholderSection(
          icon: Icons.storefront_rounded,
          title: 'Tienda',
          message: 'Próximamente.',
        ),
      ),
    );

    expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
  });
}
