// Flutter imports:
import 'package:flutter/material.dart';

/// Common page shell for a minigame: a [GameHeader] as the app bar over a
/// gradient background, with the game-specific board as [body].
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.header,
    required this.body,
    this.backgroundGradient,
  });

  final PreferredSizeWidget header;
  final Widget body;
  final Gradient? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(child: body),
      ),
    );
  }
}
