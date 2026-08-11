import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyMid = Color(0xFF2D2A82);
const _kCoral = Color(0xFFE53935);

class StudentTopNavBar extends StatelessWidget {
  const StudentTopNavBar({
    super.key,
    required this.bloc,
    required this.s,
  });
  final StudentDashboardBloc bloc;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: s.isWide ? 40 : 24,
      ),
      child: Row(
        children: [
          // Logo
          Text(
            'EduPlay',
            style: GoogleFonts.fredoka(
                fontSize: 22, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(width: 32),

          const Spacer(),

          StudentPointsBadge(points: bloc.points),
          const SizedBox(width: 16),

          // Notification bell
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notificaciones próximamente.'),
                duration: Duration(seconds: 2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_outlined,
                      color: Colors.grey[600], size: 22),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: _kCoral, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar + name
          CircleAvatar(
            radius: 16,
            backgroundColor: _kNavy,
            child: Text(
              bloc.displayName.isNotEmpty
                  ? bloc.displayName[0].toUpperCase()
                  : 'E',
              style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            bloc.displayName.split(' ').first,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700, fontSize: 14, color: _kNavy),
          ),
        ],
      ),
    );
  }
}

class StudentPointsBadge extends StatelessWidget {
  const StudentPointsBadge({super.key, required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFF8F00), size: 16),
          const SizedBox(width: 4),
          Text(
            '$points pts',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A3E00),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────

const _sideNavItems = [
  _SideItem(icon: Icons.dashboard_rounded, label: 'Panel de Control', tab: 0),
  _SideItem(icon: Icons.videogame_asset_rounded, label: 'Mis Juegos', tab: 1),
  _SideItem(icon: Icons.emoji_events_rounded, label: 'Logros', tab: 2),
  if (ReleaseFlags.friendsEnabled)
    _SideItem(icon: Icons.people_alt_rounded, label: 'Amigos', tab: 3),
  if (ReleaseFlags.studentExtraTabsEnabled)
    _SideItem(icon: Icons.storefront_rounded, label: 'Tienda', tab: 4),
];

/// Kindergarten-age children (<= 5) only ever see "Mis Juegos" — Panel de
/// Control and Logros are hidden entirely, not just unreachable.
List<_SideItem> _visibleNavItems(bool isYoungChild) => isYoungChild
    ? _sideNavItems.where((i) => i.tab == 1).toList()
    : _sideNavItems;

class _SideItem {
  const _SideItem({required this.icon, required this.label, required this.tab});
  final IconData icon;
  final String label;
  final int tab;
}

class StudentSidebar extends StatelessWidget {
  const StudentSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.bloc,
    required this.wide,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final StudentDashboardBloc bloc;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    // Wide desktop: slightly wider sidebar
    final width = wide ? 220.0 : 200.0;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kNavy, _kNavyMid, Color(0xFF3D3AA0)],
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido!',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nivel ${bloc.level} Explorador',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            _divider(),
            const SizedBox(height: 12),

            // Nav items
            for (final item in _visibleNavItems(bloc.isYoungChild))
              _SideNavTile(
                item: item,
                selected: item.tab == selected,
                onTap: () => onSelect(item.tab),
              ),

            const Spacer(),

            // Quest button → opens the Mis Juegos tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onSelect(1),
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                  label: Text(
                    '¡Comenzar Quest!',
                    style: GoogleFonts.fredoka(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            _divider(),

            _SideFooterTile(
              icon: Icons.help_outline_rounded,
              label: 'Ayuda',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centro de ayuda próximamente.'),
                  duration: Duration(seconds: 2),
                ),
              ),
            ),
            _SideFooterTile(
              icon: Icons.logout_rounded,
              label: 'Salir',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, RouterPaths.login),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white.withValues(alpha: 0.1),
      );
}

class _SideNavTile extends StatelessWidget {
  const _SideNavTile(
      {required this.item, required this.selected, required this.onTap});
  final _SideItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(item.icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.55)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                item.label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideFooterTile extends StatelessWidget {
  const _SideFooterTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME / PANEL DE CONTROL
// ─────────────────────────────────────────────────────────────────────────────
