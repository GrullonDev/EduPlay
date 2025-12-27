import 'package:flutter/material.dart';

class TreasureMapPage extends StatefulWidget {
  const TreasureMapPage({super.key});

  @override
  State<TreasureMapPage> createState() => _TreasureMapPageState();
}

class _TreasureMapPageState extends State<TreasureMapPage> {
  final int _rows = 5;
  final int _cols = 5;
  int _playerPos = 0;
  int _treasurePos = 24;
  List<int> _obstacles = [6, 8, 12, 16, 18]; // Obstacle indices

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _playerPos = 0;
      // Fixed simple level for now
      _treasurePos = 24;
      _obstacles = [6, 8, 12, 16, 18];
    });
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

    if (!_obstacles.contains(newPos)) {
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
          title: const Text('¡Ganaste!'),
          content: const Text('¡Encontraste el tesoro!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('Jugar de nuevo'),
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
        title: const Text('Mapa del Tesoro'),
        backgroundColor: const Color(0xFFFFEB3B),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rows * _cols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _cols,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                Color color = Colors.grey[200]!;
                Widget? child;

                if (index == _playerPos) {
                  color = Colors.blue;
                  child = const Icon(Icons.person, color: Colors.white);
                } else if (index == _treasurePos) {
                  color = Colors.amber;
                  child = const Icon(Icons.star, color: Colors.white);
                } else if (_obstacles.contains(index)) {
                  color = Colors.brown;
                  child = const Icon(Icons.close, color: Colors.white);
                }

                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: child),
                );
              },
            ),
          ),
          Padding(
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
    );
  }

  Widget _buildArrowButton(IconData icon, String direction) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: () => _move(direction),
        child: Icon(icon, size: 30),
      ),
    );
  }
}
