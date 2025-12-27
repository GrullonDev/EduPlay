import 'package:flutter/material.dart';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  Stroke(this.points, this.color, this.width);
}

class ArtistsInActionPage extends StatefulWidget {
  const ArtistsInActionPage({super.key});

  @override
  State<ArtistsInActionPage> createState() => _ArtistsInActionPageState();
}

class _ArtistsInActionPageState extends State<ArtistsInActionPage> {
  final List<Stroke> _strokes = [];
  Stroke? _currentStroke;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;

  void _startStroke(Offset point) {
    setState(() {
      _currentStroke = Stroke([point], _selectedColor, _strokeWidth);
      _strokes.add(_currentStroke!);
    });
  }

  void _updateStroke(Offset point) {
    setState(() {
      _currentStroke?.points.add(point);
    });
  }

  void _endStroke() {
    _currentStroke = null;
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
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
            icon: const Icon(Icons.delete),
            onPressed: _clearCanvas,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (details) => _startStroke(details.localPosition),
              onPanUpdate: (details) => _updateStroke(details.localPosition),
              onPanEnd: (_) => _endStroke(),
              child: ClipRect(
                child: CustomPaint(
                  painter: _SketchPainter(_strokes),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          Container(
            height: 80,
            color: Colors.grey[200],
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: [
                _buildColorButton(Colors.black),
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.yellow),
                _buildColorButton(Colors.purple),
                _buildColorButton(Colors.orange),
                const VerticalDivider(),
                _buildWidthButton(5.0),
                _buildWidthButton(10.0),
                _buildWidthButton(15.0),
              ],
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: _selectedColor == color
                ? Border.all(color: Colors.grey, width: 4)
                : null,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ]),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: _strokeWidth == width
              ? Border.all(color: Colors.blue, width: 3)
              : null,
        ),
        child: Center(
          child: Container(
            width: width,
            height: width,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  final List<Stroke> strokes;

  _SketchPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw white background
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke;

      if (stroke.points.isNotEmpty) {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SketchPainter oldDelegate) => true;
}
