// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);

/// Shown from the "Ayuda" sidebar item. A short, static FAQ — there's no
/// backing help-center service, so this is real content rather than a
/// "coming soon" placeholder.
void showTeacherHelpSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _TeacherHelpSheet(),
  );
}

class _TeacherHelpSheet extends StatelessWidget {
  const _TeacherHelpSheet();

  static const _faqs = [
    (
      icon: Icons.groups_rounded,
      question: '¿Cómo creo o me uno a una clase?',
      answer:
          'En "Mis Clases" puedes crear una clase nueva o unirte a una existente con un código de invitación.',
    ),
    (
      icon: Icons.emoji_events_rounded,
      question: '¿Cómo asigno un reto a mis alumnos?',
      answer:
          'Usa "Asignar Reto Rápido" en el Panel Principal, o entra a la pestaña "Retos" para crear uno con más detalle.',
    ),
    (
      icon: Icons.bar_chart_rounded,
      question: '¿Cómo veo el progreso de un alumno?',
      answer:
          'En "Alumnos" o "Rendimiento" puedes ver el avance individual, la actividad reciente y las materias donde necesitan apoyo.',
    ),
    (
      icon: Icons.description_rounded,
      question: '¿Cómo exporto los datos de mi clase?',
      answer:
          'En "Informes" toca "Exportar Todo" para copiar clases, alumnos y retos en formato CSV, listo para pegar en Excel o Google Sheets.',
    ),
    (
      icon: Icons.support_agent_rounded,
      question: 'Algo no funciona, ¿qué hago?',
      answer:
          'Revisa tu conexión e intenta actualizar el panel. Si el problema continúa, contacta al soporte de tu institución.',
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
