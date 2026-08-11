import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/core/audio/sound_manager.dart';
import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/features/friends/pages/friends_view.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_dashboard_navigation.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_games_hub_view.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_achievements_view.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_challenges_view.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_home_view.dart';
import 'package:edu_play/utils/dialogs/confetti_burst.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kBg = Color(0xFFF3F5F9);

class StudentDashboardLayout extends StatefulWidget {
  const StudentDashboardLayout({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<StudentDashboardLayout> createState() => _StudentDashboardLayoutState();
}

class _StudentDashboardLayoutState extends State<StudentDashboardLayout> {
  late int _tab = widget.initialTab;
  GameSubject? _pendingSubject;

  int _effectiveTab(StudentDashboardBloc bloc) => bloc.isYoungChild ? 1 : _tab;

  bool _celebrationShown = false;

  void _maybeShowLevelUpCelebration(StudentDashboardBloc bloc) {
    if (bloc.levelUpToShow == null || _celebrationShown) return;
    _celebrationShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showLevelUpCelebration(context, bloc);
    });
  }

  void _showLevelUpCelebration(
      BuildContext context, StudentDashboardBloc bloc) {
    SoundManager().playWin();
    final newStickers = bloc.newlyUnlockedStickers;
    final content = newStickers.isEmpty
        ? '¡Sigue jugando para desbloquear más sorpresas!'
        : newStickers.length == 1
            ? '¡Ganaste la estampa "${newStickers.first.name}"!'
            : '¡Ganaste ${newStickers.length} estampas nuevas!';

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) => Stack(
        children: [
          const Positioned.fill(child: ConfettiBurst()),
          CustomDialog(
            type: DialogType.levelUp,
            title: '¡Subiste a Nivel ${bloc.levelUpToShow}!',
            content: content,
            buttonText: '¡Genial!',
            onButtonPressed: () {
              bloc.acknowledgeLevelUp();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _selectTab(int i) => setState(() {
        _tab = i;
        _pendingSubject = null;
      });

  void _openGamesForSubject(GameSubject subject) => setState(() {
        _tab = 1;
        _pendingSubject = subject;
      });

  Widget _buildContent(StudentDashboardBloc bloc, ScreenSize s, int tab) {
    switch (tab) {
      case 1:
        return StudentGamesHubView(
            bloc: bloc, s: s, initialSubject: _pendingSubject);
      case 2:
        return StudentAchievementsView(s: s);
      case 5:
        return StudentChallengesView(s: s);
      case 3:
        if (!ReleaseFlags.friendsEnabled) {
          return StudentHomeView(
            bloc: bloc,
            s: s,
            onTabChange: _selectTab,
            onSubjectSelect: _openGamesForSubject,
          );
        }
        return FriendsView(
          identity: bloc.friendIdentity,
          subtitle: 'Conecta con otros exploradores de EduPlay.',
        );
      default:
        return StudentHomeView(
          bloc: bloc,
          s: s,
          onTabChange: _selectTab,
          onSubjectSelect: _openGamesForSubject,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StudentDashboardBloc>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = ScreenSize.fromConstraints(constraints);

        if (bloc.isLoading) {
          return const Scaffold(
            backgroundColor: _kBg,
            body: Center(
              child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2.5),
            ),
          );
        }

        _maybeShowLevelUpCelebration(bloc);

        final tab = _effectiveTab(bloc);
        final content = _buildContent(bloc, s, tab);

        // ── Desktop: top nav + persistent sidebar ──────────────────────
        if (s.isDesktop) {
          return Scaffold(
            backgroundColor: _kBg,
            body: Column(
              children: [
                StudentTopNavBar(
                  bloc: bloc,
                  s: s,
                ),
                Expanded(
                  child: Row(
                    children: [
                      StudentSidebar(
                        selected: tab,
                        onSelect: _selectTab,
                        bloc: bloc,
                        wide: s.isWide,
                      ),
                      Expanded(
                        child: MaxWidthBox(
                          maxWidth: AppBreakpoints.maxContentWidth,
                          child: content,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // ── Tablet: drawer + AppBar with nav items visible ─────────────
        if (s.isTablet) {
          return Scaffold(
            backgroundColor: _kBg,
            appBar: _buildAppBar(bloc, showLinks: false),
            drawer: Drawer(
              child: StudentSidebar(
                selected: tab,
                onSelect: (i) {
                  Navigator.pop(context);
                  _selectTab(i);
                },
                bloc: bloc,
                wide: false,
              ),
            ),
            body: SafeArea(child: content),
          );
        }

        // ── Mobile: drawer + compact AppBar ───────────────────────────
        return Scaffold(
          backgroundColor: _kBg,
          appBar: _buildAppBar(bloc, showLinks: false),
          drawer: Drawer(
            child: StudentSidebar(
              selected: tab,
              onSelect: (i) {
                Navigator.pop(context);
                _selectTab(i);
              },
              bloc: bloc,
              wide: false,
            ),
          ),
          body: SafeArea(child: content),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(StudentDashboardBloc bloc,
      {required bool showLinks}) {
    return AppBar(
      backgroundColor: _kNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'EduPlay',
        style: GoogleFonts.fredoka(
            fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
      ),
      actions: [
        StudentPointsBadge(points: bloc.points),
        const SizedBox(width: 12),
      ],
    );
  }
}
