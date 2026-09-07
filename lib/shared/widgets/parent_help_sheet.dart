// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFE53935);

/// Shown from "Soporte" links across the parent-facing pages. A short,
/// static FAQ — there's no backing help-center service, so this is real
/// content rather than a "coming soon" placeholder.
void showParentHelpSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ParentHelpSheet(),
  );
}

class _ParentHelpSheet extends StatelessWidget {
  const _ParentHelpSheet();

  static const _faqs = [
    (
      icon: Icons.child_care_rounded,
      question: '¿Cómo agrego o edito el perfil de mi hijo?',
      answer:
          'En tu panel principal, ve a "Mis Exploradores" para crear un nuevo perfil o editar uno existente.',
    ),
    (
      icon: Icons.bar_chart_rounded,
      question: '¿Cómo veo el progreso de mi hijo?',
      answer:
          'Selecciona el perfil de tu hijo desde el panel para ver su racha, nivel, materias practicadas y logros recientes.',
    ),
    (
      icon: Icons.workspace_premium_rounded,
      question: '¿Cómo funciona la suscripción PRO?',
      answer:
          'En Configuración → Suscripción puedes ver tu plan actual, mejorarlo o cancelarlo cuando quieras.',
    ),
    (
      icon: Icons.shield_rounded,
      question: '¿Cómo elimino mi cuenta o mis datos?',
      answer:
          'En Configuración → Seguridad encontrarás la opción para solicitar la eliminación de tu cuenta y tus datos.',
    ),
    (
      icon: Icons.support_agent_rounded,
      question: 'Mi problema no está aquí, ¿qué hago?',
      answer:
          'Revisa tu conexión e intenta de nuevo. Si el problema continúa, contáctanos desde la tienda de aplicaciones donde descargaste EduPlay.',
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
