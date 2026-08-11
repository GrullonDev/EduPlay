import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/parent_child_stats_service.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);

class ParentAchievementCard extends StatelessWidget {
  const ParentAchievementCard({
    super.key,
    required this.profiles,
    required this.stats,
  });
  final List<ChildProfile> profiles;
  final Map<String, ChildGameplayStats> stats;

  /// Derive achievement title + description from real gameplay data
  /// (`students/{id}` points/scores), not kiosk sessions.
  ({String title, String description, String achiever}) get _achievement {
    final total = stats.values.fold<int>(
      0,
      (runningTotal, s) => runningTotal + s.gamesPlayedCount,
    );

    if (profiles.isEmpty || total == 0) {
      return (
        title: 'Sin logros aún',
        description:
            'Los logros aparecerán cuando tu hijo juegue y gane puntos.',
        achiever: 'Tu hijo',
      );
    }

    // Child with the most games played recently is the achiever.
    var achiever = profiles.first.name;
    var bestCount = -1;
    for (final p in profiles) {
      final count = stats[p.id]?.gamesPlayedCount ?? 0;
      if (count > bestCount) {
        bestCount = count;
        achiever = p.name;
      }
    }

    if (total >= 10) {
      return (
        title: '¡Explorador Galáctico!',
        description:
            '$achiever completó $total juegos en total. ¡Impresionante!',
        achiever: achiever,
      );
    } else if (total >= 5) {
      return (
        title: '¡Aprendiz Estelar!',
        description: '$achiever completó $total juegos. ¡Va por buen camino!',
        achiever: achiever,
      );
    } else {
      return (
        title: '¡Primer Logro!',
        description: '$achiever completó su primer juego. ¡Felicitaciones!',
        achiever: achiever,
      );
    }
  }

  void _sendCongrats(BuildContext context, String achiever) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enviar Felicitación',
          style: GoogleFonts.fredoka(fontSize: 18, color: _kNavy),
        ),
        content: Text(
          '¡Comparte el logro de $achiever con tu familia! 🎉\n\n"$achiever ha conseguido un nuevo logro en EduPlay. ¡Sigue aprendiendo!"',
          style: GoogleFonts.nunito(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cerrar',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Clipboard copy for easy sharing
              Clipboard.setData(
                ClipboardData(
                  text:
                      '¡$achiever ha conseguido un nuevo logro en EduPlay! 🎉 #EduPlay',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Mensaje copiado al portapapeles',
                    style: GoogleFonts.nunito(),
                  ),
                  backgroundColor: _kNavy,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Copiar mensaje',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = _achievement;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Último Logro',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF3CD),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.military_tech_rounded,
                      size: 38,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  a.title,
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  a.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: profiles.isEmpty
                      ? null
                      : () => _sendCongrats(context, a.achiever),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Enviar Felicitación',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
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

// ── Challenges card ───────────────────────────────────────────────────────────
