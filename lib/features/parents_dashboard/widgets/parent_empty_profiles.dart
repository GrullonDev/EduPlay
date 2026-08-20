// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);

class ParentEmptyProfiles extends StatelessWidget {
  const ParentEmptyProfiles({super.key, required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEEDF8),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.child_care_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no hay perfiles de niños',
            style: GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade un perfil para que tus hijos puedan\nacceder con su código PIN personal.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Crear primer perfil',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
