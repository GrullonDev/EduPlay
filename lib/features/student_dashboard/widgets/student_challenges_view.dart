import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFE53935);
const _kGreen = Color(0xFF2E7D32);

class StudentChallengesView extends StatelessWidget {
  const StudentChallengesView({super.key, required this.s});
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StudentDashboardBloc>();
    final active =
        bloc.challenges.where((c) => c['status'] == 'active').toList();
    final completed =
        bloc.challenges.where((c) => c['status'] == 'completed').toList();

    return RefreshIndicator(
      color: _kNavy,
      onRefresh: bloc.refresh,
      child: CustomScrollView(
        slivers: [
          SizedBox(height: s.isMobile ? 12 : 24),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1060),
                    Color(0xFF2D2A82),
                    Color(0xFF3D3AA0)
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      s.isMobile ? 20 : 28, 20, s.isMobile ? 20 : 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 Mis Retos',
                        style: GoogleFonts.fredoka(
                          fontSize: s.isMobile ? 22 : 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        active.isEmpty
                            ? 'Tu profesor aún no te ha asignado retos.'
                            : '${active.length} ${active.length == 1 ? 'reto activo' : 'retos activos'} · ${completed.length} completado${completed.length == 1 ? '' : 's'}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
                s.isMobile ? 16 : 24, 20, s.isMobile ? 16 : 24, 32),
            sliver: SliverToBoxAdapter(
              child: bloc.challenges.isEmpty
                  ? const _EmptyChallenges()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (active.isNotEmpty) ...[
                          const _SectionLabel('Por hacer'),
                          const SizedBox(height: 10),
                          for (final c in active)
                            _ChallengeCard(
                              challenge: c,
                              onComplete: bloc.completeChallenge,
                            ),
                          const SizedBox(height: 20),
                        ],
                        if (completed.isNotEmpty) ...[
                          const _SectionLabel('Completados'),
                          const SizedBox(height: 10),
                          for (final c in completed)
                            _ChallengeCard(
                              challenge: c,
                              onComplete: bloc.completeChallenge,
                            ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.fredoka(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _kNavy,
        ),
      );
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.onComplete});

  final Map<String, dynamic> challenge;
  final ValueChanged<String> onComplete;

  @override
  Widget build(BuildContext context) {
    final id = challenge['id'] as String;
    final title = challenge['title'] as String? ?? 'Reto';
    final className = challenge['class_name'] as String?;
    final dueDate = challenge['due_date'] as String?;
    final subjectKey = challenge['subject_key'] as String?;
    final subject = subjectKey != null ? subjectByKey(subjectKey) : null;
    final isCompleted = challenge['status'] == 'completed';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (subject?.color ?? _kCoral).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              subject?.icon ?? Icons.flag_rounded,
              color: subject?.color ?? _kCoral,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (className != null && className.isNotEmpty)
                      _Chip(icon: Icons.school_rounded, label: className),
                    if (dueDate != null && dueDate.isNotEmpty)
                      _Chip(
                        icon: Icons.event_rounded,
                        label: 'Antes del ${_formatDate(dueDate)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCompleted)
            const Icon(Icons.check_circle_rounded, color: _kGreen, size: 26)
          else
            OutlinedButton(
              onPressed: () => onComplete(id),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kNavy,
                side: BorderSide(color: Colors.grey.shade300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Completar',
                style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _kNavy.withValues(alpha: 0.6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kNavy.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChallenges extends StatelessWidget {
  const _EmptyChallenges();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 14),
          Text(
            'Aún no tienes retos',
            style: GoogleFonts.fredoka(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando tu profesor te asigne un reto para tu clase\naparecerá aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
