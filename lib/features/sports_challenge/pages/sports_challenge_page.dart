import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SportsChallengePage extends StatefulWidget {
  const SportsChallengePage({super.key});

  @override
  State<SportsChallengePage> createState() => _SportsChallengePageState();
}

class _SportsChallengePageState extends State<SportsChallengePage> {
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Random _random = Random();

  // Current active targets (IDs)
  // Using a simplified approach: Only one ball at a time for v1
  Alignment _ballAlignment = Alignment.center;
  bool _isBallVisible = false;
  bool _isGameActive = false;

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isGameActive = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endGame();
      }
    });

    _spawnBall();
  }

  void _spawnBall() {
    if (!_isGameActive) return;

    setState(() {
      _ballAlignment = Alignment(
        _random.nextDouble() * 1.8 -
            0.9, // Range -0.9 to 0.9 to stay in safe area
        _random.nextDouble() * 1.8 - 0.9,
      );
      _isBallVisible = true;
    });

    // Auto hide if not clicked after 1.5 seconds (difficulty)
    _spawnTimer?.cancel();
    _spawnTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_isBallVisible && _isGameActive) {
        setState(() {
          _isBallVisible = false;
        });
        // Try spawning again immediately
        Future.delayed(const Duration(milliseconds: 500), _spawnBall);
      }
    });
  }

  void _onBallTap() {
    if (!_isBallVisible) return;

    setState(() {
      _score++;
      _isBallVisible = false;
    });
    _spawnTimer?.cancel();

    // Spawn next ball quickly
    Future.delayed(const Duration(milliseconds: 300), _spawnBall);
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _isGameActive = false;
      _isBallVisible = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Tiempo!'),
        content: Text('Puntuación final: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Jugar de nuevo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to menu
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafío Deportivo'),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background - Field
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
          ),

          // HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Tiempo: $_timeLeft',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Puntos: $_score',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // Start Overlay
          if (!_isGameActive)
            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF795548)),
                child: const Text('¡INICIAR!',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ),
            ),

          // The Ball
          if (_isGameActive && _isBallVisible)
            Align(
              alignment: _ballAlignment,
              child: GestureDetector(
                onTap: _onBallTap,
                child: const Icon(Icons.sports_soccer,
                    size: 80, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
