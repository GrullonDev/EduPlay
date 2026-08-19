import 'dart:async';
import 'dart:math';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
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

  // Mistake counters kept for the end-of-game educational summary — a
  // reflex game like this one is too fast to interrupt with a modal on
  // every single miss without breaking the pace.
  int _penaltyCount = 0;
  int _missedBalls = 0;

  /// Per-skill correct/total tally for this session, sent alongside the
  /// score when the round ends.
  final SkillTracker skillTracker = SkillTracker();

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
                      onPressed: _onStartPressed,
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

  Future<void> _onStartPressed() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Desafío Deportivo',
      objective:
          'Vas a poner a prueba tus reflejos y tu coordinación mano-ojo: toca los balones apenas aparezcan y evita las tarjetas rojas. Entre más rápido reacciones, más veloz se vuelve el juego.',
      difficultyLabel: 'Principiante',
    );
    if (!mounted) return;
    _startGame();
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _scaleController.stop();

    // Capture before setState so the dialog builder always sees the real value
    final finalScore = _score;
    final finalSkills = skillTracker.tallies;
    final penalties = _penaltyCount;
    final missed = _missedBalls;

    setState(() {
      _isGameActive = false;
      _isItemVisible = false;
    });

    sl<StudentRepository>().recordScore(
      subjectKey: 'sports',
      gameTitle: 'Desafío Deportivo',
      score: finalScore,
      skills: finalSkills,
      gameRoute: '/sports-challenge',
    );

    // A whack-a-mole round is too fast to explain every miss live, so the
    // educational feedback is a single summary shown once the round ends.
    final hasMistakes = penalties > 0 || missed > 0;
    await showAnswerExplanation(
      context,
      isCorrect: !hasMistakes,
      correctAnswerText: hasMistakes
          ? 'Fíjate bien antes de tocar: solo el balón cuenta como gol; la tarjeta roja te resta tiempo.'
          : '¡Reaccionaste a tiempo y evitaste todas las tarjetas rojas!',
      explanation: hasMistakes
          ? 'Tocaste $penalties tarjeta(s) roja(s) y dejaste pasar $missed balón(es) sin tocar. Para mejorar, mantén la vista fija en el centro de la cancha y reacciona apenas veas el balón, sin tocar lo rojo.'
          : 'Mantuviste la concentración durante todo el reto: tocaste los balones a tiempo y no caíste en ninguna tarjeta roja. Así se entrena la coordinación mano-ojo.',
      skillLabel: skillByKey('reflejos').label,
    );
    if (!mounted) return;

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
                              Navigator.pop(ctx); // dismiss game-over dialog
                              StudentSessionNavigationService
                                  .returnAfterGameOver(context);
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
      // Penalty! Touching a red card is the "wrong item" mistake.
      skillTracker.record('reflejos', correct: false);
      _penaltyCount++;
      setState(() {
        _timeLeft = max(0, _timeLeft - 5);
        _isItemVisible = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Tarjeta Roja! -5 Segundos'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 500)));
    } else {
      // Goal! Tapped the ball in time.
      skillTracker.record('reflejos', correct: true);
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
        // Timed out without a tap: letting a ball go is a missed reflex,
        // but letting a red card go untouched is the *correct* call.
        final wasRedCard = _isRedCard;
        skillTracker.record('reflejos', correct: wasRedCard);
        if (!wasRedCard) {
          _missedBalls++;
        }
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
      _penaltyCount = 0;
      _missedBalls = 0;
      skillTracker.reset();
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
