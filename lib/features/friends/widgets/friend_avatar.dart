import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _avatarColors = [
  Color(0xFF43A047),
  Color(0xFF1E88E5),
  Color(0xFFE53935),
  Color(0xFF8E24AA),
  Color(0xFFF4511E),
  Color(0xFF00897B),
];

Color colorForName(String name) =>
    _avatarColors[name.isEmpty ? 0 : name.codeUnitAt(0) % _avatarColors.length];

class FriendAvatar extends StatelessWidget {
  const FriendAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorForName(name),
      child: Text(
        initial,
        style: GoogleFonts.fredoka(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

String roleLabel(String role) {
  switch (role) {
    case 'student':
      return 'Estudiante';
    case 'teacher':
      return 'Profesor(a)';
    default:
      return 'Padre/Madre';
  }
}
