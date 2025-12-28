import 'package:flutter/material.dart';

enum DrawMode { pen, eraser, sticker }

// Represents either a freehand stroke or a placed sticker
class DrawObject {
  final List<Offset>? points; // For pen
  final Color color;
  final double width;
  final Offset? position; // For stickers
  final IconData? icon; // For stickers

  DrawObject.stroke(this.points, this.color, this.width)
      : position = null,
        icon = null;
  DrawObject.sticker(this.position, this.icon, this.color)
      : points = null,
        width = 0;

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

  // Sticker palette
  final List<IconData> _stickers = [
    Icons.star,
    Icons.favorite,
    Icons.sentiment_satisfied_alt,
    Icons.pets,
    Icons.flight,
    Icons.music_note
  ];

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
          )
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
              decoration:
                  const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  final List<DrawObject> objects;

  _SketchPainter(this.objects);

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
        textPainter.paint(canvas, obj.position! - const Offset(20, 20)); // Center it
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
