// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFE53935);
const _kGold = Color(0xFFFFD700);

class StudentMissionBanner extends StatelessWidget {
  const StudentMissionBanner({
    super.key,
    required this.mission,
    required this.onPlay,
    required this.s,
  });
  final Map<String, dynamic>? mission;
  final VoidCallback onPlay;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final title =
        mission?['title'] as String? ?? '¡Tu próxima misión te espera!';
    final hasReal = mission != null;

    // Mobile: no mascot, slightly shorter
    // Tablet / Desktop: mascot on the right
    final showMascot = !s.isMobile;

    return Container(
      constraints: BoxConstraints(
        minHeight: s.when(mobile: 200, tablet: 185, desktop: 195),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1060), Color(0xFF2D2A82), Color(0xFF3D3AA0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: _Circle(size: s.isMobile ? 130 : 180, opacity: 0.06),
          ),
          const Positioned(
            bottom: -20,
            left: 80,
            child: _Circle(size: 100, opacity: 0.05),
          ),

          // Gold sparkles
          const Positioned(
              top: 24, left: 160, child: _Star(size: 8, opacity: 0.6)),
          const Positioned(
              top: 44, left: 200, child: _Star(size: 5, opacity: 0.4)),
          const Positioned(
              top: 80, left: 140, child: _Star(size: 6, opacity: 0.5)),

          // Mascot (tablet / desktop only)
          if (showMascot)
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              width: s.isDesktop ? 160 : 130,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF2D2A82).withValues(alpha: 0.0),
                      const Color(0xFF3D6090).withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '🦊',
                    style: TextStyle(
                      fontSize: s.isDesktop ? 72 : 56,
                    ),
                  ),
                ),
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.all(s.isMobile ? 18 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MISIÓN DEL DÍA',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5A3E00),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: showMascot
                        ? (s.isDesktop ? 240 : 200)
                        : double.infinity,
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: s.when(mobile: 18, tablet: 20, desktop: 22),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                if (!s.isMobile)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: showMascot ? 210 : double.infinity,
                    ),
                    child: Text(
                      hasReal
                          ? 'Tu profesor te asignó este reto. ¡Gana una estampa legendaria!'
                          : 'Completa 3 retos hoy y gana una estampa legendaria.',
                      maxLines: 2,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                ElevatedButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text(
                    '¡Jugar Ahora!',
                    style: GoogleFonts.fredoka(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

class _Star extends StatelessWidget {
  const _Star({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _kGold.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: _kGold.withValues(alpha: opacity * 0.5),
              blurRadius: size,
              spreadRadius: 1,
            ),
          ],
        ),
      );
}

// ── Stat cards ────────────────────────────────────────────────────────────────

class StudentStatCardsRow extends StatelessWidget {
  const StudentStatCardsRow({
    super.key,
    required this.streak,
    required this.level,
    required this.xpIntoLevel,
    required this.xpProgress,
    required this.activeChallenges,
    required this.s,
    this.streakAtRisk = false,
  });
  final int streak;
  final int level;
  final int xpIntoLevel;
  final double xpProgress;
  final int activeChallenges;
  final ScreenSize s;

  /// True once the streak has gone 2+ days without play — rendered gray
  /// ("paused") instead of the usual fiery orange until it's either
  /// recovered or a fresh streak starts.
  final bool streakAtRisk;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: Icons.local_fire_department_rounded,
        iconColor: streakAtRisk ? Colors.grey[400]! : const Color(0xFFFF7043),
        bgColor: streakAtRisk ? Colors.grey[100]! : const Color(0xFFFFF3F0),
        title: 'Racha Actual',
        value: streakAtRisk
            ? 'Racha en pausa'
            : '$streak ${streak == 1 ? 'día' : 'días'} seguidos',
        child: null,
      ),
      _StatCard(
        icon: Icons.military_tech_rounded,
        iconColor: const Color(0xFFFF8F00),
        bgColor: const Color(0xFFFFFBE6),
        title: 'Próximo Nivel',
        value: '$xpIntoLevel / 100 XP',
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 6,
              backgroundColor: const Color(0xFFFF8F00).withValues(alpha: 0.12),
              color: const Color(0xFFFF8F00),
            ),
          ),
        ),
      ),
      _StatCard(
        icon: Icons.groups_rounded,
        iconColor: const Color(0xFF5C6BC0),
        bgColor: const Color(0xFFECEFF8),
        title: 'Retos de Clase',
        value:
            '$activeChallenges ${activeChallenges == 1 ? 'reto activo' : 'retos activos'}',
        child: null,
      ),
    ];

    // Always 3-column on tablet and desktop; single column on small mobile
    if (s.isMobile && s.isXs) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            cards[i],
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.value,
    required this.child,
  });
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                if (child != null) child!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mis Juegos section ────────────────────────────────────────────────────────
