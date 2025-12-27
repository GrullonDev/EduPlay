import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ColorConcertPage extends StatefulWidget {
  const ColorConcertPage({super.key});

  @override
  State<ColorConcertPage> createState() => _ColorConcertPageState();
}

class _ColorConcertPageState extends State<ColorConcertPage> {
  final List<Color> _colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.yellowAccent
  ];
  List<int> _sequence = [];
  List<int> _userSequence = [];
  int _score = 0;
  bool _isPlayingSequence = false;
  bool _isGameActive = false;
  int? _activeLightIndex; // Currently lit up button
  String _message = '¡Bienvenido al Concierto!';

  void _startGame() {
    setState(() {
      _sequence = [];
      _userSequence = [];
      _score = 0;
      _message = '¡Atento!';
      _isGameActive = true;
    });
    Future.delayed(const Duration(seconds: 1), _nextRound);
  }

  void _nextRound() {
    setState(() {
      _userSequence = [];
      _sequence.add(Random().nextInt(4)); // Add random color index
      _message = 'Nivel ${_sequence.length}';
      _isPlayingSequence = true;
    });
    _playSequence();
  }

  Future<void> _playSequence() async {
    // Speed increases every 3 levels
    int speedMs = max(200, 600 - (_sequence.length * 20));

    await Future.delayed(const Duration(seconds: 1)); // Prep pause

    for (int index in _sequence) {
      if (!mounted) return;

      setState(() {
        _activeLightIndex = index;
      });

      // Play sound here ideally

      await Future.delayed(Duration(milliseconds: speedMs));

      setState(() {
        _activeLightIndex = null;
      });

      await Future.delayed(
          Duration(milliseconds: speedMs ~/ 2)); // Tiny pause between notes
    }

    if (mounted) {
      setState(() {
        _isPlayingSequence = false;
        _message = '¡Tu turno!';
      });
    }
  }

  void _onColorTap(int index) {
    if (_isPlayingSequence || !_isGameActive) return;

    // Flash immediately
    setState(() {
      _activeLightIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _activeLightIndex = null;
        });
      }
    });

    _userSequence.add(index);

    // Check correctness immediately
    if (_userSequence[_userSequence.length - 1] !=
        _sequence[_userSequence.length - 1]) {
      _gameOver();
      return;
    }

    if (_userSequence.length == _sequence.length) {
      // Round complete
      setState(() {
        _score++;
        _message = '¡Correcto!';
      });
      Future.delayed(const Duration(seconds: 1), _nextRound);
    }
  }

  void _gameOver() {
    setState(() {
      _isGameActive = false;
      _message = '¡Fallaste!';
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('¡Concierto Terminado!',
            style: TextStyle(color: Colors.white)),
        content: Text('Llegaste al Nivel ${_sequence.length}',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Reintentar',
                style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child:
                const Text('Salir', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238), // Dark theme
      appBar: AppBar(
        title: const Text('Concierto de Colores'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              _message,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // The Pads
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  children: [
                    Positioned(
                        top: 0,
                        left: 0,
                        child: _buildPad(
                            0,
                            _colors[0],
                            const BorderRadius.only(
                                topLeft: Radius.circular(100)))),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: _buildPad(
                            1,
                            _colors[1],
                            const BorderRadius.only(
                                topRight: Radius.circular(100)))),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildPad(
                            2,
                            _colors[2],
                            const BorderRadius.only(
                                bottomLeft: Radius.circular(100)))),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildPad(
                            3,
                            _colors[3],
                            const BorderRadius.only(
                                bottomRight: Radius.circular(100)))),

                    // Center Start Button
                    Center(
                      child: GestureDetector(
                        onTap: _isGameActive ? null : _startGame,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.black45, blurRadius: 10)
                              ]),
                          child: Center(
                            child: Text(
                              _isGameActive ? '$_score' : 'JUGAR',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPad(int index, Color color, BorderRadius geometry) {
    final isLit = _activeLightIndex == index;
    return GestureDetector(
      onTapDown: (_) => _onColorTap(index), // Tap down feels faster
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
            color: isLit ? color : color.withOpacity(0.6),
            borderRadius: geometry,
            boxShadow: isLit
                ? [BoxShadow(color: color, blurRadius: 30, spreadRadius: 5)]
                : [
                    const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2))
                  ]),
      ),
    );
  }
}
