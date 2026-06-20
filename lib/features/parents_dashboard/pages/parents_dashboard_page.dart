import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/features/subscription/services/subscription_service.dart';
import 'package:edu_play/features/onboarding/widgets/onboarding_wizard.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kRed = Color(0xFFC0392B);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);
const _kLavender = Color(0xFFEEEDF8);

// ── Entry point ───────────────────────────────────────────────────────────────

class ParentsDashboardPage extends StatefulWidget {
  const ParentsDashboardPage({super.key});

  @override
  State<ParentsDashboardPage> createState() => _ParentsDashboardPageState();
}

class _ParentsDashboardPageState extends State<ParentsDashboardPage> {
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
      ChildProfilesService.getProfiles(),
      ChildProfilesService.getParentName(),
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
        title: Text('Eliminar perfil',
            style: GoogleFonts.fredoka(color: _kNavy, fontSize: 18)),
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
            child: Text('Eliminar',
                style: GoogleFonts.nunito(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ChildProfilesService.deleteProfile(p.id);
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

class _OverviewBody extends StatelessWidget {
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

  // Computed mock weekly stats
  int get _totalMinutes => profiles.isEmpty ? 0 : 765; // 12h 45m
  String get _topSubject =>
      profiles.isEmpty ? '—' : (profiles.first.focusSubject);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final firstName = parentName.split(' ').first;

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
                              fontSize: 14, color: Colors.grey[500]),
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
                        onPressed: () => Navigator.of(ctx)
                            .pushNamed(RouterPaths.createSession),
                        icon: const Icon(Icons.play_circle_outline_rounded,
                            size: 18),
                        label: Text(
                          'Start Session',
                          style:
                              GoogleFonts.nunito(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kCoral,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onAddProfile,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Añadir Perfil',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
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
        profiles.isEmpty
            ? _EmptyProfiles(onAdd: onAddProfile)
            : _ChildProfilesGrid(
                profiles: profiles,
                onDelete: onDeleteProfile,
              ),

        const SizedBox(height: 28),

        // Recommendations per child
        if (profiles.isNotEmpty) ...[
          const _SectionLabel(title: 'Necesita practicar', action: ''),
          const SizedBox(height: 14),
          ...profiles.map((p) => _RecommendationsCard(profile: p)),
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
                      child: _AchievementCard(profiles: profiles),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      flex: 6,
                      child: _ChallengesCard(),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _AchievementCard(profiles: profiles),
                  const SizedBox(height: 20),
                  const _ChallengesCard(),
                ],
              ),
        const SizedBox(height: 28),
      ],
    );

    Widget sideCol = Column(
      children: [
        const SizedBox(height: 24),
        _WeeklySummaryCard(
            totalMinutes: _totalMinutes, topSubject: _topSubject),
        const SizedBox(height: 16),
        const _QuickControlsCard(),
        const SizedBox(height: 16),
        const _ActiveSessionsCard(),
        const SizedBox(height: 16),
        const _SessionHistoryCard(),
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
      child: Column(
        children: [
          mainCol,
          sideCol,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Child profile grid ────────────────────────────────────────────────────────

class _ChildProfilesGrid extends StatelessWidget {
  const _ChildProfilesGrid({
    required this.profiles,
    required this.onDelete,
  });

  final List<ChildProfile> profiles;
  final ValueChanged<ChildProfile> onDelete;

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width >= 700 ? 2 : 1;

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
        onDelete: () => onDelete(profiles[i]),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.profile, required this.onDelete});

  final ChildProfile profile;
  final VoidCallback onDelete;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    profile.levelLabel,
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
                          horizontal: 8, vertical: 3),
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
                                    fontSize: 10, color: Colors.grey[500]),
                              ),
                              Text(
                                '${(profile.levelProgress * 100).toInt()}%',
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
                              value: profile.levelProgress,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pin_rounded,
                          size: 12, color: _kNavy.withValues(alpha: 0.6)),
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
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kNavy,
                  side: BorderSide(color: Colors.grey.shade200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Detalle de Actividad',
                  style: GoogleFonts.nunito(
                      fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          // Delete
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                size: 18, color: Colors.grey[400]),
            onPressed: () => _showOptions(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
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
              title: Text('Ver PIN de acceso',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                _showPinDialog(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: Text('Eliminar perfil',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: Colors.red)),
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

// ── Weekly summary card ───────────────────────────────────────────────────────

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({
    required this.totalMinutes,
    required this.topSubject,
  });
  final int totalMinutes;
  final String topSubject;

  String get _timeLabel {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kNavyDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN SEMANAL',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            icon: Icons.access_time_rounded,
            label: 'Tiempo de Juego',
            value: totalMinutes > 0 ? _timeLabel : '—',
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.menu_book_rounded,
            label: 'Materia Top',
            value: topSubject.isNotEmpty ? topSubject : '—',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Quick controls card ───────────────────────────────────────────────────────

class _QuickControlsCard extends StatefulWidget {
  const _QuickControlsCard();

  @override
  State<_QuickControlsCard> createState() => _QuickControlsCardState();
}

class _QuickControlsCardState extends State<_QuickControlsCard> {
  bool _bedtimeEnabled = true;

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.people_alt_rounded,
                  size: 16, color: Colors.white54),
              const SizedBox(width: 8),
              Text(
                'CONTROLES RÁPIDOS',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Daily limit
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Límite Diario',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Activo · 2 horas',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.4)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Bedtime
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo Dormir',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Desde las 20:30',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _bedtimeEnabled,
                  onChanged: (v) => setState(() => _bedtimeEnabled = v),
                  activeThumbColor: const Color(0xFF2ECC71),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: WidgetStateProperty.all(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active Sessions card ──────────────────────────────────────────────────────

class _ActiveSessionsCard extends StatelessWidget {
  const _ActiveSessionsCard();

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
              Row(children: [
                const Icon(Icons.play_circle_outline_rounded,
                    size: 16, color: Colors.white54),
                const SizedBox(width: 8),
                Text('Active Sessions',
                    style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                // Live indicator — pulses while stream is connected
                if (!isLoading)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27AE60),
                      shape: BoxShape.circle,
                    ),
                  ),
              ]),
              const SizedBox(height: 14),
              if (isLoading)
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white54),
                  ),
                )
              else if (sessions.isEmpty)
                Column(
                  children: [
                    const Text('🎮', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text('No active sessions',
                        style: GoogleFonts.nunito(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(RouterPaths.createSession),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _kCoral),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Start Session',
                            style: GoogleFonts.nunito(
                                color: _kCoral,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
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
          Row(children: [
            Expanded(
              child: Text(session.childName,
                  style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Active',
                  style: GoogleFonts.nunito(
                      color: const Color(0xFF27AE60),
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('PIN: ${session.pin}  •  ${session.totalCount} games',
              style: GoogleFonts.nunito(color: Colors.white54, fontSize: 11)),
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
          Row(children: [
            Text(
              '${session.completedCount}/${session.totalCount} done',
              style: GoogleFonts.nunito(color: Colors.white38, fontSize: 10),
            ),
            const Spacer(),
            // Share link button
            GestureDetector(
              onTap: () {
                final url =
                    'https://app.eduplay.com/practice-session?pin=${session.pin}';
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Enlace copiado al portapapeles',
                        style: GoogleFonts.nunito()),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1E1B6A),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.share_rounded,
                    size: 12, color: Color(0xFF27AE60)),
                const SizedBox(width: 3),
                Text('Compartir',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF27AE60),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onEnd,
              child: Text('Finalizar',
                  style: GoogleFonts.nunito(
                      color: _kCoral,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Achievement card ──────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.profiles});
  final List<ChildProfile> profiles;

  @override
  Widget build(BuildContext context) {
    final achiever = profiles.isNotEmpty ? profiles.first.name : 'Tu hijo';

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
                  '¡Explorador Galáctico!',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$achiever completó 10 misiones de\nCiencias en una semana.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Enviar Felicitación',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 12),
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

class _ChallengesCard extends StatelessWidget {
  const _ChallengesCard();

  static const _challenges = [
    (
      icon: Icons.calculate_rounded,
      title: 'Tablas de Multiplicar del 7',
      subtitle: 'Asignado por: Profe Marta',
      tag: 'Urgente',
      tagColor: Color(0xFFC0392B),
    ),
    (
      icon: Icons.eco_rounded,
      title: 'Ciclo de la Vida: Las Plantas',
      subtitle: 'Basado en intereses de Sofía',
      tag: 'Recomendado',
      tagColor: Color(0xFF2ECC71),
    ),
    (
      icon: Icons.translate_rounded,
      title: 'Vocabulario: La Ciudad',
      subtitle: 'Inglés Nivel A1',
      tag: 'Próximamente',
      tagColor: Color(0xFF95A5A6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '4 Tareas Pendientes',
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
          for (final c in _challenges) ...[
            _ChallengeTile(
              icon: c.icon,
              title: c.title,
              subtitle: c.subtitle,
              tag: c.tag,
              tagColor: c.tagColor,
            ),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ],
        ],
      ),
    );
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
                  style:
                      GoogleFonts.nunito(fontSize: 11, color: Colors.grey[500]),
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
            color: const Color(0xFFEEEDF8), width: 2, style: BorderStyle.solid),
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
                fontSize: 13, color: Colors.grey[400], height: 1.5),
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
    final profile = await ChildProfilesService.addProfile(
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
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
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
                                fontSize: 14, color: const Color(0xFF111827)),
                            decoration: _inputDec(''),
                            items: List.generate(12, (i) => i + 5)
                                .map((a) => DropdownMenuItem(
                                      value: a,
                                      child: Text('$a años'),
                                    ))
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
                                fontSize: 14, color: const Color(0xFF111827)),
                            decoration: _inputDec(''),
                            items: _subjects
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
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
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Crear perfil y generar PIN',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700, fontSize: 15),
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
                    fontSize: 13, color: Colors.grey[500], height: 1.4),
              ),
              const SizedBox(height: 24),
              // PIN display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
              // Copy button
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: profile.pin));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PIN copiado', style: GoogleFonts.nunito()),
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
                      borderRadius: BorderRadius.circular(10)),
                ),
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

// ── Session history card (completed sessions, real-time stream) ───────────────

class _SessionHistoryCard extends StatelessWidget {
  const _SessionHistoryCard();

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
              Row(children: [
                const Icon(Icons.history_rounded,
                    size: 16, color: Colors.white54),
                const SizedBox(width: 8),
                Text('Historial de Sesiones',
                    style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 14),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white54),
                  ),
                )
              else if (sessions.isEmpty)
                Text('Sin sesiones finalizadas aún.',
                    style:
                        GoogleFonts.nunito(color: Colors.white54, fontSize: 12))
              else
                ...sessions.map((s) {
                  final total = s.scoreMap.values.fold(0, (a, b) => a + b);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.childName,
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                            Text(
                              '${s.completedCount}/${s.totalCount} juegos  ·  $total pts',
                              style: GoogleFonts.nunito(
                                  color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Text(_relativeDate(s.createdAt),
                          style: GoogleFonts.nunito(
                              color: Colors.white38, fontSize: 10)),
                    ]),
                  );
                }),
              if (sessions.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(RouterPaths.progressReports),
                  child: Text(
                    'Ver informe completo →',
                    style: GoogleFonts.nunito(
                        color: _kCoral,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
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

// ── Tier badge ────────────────────────────────────────────────────────────────

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
        widget.profile.id);
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
                    child: const Icon(Icons.lightbulb_rounded,
                        size: 18, color: Color(0xFFE65100)),
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
                              fontSize: 11, color: Colors.grey[500]),
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
                        horizontal: 12, vertical: 7),
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

// ── Placeholder for other tabs ────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.index});
  final int index;

  static const _titles = ['', 'Progreso', 'Recursos', 'Configuración'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _titles[index],
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
