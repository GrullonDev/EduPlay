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
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];
  List<int> _sequence = [];
  List<int> _userSequence = [];
  int _score = 0;
  bool _isShowingSequence = false;
  int? _activeLightIndex; // Currently lit up button
  String _message = '¡Memoriza la secuencia!';

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _sequence = [];
      _userSequence = [];
      _score = 0;
      _message = '¡Memoriza la secuencia!';
    });
    // Start first round with delay
    Future.delayed(const Duration(seconds: 1), _nextRound);
  }

  void _nextRound() {
    setState(() {
      _userSequence = [];
      _sequence.add(Random().nextInt(4)); // Add random color index
      _message = 'Nivel ${_sequence.length}';
      _isShowingSequence = true;
    });
    _playSequence();
  }

  Future<void> _playSequence() async {
    for (int index in _sequence) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _activeLightIndex = index;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _activeLightIndex = null;
      });
    }
    setState(() {
      _isShowingSequence = false;
      _message = '¡Tu turno!';
    });
  }

  void _onColorTap(int index) {
    if (_isShowingSequence) return;

    setState(() {
      // Simple flash effect on tap
      _activeLightIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
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
        _message = '¡Bien hecho!';
      });
      Future.delayed(const Duration(seconds: 1), _nextRound);
    }
  }

  void _gameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Juego Terminado!'),
        content: Text('Llegaste al Nivel ${_sequence.length - 1}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concierto de Colores'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _message,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPad(0, Colors.red),
              const SizedBox(width: 20),
              _buildPad(1, Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPad(2, Colors.green),
              const SizedBox(width: 20),
              _buildPad(3, Colors.yellow),
            ],
          ),
          const SizedBox(height: 40),
          Text('Puntaje: $_score',
              style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPad(int index, Color color) {
    final isLit = _activeLightIndex == index;
    return GestureDetector(
      onTap: () => _onColorTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
            color: isLit ? color : color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 4),
            boxShadow: isLit ? [BoxShadow(color: color, blurRadius: 20)] : []),
        child: Icon(Icons.music_note,
            color: isLit ? Colors.white : color.withOpacity(0.5), size: 40),
      ),
    );
  }
}
