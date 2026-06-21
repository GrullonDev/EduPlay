import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edu_play/utils/child_portal_link.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/subscription/services/subscription_service.dart';
import 'package:edu_play/shared/widgets/upgrade_prompt_dialog.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kLavender = Color(0xFFEEEDF8);

// ── Avatar icons available for selection ──────────────────────────────────────

const _kAvatarIcons = [
  Icons.sentiment_satisfied_alt_rounded,
  Icons.rocket_launch_rounded,
  Icons.auto_awesome_rounded,
  Icons.pets_rounded,
  Icons.biotech_rounded,
  Icons.palette_rounded,
  Icons.park_rounded,
  Icons.music_note_rounded,
  Icons.castle_rounded,
  Icons.sports_esports_rounded,
];

// ── Interest options ──────────────────────────────────────────────────────────

const _kInterests = [
  (icon: Icons.calculate_rounded, label: 'Math & Numbers'),
  (icon: Icons.menu_book_rounded, label: 'Storytelling'),
  (icon: Icons.science_rounded, label: 'Space & Sci'),
  (icon: Icons.edit_rounded, label: 'Art & Drawing'),
  (icon: Icons.music_note_rounded, label: 'Music'),
  (icon: Icons.sports_soccer_rounded, label: 'Sports'),
  (icon: Icons.translate_rounded, label: 'Languages'),
  (icon: Icons.extension_rounded, label: 'Puzzles'),
];

// ── Grade levels ──────────────────────────────────────────────────────────────

const _kGradeLevels = [
  'Kindergarten',
  'Grade 1 (6 years)',
  'Grade 2 (7 years)',
  'Grade 3 (8 years)',
  'Grade 4 (9 years)',
  'Grade 5 (10 years)',
  'Grade 6 (11 years)',
  'Grade 7 (12 years)',
  'Grade 8 (13 years)',
  'Grade 9 (14 years)',
];

// ── Entry point ───────────────────────────────────────────────────────────────

class CreateExplorerPage extends StatefulWidget {
  const CreateExplorerPage({super.key});

  @override
  State<CreateExplorerPage> createState() => _CreateExplorerPageState();
}

class _CreateExplorerPageState extends State<CreateExplorerPage> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _gradeLevel;
  int _selectedAvatar = 0;
  final Set<int> _selectedInterests = {};
  bool _loading = false;

  int _existingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final profiles = await ChildProfilesService.getProfiles();
    if (mounted) setState(() => _existingCount = profiles.length);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _focusSubject {
    if (_selectedInterests.isEmpty) return 'Matemáticas';
    return _kInterests[_selectedInterests.first].label;
  }

  int get _ageFromGrade {
    if (_gradeLevel == null) return 8;
    final idx = _kGradeLevels.indexOf(_gradeLevel!);
    return idx < 0 ? 8 : idx + 5;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gradeLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an Age / Grade Level',
              style: GoogleFonts.nunito()),
          backgroundColor: _kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ── Free-tier child limit check ──────────────────────────────────────────
    final allowed = await SubscriptionService.canAddChild(_existingCount);
    if (!allowed) {
      if (!mounted) return;
      await showUpgradePrompt(context, UpgradeReason.childLimit);
      return;
    }

    setState(() => _loading = true);

    final profile = await ChildProfilesService.addProfile(
      name: _nameCtrl.text.trim(),
      age: _ageFromGrade,
      focusSubject: _focusSubject,
      existingCount: _existingCount,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    // Show PIN reveal then go back to parent dashboard
    await showDialog(
      context: context,
      builder: (_) => _PinRevealDialog(profile: profile),
    );
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RouterPaths.parentsDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      body: Stack(
        children: [
          // Gradient corner blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD6D6).withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD6E4FF).withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD6FFE8).withValues(alpha: 0.4),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                const _ExplorerNavBar(),

                // Step dots
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i == 0;
                    return Container(
                      width: active ? 28 : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active ? _kNavy : _kNavy.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Main card
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create an Explorer!',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: _kNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Let's set up a profile for your little learner to start their educational quest.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Name + Grade row
                                  _isDesktop(context)
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: _NameField(
                                                    ctrl: _nameCtrl)),
                                            const SizedBox(width: 16),
                                            Expanded(
                                                child: _GradeDropdown(
                                              value: _gradeLevel,
                                              onChanged: (v) => setState(
                                                  () => _gradeLevel = v),
                                            )),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            _NameField(ctrl: _nameCtrl),
                                            const SizedBox(height: 16),
                                            _GradeDropdown(
                                              value: _gradeLevel,
                                              onChanged: (v) => setState(
                                                  () => _gradeLevel = v),
                                            ),
                                          ],
                                        ),

                                  const SizedBox(height: 28),

                                  // Avatar picker
                                  const _SectionLabel(label: 'Pick an Avatar'),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: List.generate(
                                      _kAvatarIcons.length,
                                      (i) => _AvatarOption(
                                        icon: _kAvatarIcons[i],
                                        selected: _selectedAvatar == i,
                                        onTap: () =>
                                            setState(() => _selectedAvatar = i),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Interests
                                  const _SectionLabel(label: 'Interests'),
                                  const SizedBox(height: 12),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.6,
                                    ),
                                    itemCount: _kInterests.length,
                                    itemBuilder: (_, i) {
                                      final sel =
                                          _selectedInterests.contains(i);
                                      return _InterestTile(
                                        icon: _kInterests[i].icon,
                                        label: _kInterests[i].label,
                                        selected: sel,
                                        onTap: () => setState(() {
                                          if (sel) {
                                            _selectedInterests.remove(i);
                                          } else {
                                            _selectedInterests.add(i);
                                          }
                                        }),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 32),

                                  // Create button
                                  SizedBox(
                                    width: 240,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _kRed,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                                              'Create Profile',
                                              style: GoogleFonts.fredoka(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        '© 2024 EduPlay Learning. Secure Setup.',
                        style: GoogleFonts.nunito(
                            fontSize: 11, color: Colors.grey[400]),
                      ),
                      const Spacer(),
                      Text(
                        'Parent Guide',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.grey[400],
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey[400]),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Privacy',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.grey[400],
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isDesktop(BuildContext context) => !ScreenSize.of(context).isMobile;
}

// ── Navbar ────────────────────────────────────────────────────────────────────

class _ExplorerNavBar extends StatelessWidget {
  const _ExplorerNavBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Text(
            'EduPlay',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _kNavy,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded,
                size: 16, color: Color(0xFF666666)),
            label: Text(
              'Exit Setup',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form sub-widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _kNavy,
          decoration: TextDecoration.underline,
          decorationColor: _kNavy.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Child's name",
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.nunito(fontSize: 14),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          decoration: _inputDec('e.g. Charlie'),
        ),
      ],
    );
  }
}

class _GradeDropdown extends StatelessWidget {
  const _GradeDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age / Grade Level',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            'Select level...',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
          ),
          style:
              GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF111827)),
          decoration: _inputDec(''),
          items: _kGradeLevels
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ],
    );
  }
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );

// ── Avatar tile ───────────────────────────────────────────────────────────────

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: selected ? _kNavy : _kLavender,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kNavy : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kNavy.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 24,
          color: selected ? Colors.white : _kNavy.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

// ── Interest tile ─────────────────────────────────────────────────────────────

class _InterestTile extends StatelessWidget {
  const _InterestTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kLavender : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? _kNavy.withValues(alpha: 0.4) : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? _kNavy : _kNavy.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? _kNavy : _kNavy.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PIN reveal dialog (reused here) ──────────────────────────────────────────

class _PinRevealDialog extends StatefulWidget {
  const _PinRevealDialog({required this.profile});
  final ChildProfile profile;

  @override
  State<_PinRevealDialog> createState() => _PinRevealDialogState();
}

class _PinRevealDialogState extends State<_PinRevealDialog> {
  bool _copied = false;

  String get _portalUrl => childPortalUrl(widget.profile);

  Future<void> _copyUrl() async {
    await Clipboard.setData(ClipboardData(text: _portalUrl));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.profile.avatarColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    widget.profile.name[0].toUpperCase(),
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: widget.profile.avatarColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '¡${widget.profile.name} está listo!',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comparte el PIN o el enlace para que ${widget.profile.name} acceda a su portal personal.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.grey[500], height: 1.4),
              ),

              const SizedBox(height: 24),

              // PIN digits
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.profile.pin.split('').map((digit) {
                  return Container(
                    width: 52,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _kLavender,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
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

              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o comparte el enlace',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey[400]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
              ),

              const SizedBox(height: 14),

              // URL row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _kLavender,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 16, color: _kNavy),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _portalUrl,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: _kNavy,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _copyUrl,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _copied
                            ? const Icon(Icons.check_rounded,
                                key: ValueKey('check'),
                                size: 18,
                                color: Color(0xFF27AE60))
                            : const Icon(Icons.copy_rounded,
                                key: ValueKey('copy'), size: 18, color: _kNavy),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    '¡Entendido! Ir al Dashboard',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 15),
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
