import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kGold = Color(0xFFFFD32A);

class TimeTravelPage extends StatefulWidget {
  const TimeTravelPage({super.key});

  @override
  State<TimeTravelPage> createState() => _TimeTravelPageState();
}

class _TimeTravelPageState extends State<TimeTravelPage>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _streak = 0;
  bool _isFinished = false;

  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  Color _feedbackColor = Colors.transparent;
  IconData? _feedbackIcon;

  final List<Map<String, Object>> _questions = [
    {
      'question': '¿Qué animal vivía en la época de los dinosaurios?',
      'options': ['T-Rex', 'Gato', 'Perro', 'Vaca'],
      'answer': 0,
    },
    {
      'question': '¿Cómo viajaban las personas antes de los coches?',
      'options': ['En avión', 'En caballo', 'En cohete', 'Teletransportación'],
      'answer': 1,
    },
    {
      'question': '¿Quiénes vivían en castillos grandes de piedra?',
      'options': ['Astronautas', 'Robots', 'Reyes y Reinas', 'Cavernícolas'],
      'answer': 2,
    },
    {
      'question': '¿Qué usaban los piratas para buscar tesoros?',
      'options': ['GPS', 'Google Maps', 'Mapas de papel', 'Brújula mágica'],
      'answer': 2,
    },
    {
      'question': '¿Qué invento usamos para ver en la oscuridad?',
      'options': ['La Rueda', 'La Bombilla', 'El Teléfono', 'El Coche'],
      'answer': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _answerQuestion(int selectedIndex) {
    final isCorrect =
        _questions[_currentQuestionIndex]['answer'] == selectedIndex;

    setState(() {
      if (isCorrect) {
        _score++;
        _streak++;
        _feedbackColor = const Color(0xFF43A047);
        _feedbackIcon = Icons.check_circle_rounded;
      } else {
        _streak = 0;
        _feedbackColor = _kCoral;
        _feedbackIcon = Icons.cancel_rounded;
      }
    });

    _feedbackController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _feedbackController.reverse();
          _nextQuestion();
        }
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      final finalScore = _score; // capture before any state change
      setState(() => _isFinished = true);
      sl<StudentRepository>().recordScore(
        subjectKey: 'history',
        gameTitle: 'Viaje en el Tiempo',
        score: finalScore,
      );
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _streak = 0;
      _isFinished = false;
    });
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouterPaths.childPortal,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      appBar: AppBar(
        backgroundColor: const Color(0xFF16125C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Viaje en el Tiempo',
          style: GoogleFonts.fredoka(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _goHome,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Racha: $_streak 🔥',
                  style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF16125C),
                  Color(0xFF231B72),
                  Color(0xFF12104A),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Decorative blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kCoral.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D2D3).withValues(alpha: 0.08),
              ),
            ),
          ),

          // ── Completion overlay ──────────────────────────────────────────────
          if (_isFinished)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _CompletionCard(
                  score: _score,
                  total: _questions.length,
                  onPlayAgain: _resetQuiz,
                  onGoHome: _goHome,
                ),
              ),
            )
          else ...[
            // ── Progress bar ────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(_kGold),
                minHeight: 4,
              ),
            ),

            // ── Question + options ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Pregunta ${_currentQuestionIndex + 1} / ${_questions.length}',
                          style: GoogleFonts.nunito(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _questions[_currentQuestionIndex]['question']
                              as String,
                          style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer options
                  Expanded(
                    child: ListView(
                      children: (_questions[_currentQuestionIndex]['options']
                              as List<String>)
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ElevatedButton(
                                  onPressed: () => _answerQuestion(entry.key),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.10),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: BorderSide(
                                          color: Colors.white
                                              .withValues(alpha: 0.20)),
                                    ),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: GoogleFonts.nunito(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Answer feedback flash ───────────────────────────────────────────
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _feedbackColor.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4)
                  ],
                ),
                child: Icon(_feedbackIcon, size: 64, color: _feedbackColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion card ───────────────────────────────────────────────────────────

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.score,
    required this.total,
    required this.onPlayAgain,
    required this.onGoHome,
  });
  final int score;
  final int total;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final isPerfect = score == total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPerfect
                    ? [const Color(0xFFFF6E6C), const Color(0xFFFF9A5C)]
                    : [const Color(0xFF7B61FF), const Color(0xFF9F8BFF)],
              ),
            ),
            child: Column(
              children: [
                Text(isPerfect ? '🏆' : '⭐',
                    style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 10),
                Text(
                  isPerfect ? '¡Perfecto!' : '¡Aventura Completada!',
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
                  'Puntuación: $score / $total',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B6A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  score >= total ~/ 2
                      ? '¡Muy buen trabajo! 🎉'
                      : '¡Sigue practicando! 💪',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onGoHome,
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
                        onPressed: onPlayAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kCoral,
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
    );
  }
}
