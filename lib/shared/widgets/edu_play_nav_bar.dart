import 'package:edu_play/utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);

// ─────────────────────────────────────────────────────────────────────────────
// EduPlayNavBar — single shared app bar for the whole EduPlay app.
//
// Usage:
//   EduPlayNavBar.parent(context, activeTab: ParentTab.recursos)
//   EduPlayNavBar.student(context, activeTab: StudentTab.games)
//
// Drop it at the top of any page's Column:
//   Column(children: [
//     EduPlayNavBar.parent(context, activeTab: ParentTab.inicio),
//     Expanded(child: ...),
//   ])
// ─────────────────────────────────────────────────────────────────────────────

enum ParentTab { inicio, progreso, recursos, configuracion }

enum StudentTab { learn, games, classroom, reports }

class EduPlayNavBar extends StatelessWidget {
  // ── Parent mode ─────────────────────────────────────────────────────────────
  const EduPlayNavBar.parent({
    super.key,
    required this.activeParentTab,
    this.parentName = 'Mamá',
  })  : _mode = _Mode.parent,
        activeStudentTab = null;

  // ── Student / general mode ───────────────────────────────────────────────────
  const EduPlayNavBar.student({
    super.key,
    required this.activeStudentTab,
  })  : _mode = _Mode.student,
        activeParentTab = null,
        parentName = null;

  final _Mode _mode;
  final ParentTab? activeParentTab;
  final StudentTab? activeStudentTab;
  final String? parentName;

  static const _parentTabs = [
    (
      label: 'Inicio',
      tab: ParentTab.inicio,
      route: RouterPaths.parentsDashboard
    ),
    (
      label: 'Progreso',
      tab: ParentTab.progreso,
      route: RouterPaths.progressReports
    ),
    (
      label: 'Recursos',
      tab: ParentTab.recursos,
      route: RouterPaths.parentGuide
    ),
    (
      label: 'Configuración',
      tab: ParentTab.configuracion,
      route: RouterPaths.settings
    ),
  ];

  static const _studentTabs = [
    (label: 'Learn', tab: StudentTab.learn, route: ''),
    (label: 'Games', tab: StudentTab.games, route: RouterPaths.gamesCatalog),
    (label: 'Classroom', tab: StudentTab.classroom, route: ''),
    (
      label: 'Reports',
      tab: StudentTab.reports,
      route: RouterPaths.progressReports
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              // Logo — always navigates to home
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  RouterPaths.root,
                  (r) => false,
                ),
                child: Text(
                  'EduPlay',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
              ),

              // Tabs (desktop only)
              if (isDesktop) ...[
                const SizedBox(width: 36),
                if (_mode == _Mode.parent)
                  ..._parentTabs.map(
                    (t) => _TabItem(
                      label: t.label,
                      selected: activeParentTab == t.tab,
                      onTap: () => _navigate(context, t.route),
                    ),
                  )
                else
                  ..._studentTabs.map(
                    (t) => _TabItem(
                      label: t.label,
                      selected: activeStudentTab == t.tab,
                      onTap: () => _navigate(context, t.route),
                    ),
                  ),
              ],

              const Spacer(),

              // Right side icons
              _IconBtn(
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _IconBtn(
                icon: Icons.settings_outlined,
                onTap: () => _navigate(context, RouterPaths.settings),
              ),
              const SizedBox(width: 12),

              // Avatar (+ name in parent mode)
              GestureDetector(
                onTap: () => _navigate(context, RouterPaths.settings),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _kNavy.withValues(alpha: 0.1),
                      child: Icon(Icons.person_rounded,
                          size: 17, color: _kNavy.withValues(alpha: 0.6)),
                    ),
                    if (_mode == _Mode.parent &&
                        parentName != null &&
                        isDesktop) ...[
                      const SizedBox(width: 8),
                      Text(
                        parentName!,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _kNavy,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Routes that are exclusively for authenticated parents/teachers.
  // A guest or anonymous user clicking these is sent to login instead.
  static const _parentOnlyRoutes = {
    RouterPaths.parentsDashboard,
    RouterPaths.parentGuide,
    RouterPaths.progressReports,
    RouterPaths.settings,
  };

  void _navigate(BuildContext context, String route) {
    if (route.isEmpty) return;
    final current = ModalRoute.of(context)?.settings.name ?? '';
    if (current == route) return; // already here

    // In student mode, parent-only routes require a real (non-anonymous) login.
    if (_mode == _Mode.student && _parentOnlyRoutes.contains(route)) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) {
        Navigator.of(context).pushNamed(RouterPaths.login);
        return;
      }
    }

    Navigator.of(context).pushNamed(route);
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

enum _Mode { parent, student }

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? _kNavy : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: _kNavy,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.grey[400], size: 22),
    );
  }
}
