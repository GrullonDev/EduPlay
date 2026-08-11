import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);

class ParentSessionHistoryCard extends StatelessWidget {
  const ParentSessionHistoryCard({super.key});

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return DateFormat('d MMM', 'es').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PracticeSession>>(
      stream: PracticeSessionsService.watchCompletedSessions(),
      builder: (context, snapshot) {
        final sessions = (snapshot.data ?? []).take(5).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kNavyDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Historial de Sesiones',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
                  ),
                )
              else if (sessions.isEmpty)
                Text(
                  'Sin sesiones finalizadas aun.',
                  style: GoogleFonts.nunito(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                )
              else
                ...sessions.map((s) {
                  final total = s.scoreMap.values.fold(0, (a, b) => a + b);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.childName,
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${s.completedCount}/${s.totalCount} juegos - $total pts',
                                style: GoogleFonts.nunito(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _relativeDate(s.createdAt),
                          style: GoogleFonts.nunito(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              if (sessions.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(RouterPaths.progressReports),
                  child: Text(
                    'Ver informe completo ->',
                    style: GoogleFonts.nunito(
                      color: _kCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
