// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/onboarding/widgets/onboarding_wizard.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/parent_child_stats_service.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_achievement_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_active_sessions_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_challenges_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_child_profiles_grid.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_empty_profiles.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_purchase_approvals_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_quick_controls_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_recommendations_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_session_history_card.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_tier_badge.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_weekly_summary_card.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

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
                        ParentTierBadge(),
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
                    'Iniciar Sesión',
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
            ? ParentEmptyProfiles(onAdd: widget.onAddProfile)
            : ParentChildProfilesGrid(
                profiles: widget.profiles,
                stats: _stats,
                onDelete: widget.onDeleteProfile,
              ),

        const SizedBox(height: 28),

        // Recommendations per child
        if (widget.profiles.isNotEmpty) ...[
          const _SectionLabel(title: 'Necesita practicar', action: ''),
          const SizedBox(height: 14),
          ...widget.profiles.map((p) => ParentRecommendationsCard(profile: p)),
          const SizedBox(height: 28),
        ],

        isDesktop
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: ParentAchievementCard(
                        profiles: widget.profiles,
                        stats: _stats,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: ParentChallengesCard(profiles: widget.profiles),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  ParentAchievementCard(
                      profiles: widget.profiles, stats: _stats),
                  const SizedBox(height: 20),
                  ParentChallengesCard(profiles: widget.profiles),
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
        ParentPurchaseApprovalsCard(profiles: widget.profiles),
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

// Progress recommendations card ─────────────────────────────────────────────

// ── Child activity detail sheet ───────────────────────────────────────────────
