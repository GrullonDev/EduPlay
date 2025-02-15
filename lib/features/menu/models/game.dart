import 'package:flutter/material.dart';

class Game {
  final String title;
  final Color color;
  final VoidCallback onTap;

  Game({
    required this.title,
    required this.color,
    required this.onTap,
  });
}
