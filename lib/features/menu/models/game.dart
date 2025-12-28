import 'package:flutter/material.dart';

class Game {
  final String title;
  final Color color;
  final VoidCallback onTap;

  final IconData icon;
  final bool isDailyChallenge;

  Game({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
    this.isDailyChallenge = false,
  });
}
