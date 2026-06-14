import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/features/subscription/services/subscription_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';
import 'package:edu_play/shared/widgets/upgrade_prompt_dialog.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kLavender = Color(0xFFEEEDF8);
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

  static const _sections = [
    (icon: Icons.person_outline_rounded, label: 'Profile'),
    (icon: Icons.credit_card_outlined, label: 'Subscription'),
    (icon: Icons.notifications_none_rounded, label: 'Notifications'),
    (icon: Icons.shield_outlined, label: 'Security'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const EduPlayNavBar.parent(activeParentTab: ParentTab.configuracion),
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
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, size: 18, color: _kRed),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
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
        return const _ProfileSection();
      case 1:
        return const _SubscriptionSection();
      case 2:
        return const _PlaceholderSection(
            icon: Icons.notifications_none_rounded, title: 'Notifications');
      case 3:
        return const _PlaceholderSection(
            icon: Icons.shield_outlined, title: 'Security');
      default:
        return const _ProfileSection();
    }
  }
}

// ── Profile section ───────────────────────────────────────────────────────────

class _ProfileSection extends StatefulWidget {
  const _ProfileSection();

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  final _nameCtrl = TextEditingController(text: 'Felix Explorer');
  final _emailCtrl = TextEditingController(text: 'felix@eduplay.quest');
  final _schoolCtrl = TextEditingController(text: 'ED-7742-XP');
  String _gradeLevel = 'Middle School - Year 7';
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final bool _showPw = false;

  static const _gradeLevels = [
    'Primary School - Year 1',
    'Primary School - Year 2',
    'Primary School - Year 3',
    'Primary School - Year 4',
    'Primary School - Year 5',
    'Primary School - Year 6',
    'Middle School - Year 7',
    'Middle School - Year 8',
    'Middle School - Year 9',
    'High School - Year 10',
    'High School - Year 11',
    'High School - Year 12',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _schoolCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information card
        _SettingsCard(
          icon: Icons.person_outline_rounded,
          title: 'Personal Information',
          child: Column(
            children: [
              // Avatar row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kNavy.withValues(alpha: 0.12),
                        ),
                        child: const Icon(Icons.person_rounded,
                            size: 40, color: _kNavy),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kNavy,
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                  child: _FieldGroup(
                                      label: 'Full Name', ctrl: _nameCtrl)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _FieldGroup(
                                      label: 'Email Address',
                                      ctrl: _emailCtrl)),
                            ],
                          )
                        : Column(
                            children: [
                              _FieldGroup(label: 'Full Name', ctrl: _nameCtrl),
                              const SizedBox(height: 16),
                              _FieldGroup(
                                  label: 'Email Address', ctrl: _emailCtrl),
                            ],
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Grade Level'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _gradeLevel,
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: const Color(0xFF111827)),
                                decoration: _inputDec(''),
                                items: _gradeLevels
                                    .map((g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _gradeLevel = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FieldGroup(
                              label: 'School ID', ctrl: _schoolCtrl),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Grade Level'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _gradeLevel,
                          style: GoogleFonts.nunito(
                              fontSize: 14, color: const Color(0xFF111827)),
                          decoration: _inputDec(''),
                          items: _gradeLevels
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _gradeLevel = v!),
                        ),
                        const SizedBox(height: 16),
                        _FieldGroup(label: 'School ID', ctrl: _schoolCtrl),
                      ],
                    ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Change Password card
        _SettingsCard(
          icon: Icons.lock_outline_rounded,
          title: 'Change Password',
          child: Column(
            children: [
              isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: _PwField(
                            label: 'Current Password',
                            ctrl: _currentPwCtrl,
                            hint: '••••••••',
                            showPw: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PwField(
                            label: 'New Password',
                            ctrl: _newPwCtrl,
                            hint: 'Min. 8 chars',
                            showPw: _showPw,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PwField(
                            label: 'Confirm New Password',
                            ctrl: _confirmPwCtrl,
                            hint: '••••••••',
                            showPw: false,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _PwField(
                          label: 'Current Password',
                          ctrl: _currentPwCtrl,
                          hint: '••••••••',
                          showPw: false,
                        ),
                        const SizedBox(height: 16),
                        _PwField(
                          label: 'New Password',
                          ctrl: _newPwCtrl,
                          hint: 'Min. 8 chars',
                          showPw: _showPw,
                        ),
                        const SizedBox(height: 16),
                        _PwField(
                          label: 'Confirm New Password',
                          ctrl: _confirmPwCtrl,
                          hint: '••••••••',
                          showPw: false,
                        ),
                      ],
                    ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Profile Changes',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Footer
        const _SettingsFooter(),
      ],
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
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

// ── Shared field helpers ──────────────────────────────────────────────────────

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({required this.label, required this.ctrl});
  final String label;
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.nunito(fontSize: 14),
          decoration: _sharedInputDec(''),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
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

class _PwField extends StatelessWidget {
  const _PwField({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.showPw,
  });
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool showPw;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: !showPw,
          style: GoogleFonts.nunito(fontSize: 14),
          decoration: _sharedInputDec(hint),
        ),
      ],
    );
  }
}

InputDecoration _sharedInputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kNavy, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );

// ── Settings card wrapper ─────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _kNavy),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

// ── Placeholder for other sections ───────────────────────────────────────────

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsCard(
          icon: icon,
          title: title,
          child: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction_rounded,
                      size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Próximamente',
                    style: GoogleFonts.fredoka(
                        fontSize: 18, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const _SettingsFooter(),
      ],
    );
  }
}

// ── Subscription section ──────────────────────────────────────────────────────

class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Subscription>(
      stream: SubscriptionService.watchSubscription(),
      builder: (context, snap) {
        final sub = snap.data ?? Subscription.freeTier();
        final isPro = sub.isPro;
        final sessionsUsed = sub.sessionsThisMonth;
        final sessionLimit = Subscription.freeSessionLimit;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsCard(
              icon: Icons.credit_card_outlined,
              title: 'Suscripción',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current plan banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPro
                            ? [const Color(0xFF1E1B6A), const Color(0xFF3A36A0)]
                            : [
                                Colors.grey.shade100,
                                Colors.grey.shade200
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                                alpha: isPro ? 0.12 : 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPro
                                ? Icons.star_rounded
                                : Icons.lock_outline_rounded,
                            color:
                                isPro ? Colors.white : Colors.grey.shade500,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPro ? 'Plan Pro' : 'Plan Gratuito',
                                style: GoogleFonts.fredoka(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isPro
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                isPro
                                    ? 'Acceso ilimitado a todas las funciones'
                                    : 'Limitado a 1 niño y 5 sesiones/mes',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: isPro
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isPro) ...[
                    const SizedBox(height: 24),

                    // Usage meters
                    Text(
                      'USO ESTE MES',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: _kNavy.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _UsageMeter(
                      label: 'Sesiones de práctica',
                      used: sessionsUsed,
                      limit: sessionLimit,
                    ),
                    const SizedBox(height: 12),
                    _UsageMeter(
                      label: 'Perfiles de niño',
                      used: null, // loaded by a separate FutureBuilder below
                      limit: Subscription.freeChildLimit,
                      isChildMeter: true,
                    ),

                    const SizedBox(height: 24),

                    // Upgrade CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => showUpgradePrompt(
                            context, UpgradeReason.sessionLimit),
                        icon: const Icon(Icons.rocket_launch_rounded,
                            size: 18, color: Colors.white),
                        label: Text(
                          'Mejorar a Pro — \$9.99/mes',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6E6C),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],

                  if (isPro) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Tienes acceso ilimitado. Gracias por tu apoyo.',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            const _SettingsFooter(),
          ],
        );
      },
    );
  }
}

// ── Usage meter ───────────────────────────────────────────────────────────────

class _UsageMeter extends StatelessWidget {
  const _UsageMeter({
    required this.label,
    required this.used,
    required this.limit,
    this.isChildMeter = false,
  });

  final String label;
  final int? used;     // null triggers a FutureBuilder for child count
  final int limit;
  final bool isChildMeter;

  @override
  Widget build(BuildContext context) {
    if (isChildMeter) {
      return FutureBuilder<int>(
        future: ChildProfilesService.getProfiles()
            .then((list) => list.length),
        builder: (ctx, snap) =>
            _bar(label, snap.data ?? 0, limit),
      );
    }
    return _bar(label, used ?? 0, limit);
  }

  Widget _bar(String lbl, int u, int lim) {
    final fraction = (u / lim).clamp(0.0, 1.0);
    final atLimit = u >= lim;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lbl,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333355))),
            Text(
              '$u / $lim',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: atLimit
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF1E1B6A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: const Color(0xFFEEEDF8),
            valueColor: AlwaysStoppedAnimation<Color>(
              atLimit
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF1E1B6A),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Settings footer ───────────────────────────────────────────────────────────

class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _kLavender,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduPlay',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Empowering the next generation of explorers\nthrough play-based learning.',
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: Colors.grey[500], height: 1.5),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 2,
            child: _FooterLinks('RESOURCES',
                ['Teacher Resources', 'Parent Guide', 'Support Center']),
          ),
          const Expanded(
            flex: 2,
            child: _FooterLinks('LEGAL', [
              'Privacy Policy',
              'Terms of Service',
            ]),
          ),
        ],
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks(this.title, this.links);
  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 10),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              link,
              style: GoogleFonts.nunito(
                  fontSize: 12, color: _kNavy.withValues(alpha: 0.7)),
            ),
          ),
      ],
    );
  }
}
