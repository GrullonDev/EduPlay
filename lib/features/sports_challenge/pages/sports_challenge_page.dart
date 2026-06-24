import 'dart:async';
import 'dart:math';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportsChallengePage extends StatefulWidget {
  const SportsChallengePage({super.key});

  @override
  State<SportsChallengePage> createState() => _SportsChallengePageState();
}

class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
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

    // Capture before setState so the dialog builder always sees the real value
    final finalScore = _score;

    setState(() {
      _isGameActive = false;
      _isItemVisible = false;
    });

    sl<StudentRepository>().recordScore(
      subjectKey: 'sports',
      gameTitle: 'Desafío Deportivo',
      score: finalScore,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1B6A), Color(0xFF2D2A82)],
                  ),
                ),
                child: Column(
                  children: [
                    const Text('⏱️', style: TextStyle(fontSize: 52)),
                    const SizedBox(height: 10),
                    Text(
                      '¡Tiempo Agotado!',
                      style: GoogleFonts.fredoka(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // White body
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                child: Column(
                  children: [
                    Text(
                      'Puntuación final: $finalScore goles ⚽',
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E1B6A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                RouterPaths.childPortal,
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E1B6A),
                              side: const BorderSide(color: Color(0xFF1E1B6A)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Inicio',
                                style: GoogleFonts.fredoka(fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _startGame();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6E6C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('¡Jugar de nuevo!',
                                style: GoogleFonts.fredoka(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
