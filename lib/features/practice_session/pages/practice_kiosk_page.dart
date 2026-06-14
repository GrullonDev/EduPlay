import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/math_adventure/pages/math_adventure_page.dart';
import 'package:edu_play/features/magic_words/pages/magic_words_page.dart';
import 'package:edu_play/features/fun_english/pages/fun_english_page.dart';
import 'package:edu_play/features/nature_explorers/pages/nature_explorers_page.dart';
import 'package:edu_play/features/time_travel/pages/time_travel_page.dart';
import 'package:edu_play/features/treasure_map/pages/treasure_map_page.dart';
import 'package:edu_play/features/artists_in_action/pages/artists_in_action_page.dart';
import 'package:edu_play/features/color_concert/pages/color_concert_page.dart';
import 'package:edu_play/features/sports_challenge/pages/sports_challenge_page.dart';
import 'package:edu_play/features/sticker_album/pages/sticker_album_page.dart';

import 'package:edu_play/features/practice_session/models/game_info.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);

// ─────────────────────────────────────────────────────────────────────────────

/// Soft-lock kiosk screen the child sees during a practice session.
///
/// No EduPlayNavBar. No external navigation. Child can only play the
/// games the parent assigned. Browser address bar is still accessible
/// (web-level lock is out of scope), but the app itself has no escape.
class PracticeKioskPage extends StatefulWidget {
  const PracticeKioskPage({super.key, required this.session});

  final PracticeSession session;

  @override
  State<PracticeKioskPage> createState() => _PracticeKioskPageState();
}

class _PracticeKioskPageState extends State<PracticeKioskPage> {
  late PracticeSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  Future<void> _refresh() async {
    // Re-read the session from storage in case another instance updated it
    final sessions = await PracticeSessionsService.getAllSessions();
    final updated = sessions.where((s) => s.id == _session.id).toList();
    if (updated.isNotEmpty && mounted) {
      setState(() => _session = updated.first);
    }
  }

  Future<void> _playGame(GameInfo game) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PracticeGameWrapper(
          game: game,
          session: _session,
        ),
      ),
    );
    // When we return, refresh so progress reflects completion
    await _refresh();
  }

  bool _isCompleted(String gameId) =>
      _session.completedGameIds.contains(gameId);

  @override
  Widget build(BuildContext context) {
    if (_session.isCompleted) {
      return _CompletionScreen(session: _session);
    }

    final wide = MediaQuery.of(context).size.width >= 900;
    final games = _session.assignedGameIds
        .map((id) => gameById(id))
        .whereType<GameInfo>()
        .toList();

    return PopScope(
      // Prevent the child from using the Android/browser back button to escape
      canPop: false,
      child: Scaffold(
        backgroundColor: _kBg,
        body: Column(
          children: [
            _TopBar(session: _session),
            _ProgressBanner(session: _session),
            Expanded(
              child: games.isEmpty
                  ? _noGamesFound()
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 48 : 20,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Games',
                                style: GoogleFonts.fredoka(
                                  fontSize: 22,
                                  color: _kNavy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Complete all games to finish your session!',
                                style: GoogleFonts.nunito(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: wide ? 260 : 180,
                                  mainAxisExtent: 160,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: games.length,
                                itemBuilder: (_, i) => _KioskGameCard(
                                  game: games[i],
                                  completed: _isCompleted(games[i].id),
                                  score: _session.scoreMap[games[i].id],
                                  onPlay: () => _playGame(games[i]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noGamesFound() => Center(
        child: Text(
          'No games found for this session.',
          style: GoogleFonts.nunito(color: Colors.grey),
        ),
      );
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text('EduPlay',
              style: GoogleFonts.fredoka(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _kCoral.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Practice Mode',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              session.childName.isNotEmpty
                  ? session.childName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            session.childName,
            style: GoogleFonts.nunito(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Progress banner ───────────────────────────────────────────────────────────

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final pct = session.progressFraction;
    return Container(
      color: const Color(0xFF2A2770),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${session.completedCount} of ${session.totalCount} games completed',
                      style: GoogleFonts.nunito(
                          color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${(pct * 100).round()}%',
                      style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kCoral),
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

// ── Kiosk game card ───────────────────────────────────────────────────────────

class _KioskGameCard extends StatelessWidget {
  const _KioskGameCard({
    required this.game,
    required this.completed,
    required this.onPlay,
    this.score,
  });

  final GameInfo game;
  final bool completed;
  final VoidCallback onPlay;
  final int? score;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: completed ? null : onPlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: completed ? game.color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                completed ? const Color(0xFF27AE60) : const Color(0xFFE8E8F0),
            width: completed ? 2 : 1,
          ),
          boxShadow: completed
              ? []
              : [
                  BoxShadow(
                    color: game.color.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: game.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(game.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const Spacer(),
                  if (completed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 11, color: Color(0xFF27AE60)),
                          const SizedBox(width: 3),
                          Text('Done',
                              style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF27AE60))),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                game.name,
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  color: _kNavy,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (completed && score != null)
                Text(
                  'Score: $score',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: const Color(0xFF27AE60),
                      fontWeight: FontWeight.w700),
                )
              else if (!completed)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: game.color,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Play',
                      style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Game Wrapper ──────────────────────────────────────────────────────────────

/// Wraps any game page in a thin kiosk overlay so the child can tap
/// "Finish Game" to record completion and return to the kiosk.
class _PracticeGameWrapper extends StatefulWidget {
  const _PracticeGameWrapper({
    required this.game,
    required this.session,
  });

  final GameInfo game;
  final PracticeSession session;

  @override
  State<_PracticeGameWrapper> createState() => _PracticeGameWrapperState();
}

class _PracticeGameWrapperState extends State<_PracticeGameWrapper> {
  bool _finishing = false;
  int _currentScore = 0;

  // Stopwatch records time-on-task for games that don't have
  // their own score callback yet. Score = seconds × 2, capped at 300.
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  int get _timeBasedScore => (_stopwatch.elapsed.inSeconds * 2).clamp(0, 300);

  Future<void> _finishGame() async {
    _stopwatch.stop();
    setState(() => _finishing = true);
    final score = _currentScore > 0 ? _currentScore : _timeBasedScore;
    await PracticeSessionsService.recordGameCompletion(
      widget.session.id,
      widget.game.id,
      score: score,
    );
    if (mounted) Navigator.pop(context);
  }

  Widget _buildGameWidget() {
    switch (widget.game.id) {
      case 'math-adventure':
        return MathAdventurePage(
          userName: null,
          onScoreUpdate: (s) => setState(() => _currentScore = s),
        );
      case 'magic-words':
        return MagicWordsPage(
          onScoreUpdate: (s) => setState(() => _currentScore = s),
        );
      case 'fun-english':
        return const FunEnglishPage();
      case 'nature-explorers':
        return const NatureExplorersPage();
      case 'time-travel':
        return const TimeTravelPage();
      case 'treasure-map':
        return const TreasureMapPage();
      case 'artists-in-action':
        return const ArtistsInActionPage();
      case 'color-concert':
        return const ColorConcertPage();
      case 'sports-challenge':
        return const SportsChallengePage();
      case 'sticker-album':
        return const StickerAlbumPage();
      default:
        return Center(
          child: Text(
            'Game not found: ${widget.game.id}',
            style: GoogleFonts.nunito(color: Colors.red),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The actual game
          Positioned.fill(child: _buildGameWidget()),

          // Kiosk overlay bar pinned to top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _KioskBar(
              gameName: widget.game.name,
              childName: widget.session.childName,
              onFinish: _finishing ? null : _finishGame,
              finishing: _finishing,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kiosk bar (game wrapper) ──────────────────────────────────────────────────

class _KioskBar extends StatelessWidget {
  const _KioskBar({
    required this.gameName,
    required this.childName,
    required this.onFinish,
    required this.finishing,
  });

  final String gameName;
  final String childName;
  final VoidCallback? onFinish;
  final bool finishing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kNavy,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(gameName,
                      style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text('Practice mode • $childName',
                      style: GoogleFonts.nunito(
                          color: Colors.white60, fontSize: 11)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onFinish,
                icon: finishing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, size: 16),
                label: Text('Finish Game',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Completion screen ─────────────────────────────────────────────────────────

class _CompletionScreen extends StatelessWidget {
  const _CompletionScreen({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final totalScore =
        session.scoreMap.values.fold<int>(0, (sum, s) => sum + s);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kNavyDark, Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration
                  const Text('🎉', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  Text(
                    'Great job, ${session.childName}!',
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You completed all ${session.totalCount} games!',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Score card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Session Summary',
                          style: GoogleFonts.fredoka(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatPill(
                              emoji: '⭐',
                              label: 'Total Score',
                              value: '$totalScore',
                            ),
                            _StatPill(
                              emoji: '🎮',
                              label: 'Games',
                              value: '${session.totalCount}',
                            ),
                            _StatPill(
                              emoji: '✅',
                              label: 'Completed',
                              value: '${session.completedCount}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Per-game breakdown
                        ...session.assignedGameIds.map((gameId) {
                          final info = gameById(gameId);
                          final score = session.scoreMap[gameId] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Text(info?.emoji ?? '🎮',
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  info?.name ?? gameId,
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text('$score pts',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white60, fontSize: 13)),
                            ]),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'Ask your parent to see your progress report!',
                    style:
                        GoogleFonts.nunito(color: Colors.white60, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // "Done" button — exits to main app
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kCoral,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'All Done! 🎉',
                      style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.nunito(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}
