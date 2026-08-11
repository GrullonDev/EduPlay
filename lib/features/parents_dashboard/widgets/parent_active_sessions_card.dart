import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);

class ParentActiveSessionsCard extends StatelessWidget {
  const ParentActiveSessionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PracticeSession>>(
      stream: PracticeSessionsService.watchActiveSessions(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final sessions = snapshot.data ?? [];

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
                    Icons.play_circle_outline_rounded,
                    size: 16,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Sessions',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (!isLoading)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF27AE60),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (isLoading)
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
                Column(
                  children: [
                    const Text('🎮', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      'No active sessions',
                      style: GoogleFonts.nunito(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(RouterPaths.createSession),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _kCoral),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Start Session',
                          style: GoogleFonts.nunito(
                            color: _kCoral,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                ...sessions.map(
                  (s) => _SessionRow(
                    session: s,
                    onEnd: () => PracticeSessionsService.endSession(s.id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.onEnd});

  final PracticeSession session;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.childName,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF27AE60),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'PIN: ${session.pin}  •  ${session.totalCount} games',
            style: GoogleFonts.nunito(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: session.progressFraction,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(_kCoral),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${session.completedCount}/${session.totalCount} done',
                style: GoogleFonts.nunito(color: Colors.white38, fontSize: 10),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final url =
                      'https://app.eduplay.com/practice-session?pin=${session.pin}';
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Enlace copiado al portapapeles',
                        style: GoogleFonts.nunito(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF1E1B6A),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.share_rounded,
                      size: 12,
                      color: Color(0xFF27AE60),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Compartir',
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF27AE60),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onEnd,
                child: Text(
                  'Finalizar',
                  style: GoogleFonts.nunito(
                    color: _kCoral,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
