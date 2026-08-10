import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/utils/child_portal_link.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/services/parent_child_stats_service.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/features/subscription/services/subscription_service.dart';
import 'package:edu_play/features/onboarding/widgets/onboarding_wizard.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_active_sessions_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_challenges_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_quick_controls_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_session_history_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_weekly_summary_card.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);

// ── Entry point ───────────────────────────────────────────────────────────────

class ParentsDashboardPage extends StatefulWidget {
  const ParentsDashboardPage({super.key});

  @override
  State<ParentsDashboardPage> createState() => _ParentsDashboardPageState();
}

class _ParentsDashboardPageState extends State<ParentsDashboardPage> {
  final ChildProfilesRepository _childProfilesRepository =
      sl<ChildProfilesRepository>();

  List<ChildProfile> _profiles = [];
  String _parentName = 'Mamá';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    // Show onboarding wizard on first visit, after the frame builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) OnboardingWizard.showIfNeeded(context);
    });
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _childProfilesRepository.getProfiles(),
      _childProfilesRepository.getParentName(),
    ]);
    if (!mounted) return;
    setState(() {
      _profiles = results[0] as List<ChildProfile>;
      _parentName = results[1] as String;
      _loading = false;
    });
  }

  Future<void> _addProfile() async {
    // Navigate to the full Create Explorer wizard page
    await Navigator.of(context).pushNamed(RouterPaths.createExplorer);
    // Reload profiles after returning (wizard saves to SharedPreferences)
    _load();
  }

  Future<void> _deleteProfile(ChildProfile p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Eliminar perfil',
          style: GoogleFonts.fredoka(color: _kNavy, fontSize: 18),
        ),
        content: Text(
          '¿Eliminar el perfil de ${p.name}? Esta acción no se puede deshacer.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.nunito(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _childProfilesRepository.deleteProfile(p.id, pin: p.pin);
      if (mounted) setState(() => _profiles.removeWhere((x) => x.id == p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          EduPlayNavBar.parent(
            activeParentTab: ParentTab.inicio,
            parentName: _parentName,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _OverviewBody(
                    profiles: _profiles,
                    parentName: _parentName,
                    onAddProfile: _addProfile,
                    onDeleteProfile: _deleteProfile,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Overview body ─────────────────────────────────────────────────────────────

class _OverviewBody extends StatefulWidget {
  const _OverviewBody({
    required this.profiles,
    required this.parentName,
    required this.onAddProfile,
    required this.onDeleteProfile,
  });

  final List<ChildProfile> profiles;
  final String parentName;
  final VoidCallback onAddProfile;
  final ValueChanged<ChildProfile> onDeleteProfile;

  @override
  State<_OverviewBody> createState() => _OverviewBodyState();
}

class _OverviewBodyState extends State<_OverviewBody> {
  Map<String, ChildGameplayStats> _stats = {};
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ParentChildStatsService.loadStatsForProfiles(
      widget.profiles,
    );
    if (mounted) {
      setState(() {
        _stats = stats;
        _statsLoaded = true;
      });
    }
  }

  /// Real games played in the last 7 days across all children × 5 min
  /// estimate, sourced from `students/{id}/scores` (actual gameplay), not
  /// the parent-initiated kiosk sessions.
  int get _totalMinutes {
    if (!_statsLoaded || widget.profiles.isEmpty) return 0;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final gamesThisWeek = _stats.values.fold<int>(
      0,
      (total, stats) =>
          total +
          stats.recentScores.where((e) => e.date.isAfter(weekAgo)).length,
    );
    return gamesThisWeek * 5; // ~5 min per game
  }

  /// Subject with the most points scored this week across all children.
  /// Falls back to the first profile's static onboarding subject only when
  /// there's no real gameplay data yet.
  String get _topSubject {
    if (widget.profiles.isEmpty) return '—';
    if (!_statsLoaded) return widget.profiles.first.focusSubject;

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final totals = <String, int>{};
    for (final stats in _stats.values) {
      for (final entry in stats.recentScores) {
        if (entry.date.isBefore(weekAgo)) continue;
        totals[entry.subjectLabel] =
            (totals[entry.subjectLabel] ?? 0) + entry.score;
      }
    }
    if (totals.isEmpty) return widget.profiles.first.focusSubject;
    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final s = ScreenSize.of(context);
    final isDesktop = s.isDesktop;
    final firstName = widget.parentName.split(' ').first;

    Widget mainCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $firstName!',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Aquí tienes el resumen de hoy para tu familia.',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _TierBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              // Start Session button
              Builder(
                builder: (ctx) => ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(ctx).pushNamed(RouterPaths.createSession),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                  label: Text(
                    'Start Session',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: widget.onAddProfile,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Añadir Perfil',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Child profiles section
        const _SectionLabel(title: 'Perfiles de Niños', action: 'Ver todos'),
        const SizedBox(height: 14),
        widget.profiles.isEmpty
            ? _EmptyProfiles(onAdd: widget.onAddProfile)
            : _ChildProfilesGrid(
                profiles: widget.profiles,
                stats: _stats,
                onDelete: widget.onDeleteProfile,
              ),

        const SizedBox(height: 28),

        // Recommendations per child
        if (widget.profiles.isNotEmpty) ...[
          const _SectionLabel(title: 'Necesita practicar', action: ''),
          const SizedBox(height: 14),
          ...widget.profiles.map((p) => _RecommendationsCard(profile: p)),
          const SizedBox(height: 28),
        ],

        // Bottom row: Achievement + Challenges
        isDesktop
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _AchievementCard(
                        profiles: widget.profiles,
                        stats: _stats,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(flex: 6, child: ParentChallengesCard()),
                  ],
                ),
              )
            : Column(
                children: [
                  _AchievementCard(profiles: widget.profiles, stats: _stats),
                  const SizedBox(height: 20),
                  const ParentChallengesCard(),
                ],
              ),
        const SizedBox(height: 28),
      ],
    );

    Widget sideCol = Column(
      children: [
        const SizedBox(height: 24),
        ParentWeeklySummaryCard(
          totalMinutes: _totalMinutes,
          topSubject: _topSubject,
        ),
        const SizedBox(height: 16),
        const ParentQuickControlsCard(),
        const SizedBox(height: 16),
        const ParentActiveSessionsCard(),
        const SizedBox(height: 16),
        const ParentSessionHistoryCard(),
      ],
    );

    if (isDesktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: mainCol),
            const SizedBox(width: 24),
            SizedBox(width: 280, child: sideCol),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [mainCol, sideCol, const SizedBox(height: 20)]),
    );
  }
}

// ── Child profile grid ────────────────────────────────────────────────────────

class _ChildProfilesGrid extends StatelessWidget {
  const _ChildProfilesGrid({
    required this.profiles,
    required this.stats,
    required this.onDelete,
  });

  final List<ChildProfile> profiles;
  final Map<String, ChildGameplayStats> stats;
  final ValueChanged<ChildProfile> onDelete;

  @override
  Widget build(BuildContext context) {
    final cols =
        ScreenSize.of(context).isTablet || ScreenSize.of(context).isDesktop
            ? 2
            : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.6,
      ),
      itemCount: profiles.length,
      itemBuilder: (_, i) => _ChildCard(
        profile: profiles[i],
        stats: stats[profiles[i].id],
        onDelete: () => onDelete(profiles[i]),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.profile,
    required this.stats,
    required this.onDelete,
  });

  final ChildProfile profile;
  final ChildGameplayStats? stats;
  final VoidCallback onDelete;

  /// Live level/progress computed from real points when available, falling
  /// back to the profile's static onboarding seed while stats are loading.
  int get _level => stats?.level ?? profile.level;

  double get _levelProgress => stats?.levelProgress ?? profile.levelProgress;

  String get _levelLabel => 'Nivel ${_level.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: profile.avatarColor.withValues(alpha: 0.15),
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: profile.avatarColor,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _kNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _levelLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Online dot
              if (profile.isOnline)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDF8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        profile.focusSubject,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _kNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profile.isOnline
                      ? 'Jugando ahora'
                      : 'Última vez: ${profile.lastSeen}',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: profile.isOnline
                        ? const Color(0xFF2ECC71)
                        : Colors.grey[500],
                    fontWeight:
                        profile.isOnline ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progreso de Nivel',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                '${(_levelProgress * 100).toInt()}%',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _kNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _levelProgress,
                              minHeight: 5,
                              backgroundColor: const Color(0xFFF3F4F6),
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Actions column
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PIN chip
              GestureDetector(
                onTap: () => _showPinDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pin_rounded,
                        size: 12,
                        color: _kNavy.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PIN',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _kNavy.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _showActivityDetail(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kNavy,
                  side: BorderSide(color: Colors.grey.shade200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Detalle de Actividad',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (ReleaseFlags.teacherExperienceEnabled) ...[
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouterPaths.browseTeachers,
                    arguments: profile,
                  ),
                  icon: const Icon(Icons.person_search_rounded, size: 12),
                  label: Text(
                    'Asignar Maestro',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
          // Delete
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: Colors.grey[400],
            ),
            onPressed: () => _showOptions(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showActivityDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChildActivitySheet(profile: profile, stats: stats),
    );
  }

  void _showPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _PinRevealDialog(profile: profile),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pin_rounded, color: _kNavy),
              title: Text(
                'Ver PIN de acceso',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPinDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: Text(
                'Eliminar perfil',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action!,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kNavy.withValues(alpha: 0.5),
              decoration: TextDecoration.underline,
              decorationColor: _kNavy.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.profiles, required this.stats});
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

class _EmptyProfiles extends StatelessWidget {
  const _EmptyProfiles({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEEDF8),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.child_care_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no hay perfiles de niños',
            style: GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade un perfil para que tus hijos puedan\nacceder con su código PIN personal.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Crear primer perfil',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add profile dialog ────────────────────────────────────────────────────────

class _AddProfileDialog extends StatefulWidget {
  const _AddProfileDialog({required this.existingCount});
  final int existingCount;

  @override
  State<_AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends State<_AddProfileDialog> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _age = 8;
  String _subject = 'Matemáticas';
  bool _loading = false;

  static const _subjects = [
    'Matemáticas',
    'Ciencias',
    'Historia',
    'Idiomas',
    'Lógica',
    'Arte',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final profile = await sl<ChildProfilesRepository>().addProfile(
      name: _nameCtrl.text.trim(),
      age: _age,
      focusSubject: _subject,
      existingCount: widget.existingCount,
    );
    if (mounted) Navigator.pop(context, profile);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nuevo Perfil de Niño',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Se generará un PIN de acceso automáticamente.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                const _DialogLabel('Nombre del niño'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.nunito(fontSize: 14),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  decoration: _inputDec('Ej: María, Carlos…'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _DialogLabel('Edad'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _age,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: const Color(0xFF111827),
                            ),
                            decoration: _inputDec(''),
                            items: List.generate(12, (i) => i + 5)
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text('$a años'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _age = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _DialogLabel('Materia favorita'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _subject,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: const Color(0xFF111827),
                            ),
                            decoration: _inputDec(''),
                            items: _subjects
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _subject = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Crear perfil y generar PIN',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kNavy, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

class _DialogLabel extends StatelessWidget {
  const _DialogLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF374151),
        ),
      );
}

// ── PIN reveal dialog ─────────────────────────────────────────────────────────

class _PinRevealDialog extends StatelessWidget {
  const _PinRevealDialog({required this.profile});
  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profile.avatarColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    profile.name[0].toUpperCase(),
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: profile.avatarColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PIN de ${profile.name}',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comparte este código con ${profile.name}\npara que pueda acceder a su perfil.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // PIN display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDF8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: profile.pin.split('').map((digit) {
                    return Container(
                      width: 52,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          digit,
                          style: GoogleFonts.fredoka(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: _kNavy,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Copy PIN / Copy link row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: profile.pin));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'PIN copiado',
                            style: GoogleFonts.nunito(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _kNavy,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(
                      'Copiar PIN',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kNavy,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: childPortalUrl(profile)),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Enlace copiado',
                            style: GoogleFonts.nunito(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _kNavy,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link_rounded, size: 16),
                    label: Text(
                      'Copiar enlace',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kNavy,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
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

class _TierBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Subscription>(
      stream: SubscriptionService.watchSubscription(),
      builder: (context, snap) {
        final sub = snap.data;
        if (sub == null) return const SizedBox.shrink();
        final isPro = sub.isPro;
        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RouterPaths.settings),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isPro
                  ? const Color(0xFFF39C12).withValues(alpha: 0.15)
                  : _kNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPro
                    ? const Color(0xFFF39C12)
                    : _kNavy.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPro ? Icons.star_rounded : Icons.lock_outline_rounded,
                  size: 11,
                  color: isPro ? const Color(0xFFF39C12) : _kNavy,
                ),
                const SizedBox(width: 4),
                Text(
                  isPro ? 'PRO' : 'GRATIS',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isPro ? const Color(0xFFF39C12) : _kNavy,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Progress recommendations card ─────────────────────────────────────────────

class _RecommendationsCard extends StatefulWidget {
  const _RecommendationsCard({required this.profile});
  final ChildProfile profile;

  @override
  State<_RecommendationsCard> createState() => _RecommendationsCardState();
}

class _RecommendationsCardState extends State<_RecommendationsCard> {
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

// ── Child activity detail sheet ───────────────────────────────────────────────
//
// Shown when the parent taps "Detalle de Actividad" on a child card.
// Displays real-time session data pulled from Firestore.

class _ChildActivitySheet extends StatelessWidget {
  const _ChildActivitySheet({required this.profile, required this.stats});
  final ChildProfile profile;
  final ChildGameplayStats? stats;

  static const _kAmber = Color(0xFFD97706);

  int get _level => stats?.level ?? profile.level;

  double get _levelProgress => stats?.levelProgress ?? profile.levelProgress;

  String get _levelLabel => 'Nivel ${_level.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F7FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StreamBuilder<List<PracticeSession>>(
            stream: PracticeSessionsService.watchAllSessionsByChild(profile.id),
            builder: (context, snap) {
              final sessions = snap.data ?? [];
              final activeSessions = sessions.where((s) => s.isActive).toList();

              return ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.zero,
                children: [
                  // ── Handle + header ─────────────────────────────────
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_kNavy, Color(0xFF3A36A0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: profile.avatarColor.withValues(
                                alpha: 0.25,
                              ),
                              child: Text(
                                profile.name[0].toUpperCase(),
                                style: GoogleFonts.fredoka(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${profile.focusSubject}  ·  $_levelLabel',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Level progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso de Nivel',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${(_levelProgress * 100).toInt()}%',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _levelProgress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Stats grid ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RESUMEN',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: _kAmber,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ActivityStat(
                              icon: Icons.local_fire_department_rounded,
                              value: '${stats?.streak ?? 0}',
                              label: 'Racha\n(días)',
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 12),
                            _ActivityStat(
                              icon: Icons.sports_esports_rounded,
                              value: '${stats?.gamesPlayedCount ?? 0}',
                              label: 'Juegos\njugados',
                              color: const Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 12),
                            _ActivityStat(
                              icon: Icons.star_rounded,
                              value: (stats?.gamesPlayedCount ?? 0) == 0
                                  ? '—'
                                  : '${stats!.recentAverage.round()}',
                              label: 'Puntuación\npromedio',
                              color: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 12),
                            _ActivityStat(
                              icon: Icons.play_circle_rounded,
                              value: '${activeSessions.length}',
                              label: 'Sesiones\nactivas',
                              color: _kCoral,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Recent activity (real gameplay) ──────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      'ACTIVIDAD RECIENTE',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: _kAmber,
                      ),
                    ),
                  ),
                  if (stats == null || stats!.recentScores.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        'Aún no ha jugado ningún juego.',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  else
                    ...stats!.recentScores.take(5).map(
                          (e) => Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.gameTitle,
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _kNavy,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${e.score} pts',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  const SizedBox(height: 12),

                  // ── Active sessions ─────────────────────────────────
                  if (activeSessions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        'SESIONES ACTIVAS',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: _kAmber,
                        ),
                      ),
                    ),
                    ...activeSessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _SessionDetailRow(session: s),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ── All sessions history ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      sessions.isEmpty
                          ? 'HISTORIAL'
                          : 'HISTORIAL  (${sessions.length})',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: _kAmber,
                      ),
                    ),
                  ),

                  if (snap.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(color: _kNavy),
                      ),
                    )
                  else if (sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aún no hay sesiones asignadas',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...sessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _SessionDetailRow(session: s),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ── Activity stat chip ────────────────────────────────────────────────────────

class _ActivityStat extends StatelessWidget {
  const _ActivityStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: Colors.grey[500],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session detail row ────────────────────────────────────────────────────────

class _SessionDetailRow extends StatelessWidget {
  const _SessionDetailRow({required this.session});
  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final scores = session.scoreMap.values.toList();
    final avg = scores.isEmpty
        ? null
        : (scores.reduce((a, b) => a + b) / scores.length).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: session.isActive
                  ? const Color(0xFF2ECC71)
                  : (session.isCompleted
                      ? const Color(0xFF6366F1)
                      : Colors.grey[300]!),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.isActive
                      ? 'Sesión activa'
                      : (session.isCompleted ? 'Completada' : 'En progreso'),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.completedCount} / ${session.totalCount} juegos completados',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Progress + score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (avg != null)
                Text(
                  '⭐ $avg pts',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: session.progressFraction,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFF3F4F6),
                    color:
                        session.isCompleted ? const Color(0xFF6366F1) : _kCoral,
                  ),
                ),
              ),
              Text(
                '${(session.progressFraction * 100).toInt()}%',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
