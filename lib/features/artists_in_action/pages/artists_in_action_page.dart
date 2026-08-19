import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';
import 'package:edu_play/features/games/core/widgets/answer_explanation_sheet.dart';
import 'package:edu_play/features/games/core/widgets/game_objective_intro.dart';
import 'package:edu_play/shared/data/skill_catalog.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:flutter/material.dart';

enum DrawMode { pen, eraser, sticker }

// Represents either a freehand stroke or a placed sticker
class DrawObject {
  // For stickers

  DrawObject.stroke(this.points, this.color, this.width)
      : position = null,
        icon = null;
  DrawObject.sticker(this.position, this.icon, this.color)
      : points = null,
        width = 0;
  final List<Offset>? points; // For pen
  final Color color;
  final double width;
  final Offset? position; // For stickers
  final IconData? icon;

  bool get isSticker => position != null;
}

class ArtistsInActionPage extends StatefulWidget {
  const ArtistsInActionPage({super.key});

  @override
  State<ArtistsInActionPage> createState() => _ArtistsInActionPageState();
}

class _ArtistsInActionPageState extends State<ArtistsInActionPage> {
  final List<DrawObject> _history = [];
  DrawObject? _currentStroke;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;
  DrawMode _mode = DrawMode.pen;
  IconData _selectedSticker = Icons.star;

  /// Free drawing has no right/wrong answers, so this just tallies
  /// participation — it lets the skill report show "practicó artes
  /// visuales" instead of leaving the subject with zero data forever.
  final SkillTracker skillTracker = SkillTracker();
  bool _finished = false;

  // Sticker palette
  final List<IconData> _stickers = [
    Icons.star,
    Icons.favorite,
    Icons.sentiment_satisfied_alt,
    Icons.pets,
    Icons.flight,
    Icons.music_note
  ];

  @override
  void initState() {
    super.initState();
    // Shown once the first frame is up, so the player knows what this
    // activity is (free drawing) before touching the canvas.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showObjectiveIntro());
  }

  Future<void> _showObjectiveIntro() async {
    if (!mounted) return;
    await showGameObjectiveIntro(
      context,
      gameTitle: 'Artistas en Acción',
      objective:
          'Vas a dibujar libremente en el lienzo: usa el lápiz para trazar '
          'líneas de distintos colores y grosores, el borrador para '
          'corregir, y las calcomanías para decorar tu creación.',
      difficultyLabel: 'Principiante (actividad libre, sin niveles)',
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (_mode == DrawMode.pen) {
      setState(() {
        _currentStroke = DrawObject.stroke(
            [details.localPosition], _selectedColor, _strokeWidth);
        _history.add(_currentStroke!);
      });
    } else if (_mode == DrawMode.eraser) {
      setState(() {
        // Eraser is just white pen
        _currentStroke = DrawObject.stroke(
            [details.localPosition], Colors.white, _strokeWidth * 3);
        _history.add(_currentStroke!);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_mode == DrawMode.pen || _mode == DrawMode.eraser) {
      setState(() {
        _currentStroke?.points?.add(details.localPosition);
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_mode == DrawMode.sticker) {
      setState(() {
        _history.add(DrawObject.sticker(
            details.localPosition, _selectedSticker, _selectedColor));
      });
    }
  }

  void _undo() {
    if (_history.isNotEmpty) {
      setState(() {
        _history.removeLast();
      });
    }
  }

  void _clearCanvas() {
    setState(() {
      _history.clear();
    });
  }

  /// Records the practice as a skill entry and shows encouraging feedback
  /// before leaving — mirrors the finish flow in Color Concert / Sports
  /// Challenge so every game reports concrete skill practice, not just
  /// this one silently closing with nothing recorded.
  Future<void> _finishSession() async {
    if (_finished || _history.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    _finished = true;

    skillTracker.record('artes_visuales', correct: true);
    sl<StudentRepository>().recordScore(
      subjectKey: 'art',
      gameTitle: 'Artistas en Acción',
      score: (_history.length.clamp(0, 50) * 2).toInt(),
      skills: skillTracker.tallies,
      gameRoute: '/artists-in-action',
    );

    await showAnswerExplanation(
      context,
      isCorrect: true,
      correctAnswerText: '',
      explanation: '¡Practicaste trazo, color y composición en tu dibujo! '
          'Dibujar libremente ayuda a desarrollar la motricidad fina y la '
          'creatividad visual.',
      skillLabel: skillByKey('artes_visuales').label,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artistas en Acción'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _history.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearCanvas,
          ),
          TextButton.icon(
            onPressed: _finishSession,
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            label: const Text('Listo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Canvas Layer
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _currentStroke = null,
            onTapUp: _onTapUp,
            child: ClipRect(
              child: CustomPaint(
                painter: _SketchPainter(_history),
                size: Size.infinite,
              ),
            ),
          ),

          // Floating Toolbar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2))
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tools Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: _mode == DrawMode.pen
                                ? Colors.blue
                                : Colors.grey),
                        onPressed: () => setState(() => _mode = DrawMode.pen),
                      ),
                      IconButton(
                        icon: Icon(Icons.cleaning_services,
                            color: _mode == DrawMode.eraser
                                ? Colors.blue
                                : Colors.grey),
                        onPressed: () =>
                            setState(() => _mode = DrawMode.eraser),
                      ),
                      IconButton(
                        icon: Icon(Icons.emoji_emotions,
                            color: _mode == DrawMode.sticker
                                ? Colors.blue
                                : Colors.grey),
                        onPressed: () =>
                            setState(() => _mode = DrawMode.sticker),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Contextual Palette
                  if (_mode == DrawMode.sticker)
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _stickers
                            .map((icon) => GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedSticker = icon),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: _selectedSticker == icon
                                            ? Colors.grey[200]
                                            : null,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Icon(icon, color: _selectedColor),
                                  ),
                                ))
                            .toList(),
                      ),
                    )
                  else
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildColorButton(Colors.black),
                          _buildColorButton(Colors.red),
                          _buildColorButton(Colors.green),
                          _buildColorButton(Colors.blue),
                          _buildColorButton(Colors.purple),
                          _buildColorButton(Colors.orange),
                          const VerticalDivider(),
                          _buildWidthButton(5.0),
                          _buildWidthButton(10.0),
                          _buildWidthButton(20.0),
                        ],
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _selectedColor == color
              ? Border.all(color: Colors.grey, width: 3)
              : null,
        ),
      ),
    );
  }

  Widget _buildWidthButton(double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _strokeWidth = width;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: _strokeWidth == width
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Container(
              width: width,
              height: width,
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  _SketchPainter(this.objects);
  final List<DrawObject> objects;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    for (final obj in objects) {
      if (obj.isSticker && obj.position != null && obj.icon != null) {
        // Draw Icon
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(obj.icon!.codePoint),
          style: TextStyle(
            color: obj.color,
            fontSize: 40.0,
            fontFamily: obj.icon!.fontFamily,
            package: obj.icon!.fontPackage,
          ),
        );
        textPainter.layout();
        textPainter.paint(
            canvas, obj.position! - const Offset(20, 20)); // Center it
      } else if (obj.points != null && obj.points!.isNotEmpty) {
        // Draw Stroke
        final paint = Paint()
          ..color = obj.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = obj.width
          ..style = PaintingStyle.stroke;

        final path = Path();
        path.moveTo(obj.points!.first.dx, obj.points!.first.dy);
        for (int i = 1; i < obj.points!.length; i++) {
          path.lineTo(obj.points![i].dx, obj.points![i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SketchPainter oldDelegate) => true;
}
