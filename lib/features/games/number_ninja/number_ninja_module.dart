// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:edu_play/features/games/core/game_metadata.dart';
import 'package:edu_play/features/games/core/game_module.dart';
import 'package:edu_play/features/games/number_ninja/pages/number_ninja_page.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart'
    show AgeRange, Difficulty;

/// Single source of truth for Number Ninja's identity — reused by the
/// controller (to know what to submit scores as) and by [GameRegistry]
/// (to route to it and list it in the catalog), without instantiating any
/// gameplay state.
const GameMetadata numberNinjaMetadata = GameMetadata(
  id: 'number_ninja',
  title: 'Ninja de los Números',
  route: RouterPaths.numberNinja,
  subjectKey: 'math',
  ageRange: AgeRange.age6to8,
  difficulty: Difficulty.beginner,
  icon: Icons.bolt_rounded,
  gradientColors: [Color(0xFF0F3443), Color(0xFF34E89E)],
);

/// Registration descriptor for Number Ninja. Stateless and `const` on
/// purpose — see [IGameModule] for why.
class NumberNinjaModule implements IGameModule {
  const NumberNinjaModule();

  @override
  GameMetadata get metadata => numberNinjaMetadata;

  @override
  Widget buildPage() => const NumberNinjaPage();
}
