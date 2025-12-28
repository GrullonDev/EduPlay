import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class SportsChallengePage extends StatefulWidget {
  const SportsChallengePage({super.key});

  @override
  State<SportsChallengePage> createState() => _SportsChallengePageState();
}

class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 80, paint);

    // Half way line
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SportsChallengePageState extends State<SportsChallengePage>
    with TickerProviderStateMixin {
  int _score = 0;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Random _random = Random();

  Alignment _ballAlignment = Alignment.center;
  bool _isItemVisible = false;
  bool _isGameActive = false;
  bool _isRedCard = false; // "Bomb" type item

  // Animation
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafío Deportivo'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background - Field Pattern
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: CustomPaint(
              painter: _FieldPainter(),
              size: Size.infinite,
            ),
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
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ]),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('$_timeLeft s',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ]),
                    child: Text('Goles: $_score',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800])),
                  ),
                ],
              ),
            ),
          ),

          // Start Overlay
          if (!_isGameActive)
            Container(
              color: Colors.black45,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '¡Entrenamiento!',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 10)
                          ]),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Toca los balones. Evita las tarjetas rojas.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          backgroundColor: Colors.amber, // Whistle color
                          foregroundColor: Colors.black),
                      child: const Text('¡SILBATAZO!',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          // The Item (Ball or Card)
          if (_isGameActive && _isItemVisible)
            Align(
              alignment: _ballAlignment,
              child: GestureDetector(
                onTap: _onItemTap,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _isRedCard
                      ? Container(
                          width: 80,
                          height: 110,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(4, 4))
                              ]),
                          child: const Center(
                              child: Icon(Icons.warning_amber_rounded,
                                  color: Colors.white, size: 40)),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 10,
                                    offset: Offset(2, 5))
                              ]),
                          child: const Icon(Icons.sports_soccer,
                              size: 80, color: Colors.white),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        lowerBound: 0.0,
        upperBound: 1.0);
    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _scaleController.stop();
    setState(() {
      _isGameActive = false;
      _isItemVisible = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Tiempo Agotado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_soccer, size: 50, color: Colors.green),
            const SizedBox(height: 10),
            Text('Puntuación final: $_score',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
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
              Navigator.pop(context);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _hideItem() {
    if (!mounted) return;

    // Animate out? For simplicity just disappear or define reverse animation
    // Let's just reset loop
    setState(() {
      _isItemVisible = false;
    });
    // Pause before next
    Future.delayed(const Duration(milliseconds: 300), _spawnItem);
  }

  void _onItemTap() {
    if (!_isItemVisible) return;

    if (_isRedCard) {
      // Penalty!
      setState(() {
        _timeLeft = max(0, _timeLeft - 5);
        _isItemVisible = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Tarjeta Roja! -5 Segundos'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 500)));
    } else {
      // Goal!
      setState(() {
        _score++;
        _isItemVisible = false;
      });
    }

    _spawnTimer?.cancel();
    Future.delayed(const Duration(milliseconds: 100), _spawnItem);
  }

  void _spawnItem() {
    if (!_isGameActive) return;

    // 20% chance to be a Red Card (Bomb)
    bool isRedCard = _random.nextDouble() < 0.2;

    setState(() {
      _ballAlignment = Alignment(
        _random.nextDouble() * 1.6 -
            0.8, // Slightly reduced range to avoid edges
        _random.nextDouble() * 1.4 - 0.7, // Avoid top/bottom UI overlap
      );
      _isRedCard = isRedCard;
      _isItemVisible = true;
    });

    _scaleController.forward(from: 0.0);

    // Dynamic duration based on score (gets faster)
    int duration = max(800, 1500 - (_score * 20));

    _spawnTimer?.cancel();
    _spawnTimer = Timer(Duration(milliseconds: duration), () {
      if (_isItemVisible && _isGameActive) {
        // Missed it
        _hideItem();
      }
    });
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isGameActive = true;
      _isItemVisible = false;
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

    _spawnItem();
  }
}
