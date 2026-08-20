// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/student_dashboard/pages/student_dashboard_page.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);

class _PendingChallenge {
  const _PendingChallenge(this.child, this.challenge);
  final ChildProfile child;
  final ClassroomChallenge challenge;
}

class ParentChallengesCard extends StatefulWidget {
  const ParentChallengesCard({super.key, required this.profiles});

  final List<ChildProfile> profiles;

  @override
  State<ParentChallengesCard> createState() => _ParentChallengesCardState();
}

class _ParentChallengesCardState extends State<ParentChallengesCard> {
  final ClassroomChallengesRepository _repository =
      sl<ClassroomChallengesRepository>();

  List<_PendingChallenge> _pending = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ParentChallengesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profiles != widget.profiles) _load();
  }

  Future<void> _load() async {
    try {
      final entries = <_PendingChallenge>[];
      for (final child in widget.profiles) {
        final challenges = await _repository.getChallengesForStudent(child.id);
        entries.addAll(
          challenges
              .where((c) => !c.completed)
              .map((c) => _PendingChallenge(child, c)),
        );
      }
      entries.sort(
        (a, b) => b.challenge.createdAt.compareTo(a.challenge.createdAt),
      );
      if (mounted) {
        setState(() {
          _pending = entries;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  void _openChallenge(ChildProfile child) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentDashboardPage(
          username: child.name,
          childProfile: child,
          initialTab: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _pending.length;

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
          else if (_pending.isEmpty)
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
            for (final entry in _pending) ...[
              _ChallengeTile(
                entry: entry,
                onTap: () => _openChallenge(entry.child),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ],
        ],
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.entry, required this.onTap});

  final _PendingChallenge entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final challenge = entry.challenge;
    final subject = subjectByKey(challenge.subjectKey);
    final (tag, tagColor) = _dueTag(challenge.dueDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
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
              child: Icon(
                subject.icon,
                size: 20,
                color: _kNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                  Text(
                    '${entry.child.name} · ${challenge.className}',
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
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  (String, Color) _dueTag(String? dueDateIso) {
    if (dueDateIso == null || dueDateIso.isEmpty) {
      return ('Pendiente', const Color(0xFF95A5A6));
    }
    final due = DateTime.tryParse(dueDateIso);
    if (due == null) return ('Pendiente', const Color(0xFF95A5A6));

    final today = DateTime.now();
    final daysLeft =
        due.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (daysLeft < 0) return ('Vencido', const Color(0xFFC0392B));
    if (daysLeft <= 2) return ('Urgente', const Color(0xFFC0392B));
    return ('Pendiente', const Color(0xFF95A5A6));
  }
}
