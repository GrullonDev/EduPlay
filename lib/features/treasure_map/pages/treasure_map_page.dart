// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';
import 'package:edu_play/utils/injection_container.dart';

class TreasureMapPage extends StatefulWidget {
  const TreasureMapPage({super.key});

  @override
  State<TreasureMapPage> createState() => _TreasureMapPageState();
}

class _TreasureMapPageState extends State<TreasureMapPage> {
  int _rows = 6;
  int _cols = 6;
  int _playerPos = 0;
  int _treasurePos = 35;
  final List<int> _obstacles = [];
  int _level = 1;
  final Random _random = Random();
  final GlobalKey _playerKey = GlobalKey();

  /// Lives left before an obstacle collision triggers a full explanation
  /// (instead of just the quick snack-bar bump), so the player isn't
  /// interrupted with a modal on every single bump.
  int _livesThisLevel = 3;

  /// Per-skill correct/total tally for this session, sent alongside the
  /// score every time a level is completed.
  final SkillTracker skillTracker = SkillTracker();

  @override
  void initState() {
    super.initState();
    // Show the objective dialog after the first frame (it needs an Overlay
    // to be mounted), then generate the first board once it's dismissed.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroAndStart());
  }

  Future<void> _showIntroAndStart() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Mapa del Tesoro',
      objective:
          'Vas a practicar razonamiento lógico-espacial: observa el tablero completo, planifica tu ruta con anticipación y esquiva los obstáculos para llegar al tesoro.',
      difficultyLabel: _difficultyLabel(),
    );
    if (!mounted) return;
    _startLevel();
  }

  String _difficultyLabel() {
    if (_level <= 2) return 'Principiante';
    if (_level <= 4) return 'Intermedio';
    return 'Avanzado';
  }

  /// Grows the maze itself every few levels (not just the obstacle count),
  /// so higher levels genuinely require more spatial planning instead of
  /// just dodging more clutter on the same small board.
  int _gridSizeForLevel() => min(6 + ((_level - 1) ~/ 3), 9);

  void _startLevel() {
    setState(() {
      _rows = _gridSizeForLevel();
      _cols = _rows;
      _playerPos = 0;
      _treasurePos = (_rows * _cols) - 1;
      _livesThisLevel = 3;
      _generateObstacles();
    });
    _scrollToPlayer();
  }

  /// Keeps the boat visible by scrolling the board to follow it, since the
  /// grid is taller than the viewport and can't show all rows at once.
  void _scrollToPlayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _playerKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _generateObstacles() {
    _obstacles.clear();
    // Number of obstacles increases with level, capped at 12
    int numObstacles = min(4 + (_level * 2), 12);

    while (_obstacles.length < numObstacles) {
      int pos = _random.nextInt(_rows * _cols);
      // Don't place obstacle on player, treasure, or duplicate
      if (pos != _playerPos &&
          pos != _treasurePos &&
          !_obstacles.contains(pos)) {
        // Ensure path is solvable (simplified check: just don't block start/end neighbors too much)
        // A real pathfinding check would be better but overkill for this simple logic
        _obstacles.add(pos);
      }
    }
  }

  Future<void> _move(String direction) async {
    int newPos = _playerPos;
    if (direction == 'UP') {
      if (_playerPos >= _cols) newPos -= _cols;
    } else if (direction == 'DOWN') {
      if (_playerPos < (_rows * _cols) - _cols) newPos += _cols;
    } else if (direction == 'LEFT') {
      if (_playerPos % _cols != 0) newPos -= 1;
    } else if (direction == 'RIGHT') {
      if ((_playerPos + 1) % _cols != 0) newPos += 1;
    }

    if (_obstacles.contains(newPos)) {
      skillTracker.record('logica_espacial', correct: false);
      setState(() {
        _livesThisLevel--;
      });

      // Quick, non-blocking bump feedback so the maze keeps its pace on
      // every single collision.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('¡Cuidado! Un monstruo marino bloquea el camino.'),
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.redAccent,
      ));

      // Only after "losing a life" (3 collisions) do we interrupt with the
      // full explanation, so occasional bumps don't break the flow.
      if (_livesThisLevel <= 0) {
        await showAnswerExplanation(
          context,
          isCorrect: false,
          correctAnswerText:
              'Observa el tablero completo antes de moverte y rodea el obstáculo por el lado que sí tenga camino libre.',
          explanation:
              'Chocar varias veces con el mismo obstáculo suele significar que avanzas sin mirar. Antes de mover, ubica el tesoro, identifica los obstáculos entre tú y él, y planea 2 o 3 pasos por adelantado.',
          skillLabel: skillByKey('logica_espacial').label,
        );
        if (!mounted) return;
        setState(() {
          _livesThisLevel = 3;
        });
      }
    } else {
      setState(() {
        _playerPos = newPos;
      });
      _scrollToPlayer();
      _checkWin();
    }
  }

  void _checkWin() {
    if (_playerPos == _treasurePos) {
      skillTracker.record('logica_espacial', correct: true);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('¡Tesoro Encontrado!'),
          content: Text(
              '¡Has completado el Nivel $_level!\n¿Listo para el siguiente?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                sl<StudentRepository>().recordScore(
                  subjectKey: 'logic',
                  gameTitle: 'Mapa del Tesoro',
                  score: _level * 10,
                  skills: skillTracker.tallies,
                  gameRoute: '/treasure-map',
                );
                setState(() {
                  _level++;
                });
                _startLevel();
              },
              child: const Text('Siguiente Nivel'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa del Tesoro - Nivel $_level'),
        backgroundColor: const Color(0xFF795548), // Brown
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFFFF8E1), // Parchment color
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rows * _cols,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _cols,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    Widget? child;

                    if (index == _playerPos) {
                      child = const Icon(Icons.sailing,
                          color: Colors.blue, size: 32);
                    } else if (index == _treasurePos) {
                      child = const Icon(Icons.api_rounded,
                          color: Colors.amber, size: 32); // Chest/Island
                    } else if (_obstacles.contains(index)) {
                      // Randomize monster slightly for fun? specific icon
                      child = const Icon(Icons.waves,
                          color: Colors.blueGrey,
                          size: 32); // Water monster/Rocks
                    }

                    // Water texture
                    return Container(
                      key: index == _playerPos ? _playerKey : null,
                      decoration: BoxDecoration(
                        color: _obstacles.contains(index)
                            ? Colors.red[50]
                            : const Color(0xFFB3E5FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                          child: child ??
                              (_obstacles.contains(index)
                                  ? const Icon(Icons.close,
                                      color: Colors.red) // Fallback
                                  : null)),
                    );
                  },
                ),
              ),
            ),

            // Movement Controls
            Container(
              decoration: const BoxDecoration(
                  color: Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowButton(Icons.arrow_upward, 'UP'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowButton(Icons.arrow_back, 'LEFT'),
                      const SizedBox(width: 40),
                      _buildArrowButton(Icons.arrow_forward, 'RIGHT'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildArrowButton(Icons.arrow_downward, 'DOWN'),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, String direction) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
          color: Color(0xFF5D4037),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black38, blurRadius: 5, offset: Offset(0, 3))
          ]),
      child: IconButton(
        icon: Icon(icon, size: 36, color: Colors.white),
        onPressed: () => _move(direction),
      ),
    );
  }
}
