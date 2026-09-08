// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFE53935);

/// Shown from the "Ayuda" footer tile in the student side nav. A short,
/// static FAQ — there's no backing help-center service, so this is real
/// content rather than a "coming soon" placeholder.
void showStudentHelpSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _StudentHelpSheet(),
  );
}

class _StudentHelpSheet extends StatelessWidget {
  const _StudentHelpSheet();

  static const _faqs = [
    (
      icon: Icons.sports_esports_rounded,
      question: '¿Cómo juego un juego?',
      answer:
          'Toca el botón "Jugar" en cualquier tarjeta de juego, en el inicio o en el catálogo de juegos.',
    ),
    (
      icon: Icons.group_add_rounded,
      question: '¿Cómo agrego amigos?',
      answer:
          'En "Amigos en Línea" toca "Añadir" e ingresa su código de amigo. Necesitas haber entrado con tu PIN.',
    ),
    (
      icon: Icons.emoji_events_rounded,
      question: '¿Cómo gano estampas y subo de nivel?',
      answer:
          'Completa retos y juega tus juegos favoritos: cada partida te da puntos de experiencia (XP) para subir de nivel y desbloquear estampas.',
    ),
    (
      icon: Icons.flag_rounded,
      question: '¿Qué es "Mis Retos"?',
      answer:
          'Son misiones que tu profesor te asigna desde su panel. Márcalas como completadas cuando termines.',
    ),
    (
      icon: Icons.family_restroom_rounded,
      question: 'Algo no funciona, ¿qué hago?',
      answer:
          'Pídele a mamá, papá o tu profesor que revisen tu cuenta. Ellos pueden ayudarte desde el panel de padres o de profesores.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.help_rounded, color: _kCoral, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Centro de Ayuda',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemCount: _faqs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final faq = _faqs[i];
                  return _FaqTile(
                    icon: faq.icon,
                    question: faq.question,
                    answer: faq.answer,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.icon,
    required this.question,
    required this.answer,
  });
  final IconData icon;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.fromLTRB(48, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Icon(icon, color: _kNavy, size: 20),
        title: Text(
          question,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
        children: [
          Text(
            answer,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
