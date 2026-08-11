import 'package:edu_play/features/parents_dashboard/domain/repositories/parent_dashboard_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/parent_challenge.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);

class ParentChallengesCard extends StatefulWidget {
  const ParentChallengesCard({super.key});

  @override
  State<ParentChallengesCard> createState() => _ParentChallengesCardState();
}

class _ParentChallengesCardState extends State<ParentChallengesCard> {
  final ParentDashboardRepository _repository = sl<ParentDashboardRepository>();

  List<ParentChallenge> _challenges = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final challenges = await _repository.getChallenges();
      if (mounted) {
        setState(() {
          _challenges = challenges;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _challenges.length;

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
          Row(
            children: [
              Text(
                'Próximos Desafíos',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const Spacer(),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDF8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pendingCount ${pendingCount == 1 ? 'Tarea Pendiente' : 'Tareas Pendientes'}',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _kNavy,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (!_loaded)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_challenges.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 40,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay retos asignados',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Los desafíos de maestros aparecerán aquí.',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            for (final c in _challenges) ...[
              _ChallengeTile(
                icon: _iconForSubject(c.subject),
                title: c.title,
                subtitle: c.displaySubtitle,
                tag: c.tag,
                tagColor: _colorForTag(c.tag),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ],
        ],
      ),
    );
  }

  IconData _iconForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'matemáticas':
        return Icons.calculate_rounded;
      case 'science':
      case 'ciencias':
        return Icons.eco_rounded;
      case 'english':
      case 'inglés':
        return Icons.translate_rounded;
      case 'history':
      case 'historia':
        return Icons.history_edu_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _colorForTag(String tag) {
    switch (tag.toLowerCase()) {
      case 'urgente':
        return const Color(0xFFC0392B);
      case 'recomendado':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: _kNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            tag,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: tagColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[300]),
        ],
      ),
    );
  }
}

// ── Empty state when no children ──────────────────────────────────────────────
