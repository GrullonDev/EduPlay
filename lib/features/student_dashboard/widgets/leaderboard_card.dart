import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';

/// "Top de la Clase" leaderboard card. Highlights the current student's row.
class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({
    super.key,
    required this.entries,
    required this.myStudentId,
  });

  /// Students ordered by points, descending (already limited upstream).
  final List<Map<String, dynamic>> entries;
  final String myStudentId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC107)),
              const SizedBox(width: 10),
              Text(
                'Top de la Clase',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aún no hay puntajes registrados. ¡Sé el primero!',
                style: GoogleFonts.nunito(color: Colors.grey[600]),
              ),
            )
          else
            for (var i = 0; i < entries.length; i++)
              _LeaderboardRow(
                rank: i + 1,
                name: entries[i]['name'] as String? ?? 'Explorador',
                points: (entries[i]['points'] as num?)?.toInt() ?? 0,
                isMe: entries[i]['id'] == myStudentId,
              ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.points,
    required this.isMe,
  });

  final int rank;
  final String name;
  final int points;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final medalColors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isMe
            ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: medalColors[rank] ?? Colors.grey[200],
            child: Text(
              '$rank',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: rank <= 3 ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? '$name (Tú)' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
          Text(
            '$points pts',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
