import 'package:flutter/material.dart';

class TimeTravelPage extends StatefulWidget {
  const TimeTravelPage({super.key});

  @override
  State<TimeTravelPage> createState() => _TimeTravelPageState();
}

class _TimeTravelPageState extends State<TimeTravelPage>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _streak = 0; // Current winning streak
  bool _isFinished = false;

  // Animation for feedback
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
    bool isCorrect =
        _questions[_currentQuestionIndex]['answer'] == selectedIndex;

    setState(() {
      if (isCorrect) {
        _score++;
        _streak++;
        _feedbackColor = Colors.green;
        _feedbackIcon = Icons.check_circle;
      } else {
        _streak = 0;
        _feedbackColor = Colors.red;
        _feedbackIcon = Icons.cancel;
      }
    });

    _feedbackController.forward(from: 0.0).then((_) {
      // Wait a bit then reset animation and move to next question
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _feedbackController.reverse();
          _nextQuestion();
        }
      });
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _isFinished = true;
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _streak = 0;
      _isFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje en el Tiempo'),
        backgroundColor: const Color(0xFF673AB7), // Deep Purple
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
                child: Text('Racha: $_streak 🔥',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
              ),
            ),
          ),

          if (_isFinished)
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 80, color: Colors.amber),
                    const SizedBox(height: 20),
                    Text(
                      '¡Aventura Completada!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Puntuación: $_score / ${_questions.length}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _resetQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Jugar de nuevo',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  'Pregunta ${_currentQuestionIndex + 1}',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _questions[_currentQuestionIndex]['question']
                                      as String,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF311B92)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Options
                        ...(_questions[_currentQuestionIndex]['options']
                                as List<String>)
                            .asMap()
                            .entries
                            .map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(entry.key),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF673AB7),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                shadowColor: Colors.black26,
                              ),
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          // Feedback Overlay
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 20)
                    ]),
                child: Icon(_feedbackIcon, size: 80, color: _feedbackColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
