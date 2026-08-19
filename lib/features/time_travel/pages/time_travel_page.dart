import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kGold = Color(0xFFFFD32A);

/// One trivia question, tagged with a difficulty tier (1 = fácil ... 3 =
/// avanzado) so a session can start with basic facts and work up to more
/// specific ones instead of always asking the same fixed 5 questions.
class _TimeTravelQuestion {
  const _TimeTravelQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    required this.tier,
  });
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final int tier;
}

/// Full question bank, grouped by difficulty tier. Kept honest to what
/// this quiz actually is: kid-friendly trivia across scattered historical
/// topics (prehistoria, Egipto, Roma, Edad Media, piratas, inventos), not
/// the geopolitics/world-leaders framing used elsewhere in the catalog.
const List<_TimeTravelQuestion> _questionBank = [
  // Tier 1 — fácil
  _TimeTravelQuestion(
    question: '¿Qué animal vivía en la época de los dinosaurios?',
    options: ['T-Rex', 'Gato', 'Perro', 'Vaca'],
    answerIndex: 0,
    explanation:
        'El Tiranosaurio Rex vivió hace unos 66 millones de años, mucho '
        'antes de que existieran los gatos y los perros.',
    tier: 1,
  ),
  _TimeTravelQuestion(
    question: '¿Cómo viajaban las personas antes de los coches?',
    options: ['En avión', 'En caballo', 'En cohete', 'Teletransportación'],
    answerIndex: 1,
    explanation:
        'Antes de inventarse los motores, la gente usaba caballos y '
        'carretas para moverse de un lugar a otro.',
    tier: 1,
  ),
  _TimeTravelQuestion(
    question: '¿Quiénes vivían en castillos grandes de piedra?',
    options: ['Astronautas', 'Robots', 'Reyes y Reinas', 'Cavernícolas'],
    answerIndex: 2,
    explanation:
        'Los reyes, las reinas y los nobles vivían en castillos de '
        'piedra durante la Edad Media, hace cientos de años.',
    tier: 1,
  ),
  _TimeTravelQuestion(
    question: '¿Qué usaban los piratas para buscar tesoros?',
    options: ['GPS', 'Google Maps', 'Mapas de papel', 'Brújula mágica'],
    answerIndex: 2,
    explanation:
        'Los piratas dibujaban mapas en papel para marcar dónde '
        'escondían sus tesoros, mucho antes de que existiera el GPS.',
    tier: 1,
  ),
  _TimeTravelQuestion(
    question: '¿Qué invento usamos para ver en la oscuridad?',
    options: ['La Rueda', 'La Bombilla', 'El Teléfono', 'El Coche'],
    answerIndex: 1,
    explanation:
        'La bombilla eléctrica se popularizó a finales del siglo XIX y '
        'cambió para siempre las noches de las personas.',
    tier: 1,
  ),
  _TimeTravelQuestion(
    question: '¿Dónde vivían los cavernícolas de la prehistoria?',
    options: ['En cuevas', 'En rascacielos', 'En barcos', 'En castillos'],
    answerIndex: 0,
    explanation:
        'Los primeros seres humanos se refugiaban en cuevas para '
        'protegerse del frío y de los animales.',
    tier: 1,
  ),
  // Tier 2 — intermedio
  _TimeTravelQuestion(
    question: '¿Quiénes construyeron las pirámides de Egipto?',
    options: [
      'Los antiguos egipcios',
      'Los vikingos',
      'Los romanos',
      'Los piratas',
    ],
    answerIndex: 0,
    explanation:
        'Los antiguos egipcios construyeron las pirámides hace más de '
        '4.000 años como tumbas para sus faraones.',
    tier: 2,
  ),
  _TimeTravelQuestion(
    question:
        '¿Qué imperio construyó grandes caminos y acueductos en Europa?',
    options: [
      'El Imperio Romano',
      'El Imperio Azteca',
      'El Imperio Chino',
      'El Imperio Inca',
    ],
    answerIndex: 0,
    explanation:
        'El Imperio Romano construyó miles de kilómetros de caminos y '
        'acueductos que todavía se pueden ver hoy.',
    tier: 2,
  ),
  _TimeTravelQuestion(
    question:
        '¿Qué usaban los caballeros medievales para protegerse en batalla?',
    options: [
      'Armaduras de metal',
      'Trajes de baño',
      'Ropa de algodón',
      'Capas de papel',
    ],
    answerIndex: 0,
    explanation:
        'Los caballeros medievales usaban armaduras de metal para '
        'protegerse de espadas y flechas.',
    tier: 2,
  ),
  _TimeTravelQuestion(
    question: '¿Quién llegó a América en 1492 desde España?',
    options: ['Cristóbal Colón', 'Julio César', 'Napoleón', 'Marco Polo'],
    answerIndex: 0,
    explanation:
        'Cristóbal Colón llegó a tierras americanas en 1492 mientras '
        'buscaba una ruta hacia Asia.',
    tier: 2,
  ),
  _TimeTravelQuestion(
    question: '¿Qué pueblo navegaba en barcos llamados drakkar?',
    options: ['Los vikingos', 'Los piratas', 'Los egipcios', 'Los romanos'],
    answerIndex: 0,
    explanation:
        'Los vikingos navegaban desde el norte de Europa en barcos '
        'largos y veloces llamados drakkar.',
    tier: 2,
  ),
  _TimeTravelQuestion(
    question:
        '¿Qué invento permitió imprimir libros en vez de copiarlos a mano?',
    options: ['La imprenta', 'El teléfono', 'La televisión', 'La computadora'],
    answerIndex: 0,
    explanation:
        'Johannes Gutenberg inventó la imprenta de tipos móviles en el '
        'siglo XV, lo que permitió producir libros mucho más rápido.',
    tier: 2,
  ),
  // Tier 3 — avanzado
  _TimeTravelQuestion(
    question: '¿En qué período geológico vivió el Triceratops?',
    options: [
      'El período Cretácico',
      'La Edad de Hielo',
      'El Renacimiento',
      'La Edad Media',
    ],
    answerIndex: 0,
    explanation:
        'El Triceratops vivió durante el período Cretácico, hace unos '
        '68 millones de años, poco antes de la extinción de los '
        'dinosaurios.',
    tier: 3,
  ),
  _TimeTravelQuestion(
    question:
        '¿Cómo se llama el período de la historia europea entre la caída '
        'de Roma y el Renacimiento?',
    options: ['Edad Media', 'Edad de Piedra', 'Edad Moderna', 'Prehistoria'],
    answerIndex: 0,
    explanation:
        'La Edad Media duró casi mil años, entre la caída del Imperio '
        'Romano y el inicio del Renacimiento.',
    tier: 3,
  ),
  _TimeTravelQuestion(
    question:
        '¿Qué faraona egipcia fue una de las pocas mujeres que '
        'gobernaron el Antiguo Egipto?',
    options: ['Cleopatra', 'Isabel I', 'Catalina la Grande', 'Juana de Arco'],
    answerIndex: 0,
    explanation:
        'Cleopatra fue la última faraona activa del Antiguo Egipto y '
        'gobernó hace más de 2.000 años.',
    tier: 3,
  ),
  _TimeTravelQuestion(
    question:
        '¿Qué revolución tecnológica del siglo XVIII cambió las '
        'fábricas para siempre?',
    options: [
      'La Revolución Industrial',
      'La Guerra Fría',
      'El Renacimiento',
      'La Edad de Bronce',
    ],
    answerIndex: 0,
    explanation:
        'La Revolución Industrial, iniciada en Inglaterra en el siglo '
        'XVIII, introdujo las máquinas de vapor en las fábricas.',
    tier: 3,
  ),
  _TimeTravelQuestion(
    question:
        '¿Qué civilización prehispánica construyó Machu Picchu en los '
        'Andes?',
    options: ['Los incas', 'Los mayas', 'Los aztecas', 'Los vikingos'],
    answerIndex: 0,
    explanation:
        'Los incas construyeron Machu Picchu en las montañas de los '
        'Andes, en el actual Perú, hace más de 500 años.',
    tier: 3,
  ),
  _TimeTravelQuestion(
    question:
        '¿En qué era comenzaron los seres humanos a usar herramientas '
        'de piedra?',
    options: [
      'La Edad de Piedra',
      'La Edad Media',
      'La Era Digital',
      'La Edad de Bronce',
    ],
    answerIndex: 0,
    explanation:
        'La Edad de Piedra fue el primer gran período de la '
        'prehistoria, cuando los humanos fabricaban herramientas de '
        'piedra.',
    tier: 3,
  ),
];

class TimeTravelPage extends StatefulWidget {
  const TimeTravelPage({super.key});

  @override
  State<TimeTravelPage> createState() => _TimeTravelPageState();
}

class _TimeTravelPageState extends State<TimeTravelPage>
    with SingleTickerProviderStateMixin {
  static const String _skillId = 'historia';

  /// How many questions are drawn from each difficulty tier (fácil →
  /// intermedio → avanzado). One play-through is 3 tiers × this many, so
  /// later rounds are genuinely harder instead of repeating the same 5
  /// questions.
  static const int _questionsPerTier = 3;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int _streak = 0;
  bool _isFinished = false;
  bool _isAnswering = false;

  /// Populated after the player dismisses the objective intro, so the
  /// first question is only picked once they've seen what the quiz covers.
  List<_TimeTravelQuestion> _sessionQuestions = [];

  /// Per-skill correct/total tally for the current session, sent alongside
  /// the score when the game ends.
  final SkillTracker skillTracker = SkillTracker();

  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  Color _feedbackColor = Colors.transparent;
  IconData? _feedbackIcon;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Viaje en el Tiempo',
      objective:
          'Vas a responder preguntas de trivia sobre distintas épocas de '
          'la historia: la prehistoria y los dinosaurios, el antiguo '
          'Egipto y Roma, los castillos medievales, los piratas y '
          'algunos inventos importantes. Las preguntas se vuelven más '
          'específicas a medida que avanzas.',
      difficultyLabel: 'Intermedio',
    );
    if (!mounted) return;
    setState(() {
      _sessionQuestions = _buildSessionQuestions();
    });
  }

  /// Draws [_questionsPerTier] random, non-repeating questions from each
  /// tier and concatenates them in order, so tier 1 (fácil) always opens
  /// the session and tier 3 (avanzado) always closes it.
  List<_TimeTravelQuestion> _buildSessionQuestions() {
    final result = <_TimeTravelQuestion>[];
    for (final tier in [1, 2, 3]) {
      final tierQuestions =
          _questionBank.where((q) => q.tier == tier).toList()..shuffle();
      result.addAll(tierQuestions.take(_questionsPerTier));
    }
    return result;
  }

  Future<void> _answerQuestion(int selectedIndex) async {
    if (_isAnswering || _sessionQuestions.isEmpty) return;
    final currentQuestion = _sessionQuestions[_currentQuestionIndex];
    final isCorrect = currentQuestion.answerIndex == selectedIndex;

    _isAnswering = true;
    skillTracker.record(_skillId, correct: isCorrect);

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

    await _feedbackController.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _feedbackController.reverse();

    if (!isCorrect) {
      await showAnswerExplanation(
        context,
        isCorrect: false,
        correctAnswerText: currentQuestion.options[currentQuestion.answerIndex],
        explanation: currentQuestion.explanation,
        skillLabel: skillByKey(_skillId).label,
      );
      if (!mounted) return;
    }

    _isAnswering = false;
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _sessionQuestions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      final finalScore = _score; // capture before any state change
      setState(() => _isFinished = true);
      sl<StudentRepository>().recordScore(
        subjectKey: 'history',
        gameTitle: 'Viaje en el Tiempo',
        score: finalScore,
        skills: skillTracker.tallies,
        gameRoute: '/time-travel',
      );
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _streak = 0;
      _isFinished = false;
      _isAnswering = false;
      skillTracker.reset();
      _sessionQuestions = _buildSessionQuestions();
    });
  }

  void _goHome() {
    StudentSessionNavigationService.returnAfterGameOver(context);
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
                  total: _sessionQuestions.length,
                  onPlayAgain: _resetQuiz,
                  onGoHome: _goHome,
                ),
              ),
            )
          else if (_sessionQuestions.isEmpty)
            // Objective intro dialog is showing on top of this frame; no
            // question has been picked yet.
            const SizedBox.shrink()
          else ...[
            // ── Progress bar ────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _sessionQuestions.length,
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
                          'Pregunta ${_currentQuestionIndex + 1} / ${_sessionQuestions.length}',
                          style: GoogleFonts.nunito(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _sessionQuestions[_currentQuestionIndex].question,
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
                      children: _sessionQuestions[_currentQuestionIndex]
                          .options
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ElevatedButton(
                                  onPressed: _isAnswering
                                      ? null
                                      : () => _answerQuestion(entry.key),
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
