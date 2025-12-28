import 'dart:math';
import 'package:flutter/material.dart';

class TreasureMapPage extends StatefulWidget {
  const TreasureMapPage({super.key});

  @override
  State<TreasureMapPage> createState() => _TreasureMapPageState();
}

class _TreasureMapPageState extends State<TreasureMapPage> {
  final int _rows = 6;
  final int _cols = 6;
  int _playerPos = 0;
  int _treasurePos = 35;
  final List<int> _obstacles = [];
  int _level = 1;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    setState(() {
      _playerPos = 0;
      _treasurePos = (_rows * _cols) - 1;
      _generateObstacles();
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

  void _move(String direction) {
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
      // Shake or feedback effect could go here
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('¡Cuidado! Un monstruo marino bloquea el camino.'),
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.redAccent,
      ));
    } else {
      setState(() {
        _playerPos = newPos;
      });
      _checkWin();
    }
  }

  void _checkWin() {
    if (_playerPos == _treasurePos) {
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
