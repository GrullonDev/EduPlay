import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/responsive.dart';

const kLegalNavy = Color(0xFF1E1B6A);
const kLegalCoral = Color(0xFFFF6E6C);
const kLegalBg = Color(0xFFF8F7FF);

// ── Data model ────────────────────────────────────────────────────────────────

class LegalSection {
  const LegalSection({required this.title, required this.body});
  final String title;
  final String body;
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared scaffold used by both legal pages
// ─────────────────────────────────────────────────────────────────────────────

class LegalScaffold extends StatelessWidget {
  const LegalScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.sections,
    required this.lastUpdated,
    required this.intro,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<LegalSection> sections;
  final String lastUpdated;
  final String intro;

  @override
  Widget build(BuildContext context) {
    final s = ScreenSize.of(context);
    final hPad = s.when(mobile: 20.0, tablet: 40.0, desktop: 0.0);

    return Scaffold(
      backgroundColor: kLegalBg,
      appBar: AppBar(
        backgroundColor: kLegalNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 48),
            children: [
              LegalHeroCard(
                title: title,
                intro: intro,
                icon: icon,
                iconColor: iconColor,
                lastUpdated: lastUpdated,
              ),
              const SizedBox(height: 24),
              for (final section in sections) ...[
                LegalSectionCard(section: section),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 8),
              const LegalFooterNote(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class LegalHeroCard extends StatelessWidget {
  const LegalHeroCard({
    super.key,
    required this.title,
    required this.intro,
    required this.icon,
    required this.iconColor,
    required this.lastUpdated,
  });

  final String title;
  final String intro;
  final IconData icon;
  final Color iconColor;
  final String lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kLegalNavy, Color(0xFF2D2A82)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kLegalNavy.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            intro,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Última actualización: $lastUpdated',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class LegalSectionCard extends StatelessWidget {
  const LegalSectionCard({super.key, required this.section});
  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: kLegalCoral,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kLegalNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.body,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF444466),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer note ───────────────────────────────────────────────────────────────

class LegalFooterNote extends StatelessWidget {
  const LegalFooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: Color(0xFF5C6BC0)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Este documento es un texto de muestra con fines ilustrativos y '
              'deberá ser revisado por un equipo legal antes de su publicación oficial.',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: const Color(0xFF5C6BC0),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
