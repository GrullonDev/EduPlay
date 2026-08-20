// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:edu_play/features/games/core/game_metadata.dart';

/// Stateless registration contract every minigame must implement.
///
/// Deliberately holds no gameplay state (no score, no lives, no timers) —
/// implementations must have a `const` constructor so `GameRegistry` can
/// list every game at app start without instantiating a single
/// `GameSessionController` (and its timers) just to read a title or route.
/// The actual per-session state lives in a [GameSessionController]
/// subclass created fresh by the page each time it's opened.
abstract class IGameModule {
  GameMetadata get metadata;

  /// Builds the fully-assembled page (provider + scaffold + header + board)
  /// for this game. Called by [GameRegistry] to resolve a named route.
  Widget buildPage();
}
