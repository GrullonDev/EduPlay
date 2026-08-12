import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';
import 'package:edu_play/features/settings/widgets/settings_security_section.dart';
import 'package:edu_play/features/settings/widgets/settings_notifications_section.dart';
import 'package:edu_play/features/settings/widgets/settings_subscription_section.dart';
import 'package:edu_play/features/settings/widgets/settings_profile_section.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kBg = Color(0xFFF8F7FF);

// ── Entry point ───────────────────────────────────────────────────────────────

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _sectionIndex =
      0; // 0=Profile, 1=Subscription, 2=Notifications, 3=Security
  String _parentName = 'Mamá';

  @override
  void initState() {
    super.initState();
    _loadParentName();
  }

  Future<void> _loadParentName() async {
    final name = await ChildProfilesService.getParentName();
    if (!mounted) return;
    setState(() => _parentName = name);
  }

  static const _sections = [
    (icon: Icons.person_outline_rounded, label: 'Profile'),
    (icon: Icons.credit_card_outlined, label: 'Subscription'),
    (icon: Icons.notifications_none_rounded, label: 'Notifications'),
    (icon: Icons.shield_outlined, label: 'Security'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          EduPlayNavBar.parent(
              activeParentTab: ParentTab.configuracion,
              parentName: _parentName),
          Expanded(
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left sidebar
                      _SidebarPanel(
                        sections: _sections
                            .map((s) => (icon: s.icon, label: s.label))
                            .toList(),
                        selectedIndex: _sectionIndex,
                        onTap: (i) => setState(() => _sectionIndex = i),
                      ),
                      // Main content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _SectionBody(index: _sectionIndex),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Horizontal tab row on mobile
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: List.generate(
                            _sections.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _MobileTab(
                                icon: _sections[i].icon,
                                label: _sections[i].label,
                                selected: _sectionIndex == i,
                                onTap: () => setState(() => _sectionIndex = i),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _SectionBody(index: _sectionIndex),
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

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _SidebarPanel extends StatelessWidget {
  const _SidebarPanel({
    required this.sections,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<({IconData icon, String label})> sections;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Settings',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          Text(
            'Manage your account and preferences',
            style: GoogleFonts.nunito(
                fontSize: 12, color: Colors.grey[500], height: 1.4),
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < sections.length; i++)
            _SidebarItem(
              icon: sections[i].icon,
              label: sections[i].label,
              selected: selectedIndex == i,
              onTap: () => onTap(i),
            ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 8),
          // Logout
          InkWell(
            onTap: () async {
              init();
              await sl<AccountSecurityRepository>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouterPaths.login,
                  (route) => false,
                );
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, size: 18, color: _kRed),
                  const SizedBox(width: 12),
                  Text(
                    'Cerrar sesión',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _kNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18, color: selected ? Colors.white : Colors.grey[500]),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileTab extends StatelessWidget {
  const _MobileTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _kNavy : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14, color: selected ? Colors.white : Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section body ──────────────────────────────────────────────────────────────

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const SettingsProfileSection();
      case 1:
        return const SettingsSubscriptionSection();
      case 2:
        return const SettingsNotificationsSection();
      case 3:
        return const SettingsSecuritySection();
      default:
        return const SettingsProfileSection();
    }
  }
}

// ── Profile section ───────────────────────────────────────────────────────────

// ── Subscription section ──────────────────────────────────────────────────────

// ── Settings footer ───────────────────────────────────────────────────────────

// ── Notifications section ─────────────────────────────────────────────────────

// ── Security section ──────────────────────────────────────────────────────────
