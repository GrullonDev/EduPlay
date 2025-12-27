import 'package:flutter/material.dart';

class TimeTravelPage extends StatefulWidget {
  const TimeTravelPage({super.key});

  @override
  State<TimeTravelPage> createState() => _TimeTravelPageState();
}

class _TimeTravelPageState extends State<TimeTravelPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isFinished = false;

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
  ];

  void _answerQuestion(int selectedIndex) {
    if (_questions[_currentQuestionIndex]['answer'] == selectedIndex) {
      setState(() {
        _score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Correcto!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Incorrecto!'), backgroundColor: Colors.red),
      );
    }

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
      _isFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje en el Tiempo'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1BEE7), Color(0xFFF3E5F5)],
          ),
        ),
        child: _isFinished
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¡Juego Terminado!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Puntuación: $_score / ${_questions.length}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Jugar de nuevo'),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _questions[_currentQuestionIndex]['question']
                              as String,
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                              foregroundColor: const Color(0xFF9C27B0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                  color: Color(0xFF9C27B0), width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
