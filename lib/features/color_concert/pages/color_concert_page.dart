// Dart imports:
import 'dart:async';
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

  // Each pad is framed as a musical note so the memory challenge has a
  // musical hook, even though the game itself doesn't play real audio yet.
  static const List<String> _padNoteNames = ['Do', 'Re', 'Mi', 'Fa'];
  static const List<String> _padColorNames = [
    'rojo',
    'azul',
    'verde',
    'amarillo'
  ];

  String _padLabel(int index) => '${_padNoteNames[index]} (${_padColorNames[index]})';

  List<int> _sequence = [];
  List<int> _userSequence = [];
  int _score = 0;
  bool _isPlayingSequence = false;
  bool _isGameActive = false;
  bool _playedTodayMarked = false;
  int? _activeLightIndex; // Currently lit up button
  String _message = '¡Bienvenido al Concierto!';

  /// Per-skill correct/total tally for the current session, sent alongside
  /// the score when the game ends.
  final SkillTracker skillTracker = SkillTracker();

  /// Shows the learning objective before each new game starts, so the
  /// player knows what they're about to practice.
  Future<void> _showIntroAndStart() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Concierto de Colores',
      objective:
          'Memoriza la secuencia de colores que se ilumina — cada color '
          'representa una nota musical distinta — y repítela tocando los '
          'pads en el mismo orden. Cada ronda que superas agrega un color '
          'más a la secuencia y la reproduce más rápido.',
      difficultyLabel:
          'Principiante (la secuencia crece y se acelera en cada ronda)',
    );
    if (!mounted) return;
    _startGame();
  }

  void _startGame() {
    setState(() {
      _sequence = [];
      _userSequence = [];
      _score = 0;
      _message = '¡Atento!';
      _isGameActive = true;
      _playedTodayMarked = false;
      skillTracker.reset();
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

  Future<void> _onColorTap(int index) async {
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

    final int position = _userSequence.length;
    _userSequence.add(index);

    // Check correctness immediately
    final bool tapIsCorrect = index == _sequence[position];
    skillTracker.record('teoria_musical', correct: tapIsCorrect);

    if (!tapIsCorrect) {
      final correctIndex = _sequence[position];
      await showAnswerExplanation(
        context,
        isCorrect: false,
        correctAnswerText: _padLabel(correctIndex),
        explanation: 'La secuencia era: '
            '${_sequence.map(_padLabel).join(' → ')}. '
            'En el Concierto de Colores cada color representa una nota '
            'distinta: repetir el orden exacto entrena tu memoria musical.',
        skillLabel: skillByKey('teoria_musical').label,
      );
      if (!mounted) return;
      _gameOver();
      return;
    }

    if (_userSequence.length == _sequence.length) {
      // Round complete
      setState(() {
        _score++;
        _message = '¡Correcto!';
      });
      // First completed round of the session keeps the streak alive right
      // away, instead of waiting for the player to eventually fail.
      if (!_playedTodayMarked) {
        _playedTodayMarked = true;
        sl<StudentRepository>().markPlayedToday();
      }
      Future.delayed(const Duration(seconds: 1), _nextRound);
    }
  }

  void _gameOver() {
    setState(() {
      _isGameActive = false;
      _message = '¡Fallaste!';
    });

    sl<StudentRepository>().recordScore(
      subjectKey: 'music',
      gameTitle: 'Concierto de Colores',
      score: _score * 10,
      skills: skillTracker.tallies,
      gameRoute: '/color-concert',
    );

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
              _showIntroAndStart();
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
                        onTap: _isGameActive ? null : _showIntroAndStart,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
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
            color: isLit ? color : color.withValues(alpha: 0.6),
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
