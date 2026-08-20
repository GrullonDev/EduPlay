// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';

const _kNavy = Color(0xFF1E1B6A);

class ParentRecommendationsCard extends StatefulWidget {
  const ParentRecommendationsCard({super.key, required this.profile});
  final ChildProfile profile;

  @override
  State<ParentRecommendationsCard> createState() =>
      ParentRecommendationsCardState();
}

class ParentRecommendationsCardState extends State<ParentRecommendationsCard> {
  late Future<List<GameRecommendation>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProgressRecommendationsService.getRecommendations(
      widget.profile.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameRecommendation>>(
      future: _future,
      builder: (context, snap) {
        final recs = snap.data ?? [];
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (recs.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      size: 18,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.profile.name} necesita practicar',
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        Text(
                          'Basado en las sesiones completadas',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recs.map((rec) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: rec.neverPlayed
                          ? const Color(0xFFEEEDF8)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: rec.neverPlayed
                            ? _kNavy.withValues(alpha: 0.15)
                            : const Color(0xFFFFCC80),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          rec.neverPlayed
                              ? Icons.play_circle_outline_rounded
                              : Icons.trending_up_rounded,
                          size: 14,
                          color: rec.neverPlayed
                              ? _kNavy
                              : const Color(0xFFE65100),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.gameName,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kNavy,
                              ),
                            ),
                            Text(
                              rec.reason,
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
