import 'package:flutter/material.dart';

import 'package:edu_play/features/games/core/game_metadata.dart';
import 'package:edu_play/features/games/core/game_module.dart';
import 'package:edu_play/features/games/number_ninja/number_ninja_module.dart';

/// Single source of truth for every minigame built on the games engine.
///
/// To add a new game: implement [IGameModule] in its own folder under
/// `lib/features/games/<id>/`, then add one line to [entries] below.
/// No changes needed to the router or the catalog — both read from here.
class GameRegistry {
  GameRegistry._();

  static const List<IGameModule> entries = [
    NumberNinjaModule(),
  ];

  static IGameModule? _findByRoute(String route) {
    for (final module in entries) {
      if (module.metadata.route == route) return module;
    }
    return null;
  }

  /// Resolves an engine-registered route. Called from [AppRouter] before
  /// falling back to the legacy hand-written `switch`.
  static Route<dynamic>? resolve(RouteSettings settings) {
    final module = _findByRoute(settings.name ?? '');
    if (module == null) return null;
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => module.buildPage(),
    );
  }

  /// Metadata for every engine-registered game — feeds the games catalog.
  static List<GameMetadata> get catalog =>
      entries.map((module) => module.metadata).toList();
}
