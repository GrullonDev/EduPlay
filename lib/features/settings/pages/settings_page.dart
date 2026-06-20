import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/features/subscription/services/subscription_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';
import 'package:edu_play/shared/widgets/upgrade_prompt_dialog.dart';
import 'package:edu_play/features/subscription/services/stripe_service.dart';

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
        return const _NotificationsSection();
      case 3:
        return const _SecuritySection();
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
  // Profile fields
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  // Password fields
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _savingPassword = false;
  String? _profileError;
  String? _profileSuccess;
  String? _pwError;
  String? _pwSuccess;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingProfile = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(uid)
          .get();
      final data = doc.data() ?? {};
      _firstNameCtrl.text = (data['firstName'] as String?) ?? '';
      _lastNameCtrl.text = (data['lastName'] as String?) ?? '';
      _emailCtrl.text = (data['email'] as String?) ??
          FirebaseAuth.instance.currentUser?.email ??
          '';
      _ageCtrl.text = (data['age'] as String?) ?? '';
    } catch (_) {}
    if (mounted) setState(() => _loadingProfile = false);
  }

  bool get _isProfileIncomplete =>
      _firstNameCtrl.text.trim().isEmpty ||
      _lastNameCtrl.text.trim().isEmpty;

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() {
      _savingProfile = true;
      _profileError = null;
      _profileSuccess = null;
    });
    try {
      await FirebaseFirestore.instance.collection('parents').doc(uid).update({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'age': _ageCtrl.text.trim(),
      });
      if (mounted) setState(() => _profileSuccess = 'Perfil actualizado correctamente.');
    } catch (e) {
      if (mounted) setState(() => _profileError = 'No se pudo guardar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    setState(() {
      _pwError = null;
      _pwSuccess = null;
    });
    final newPw = _newPwCtrl.text;
    final confirm = _confirmPwCtrl.text;
    final current = _currentPwCtrl.text;

    if (newPw.length < 8) {
      setState(() => _pwError = 'La nueva contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (newPw != confirm) {
      setState(() => _pwError = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() => _savingPassword = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // Re-authenticate before sensitive op
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPw);
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      if (mounted) setState(() => _pwSuccess = 'Contraseña cambiada correctamente.');
    } on FirebaseAuthException catch (e) {
      String msg = 'No se pudo cambiar la contraseña.';
      if (e.code == 'wrong-password') msg = 'La contraseña actual es incorrecta.';
      if (e.code == 'weak-password') msg = 'La nueva contraseña es demasiado débil.';
      if (mounted) setState(() => _pwError = msg);
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(80),
          child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2),
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Incomplete profile banner ─────────────────────────────────────
        if (_isProfileIncomplete)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE08A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF856404), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tu perfil está incompleto. Añade tu nombre para que podamos personalizar tu experiencia.',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF856404),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Personal information card ──────────────────────────────────────
        _SettingsCard(
          icon: Icons.person_outline_rounded,
          title: 'Información personal',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + name row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kNavy.withValues(alpha: 0.10),
                    ),
                    child: Center(
                      child: _firstNameCtrl.text.isNotEmpty
                          ? Text(
                              _firstNameCtrl.text[0].toUpperCase(),
                              style: GoogleFonts.fredoka(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: _kNavy,
                              ),
                            )
                          : const Icon(Icons.person_rounded,
                              size: 36, color: _kNavy),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _firstNameCtrl.text.isNotEmpty ||
                                  _lastNameCtrl.text.isNotEmpty
                              ? '${_firstNameCtrl.text} ${_lastNameCtrl.text}'.trim()
                              : 'Sin nombre',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        Text(
                          _emailCtrl.text,
                          style: GoogleFonts.nunito(
                              fontSize: 13, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 20),

              // Form fields
              if (isDesktop)
                Row(
                  children: [
                    Expanded(
                        child: _FieldGroup(
                            label: 'Nombre', ctrl: _firstNameCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _FieldGroup(
                            label: 'Apellido', ctrl: _lastNameCtrl)),
                  ],
                )
              else ...[
                _FieldGroup(label: 'Nombre', ctrl: _firstNameCtrl),
                const SizedBox(height: 16),
                _FieldGroup(label: 'Apellido', ctrl: _lastNameCtrl),
              ],

              const SizedBox(height: 16),

              if (isDesktop)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Correo electrónico'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            readOnly: true,
                            style: GoogleFonts.nunito(
                                fontSize: 14, color: Colors.grey[500]),
                            decoration: _sharedInputDec('').copyWith(
                              fillColor: Colors.grey.shade50,
                              suffixIcon: const Tooltip(
                                message:
                                    'El correo no puede cambiarse aquí',
                                child: Icon(Icons.lock_outline_rounded,
                                    size: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _FieldGroup(label: 'Edad', ctrl: _ageCtrl)),
                  ],
                )
              else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Correo electrónico'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      readOnly: true,
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: Colors.grey[500]),
                      decoration: _sharedInputDec('').copyWith(
                        fillColor: Colors.grey.shade50,
                        suffixIcon: const Tooltip(
                          message: 'El correo no puede cambiarse aquí',
                          child: Icon(Icons.lock_outline_rounded,
                              size: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FieldGroup(label: 'Edad', ctrl: _ageCtrl),
              ],

              const SizedBox(height: 24),

              // Feedback messages
              if (_profileError != null)
                _FeedbackBanner(message: _profileError!, isError: true),
              if (_profileSuccess != null)
                _FeedbackBanner(message: _profileSuccess!, isError: false),
              if (_profileError != null || _profileSuccess != null)
                const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _savingProfile ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kNavy.withValues(alpha: 0.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _savingProfile
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Guardar cambios',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Change password card ───────────────────────────────────────────
        _SettingsCard(
          icon: Icons.lock_outline_rounded,
          title: 'Cambiar contraseña',
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  children: [
                    Expanded(
                      child: _PwField(
                        label: 'Contraseña actual',
                        ctrl: _currentPwCtrl,
                        hint: '••••••••',
                        showPw: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PwField(
                        label: 'Nueva contraseña',
                        ctrl: _newPwCtrl,
                        hint: 'Mín. 8 caracteres',
                        showPw: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PwField(
                        label: 'Confirmar contraseña',
                        ctrl: _confirmPwCtrl,
                        hint: '••••••••',
                        showPw: false,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _PwField(
                      label: 'Contraseña actual',
                      ctrl: _currentPwCtrl,
                      hint: '••••••••',
                      showPw: false,
                    ),
                    const SizedBox(height: 16),
                    _PwField(
                      label: 'Nueva contraseña',
                      ctrl: _newPwCtrl,
                      hint: 'Mín. 8 caracteres',
                      showPw: false,
                    ),
                    const SizedBox(height: 16),
                    _PwField(
                      label: 'Confirmar contraseña',
                      ctrl: _confirmPwCtrl,
                      hint: '••••••••',
                      showPw: false,
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              if (_pwError != null)
                _FeedbackBanner(message: _pwError!, isError: true),
              if (_pwSuccess != null)
                _FeedbackBanner(message: _pwSuccess!, isError: false),
              if (_pwError != null || _pwSuccess != null)
                const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _savingPassword ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kNavy.withValues(alpha: 0.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _savingPassword
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Cambiar contraseña',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        const _SettingsFooter(),
      ],
    );
  }
}

// ── Inline feedback banner ─────────────────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFFDE8E8) : const Color(0xFFD1FAE5);
    final textColor =
        isError ? const Color(0xFF9B1C1C) : const Color(0xFF065F46);
    final icon =
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
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
        const sessionLimit = Subscription.freeSessionLimit;

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
                            : [Colors.grey.shade100, Colors.grey.shade200],
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
                            color: Colors.white
                                .withValues(alpha: isPro ? 0.12 : 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPro
                                ? Icons.star_rounded
                                : Icons.lock_outline_rounded,
                            color: isPro ? Colors.white : Colors.grey.shade500,
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
                    const _UsageMeter(
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
                        onPressed: () async {
                          try {
                            await StripeService.startCheckout();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'No se pudo abrir el pago. Inténtalo de nuevo.',
                                    style: GoogleFonts.nunito(),
                                  ),
                                ),
                              );
                            }
                          }
                        },
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
  final int? used; // null triggers a FutureBuilder for child count
  final int limit;
  final bool isChildMeter;

  @override
  Widget build(BuildContext context) {
    if (isChildMeter) {
      return FutureBuilder<int>(
        future: ChildProfilesService.getProfiles().then((list) => list.length),
        builder: (ctx, snap) => _bar(label, snap.data ?? 0, limit),
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
                color:
                    atLimit ? const Color(0xFFE74C3C) : const Color(0xFF1E1B6A),
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
              atLimit ? const Color(0xFFE74C3C) : const Color(0xFF1E1B6A),
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

// ── Notifications section ─────────────────────────────────────────────────────

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _loading = true;
  bool _saving = false;

  // Toggle states — keys mirror Firestore fields
  bool _emailSessionComplete = true;
  bool _emailWeeklyDigest = true;
  bool _emailTips = false;
  bool _emailNewFeatures = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(uid)
          .get();
      final prefs = (doc.data()?['notificationPrefs'] as Map<String, dynamic>?) ?? {};
      setState(() {
        _emailSessionComplete = (prefs['emailSessionComplete'] as bool?) ?? true;
        _emailWeeklyDigest = (prefs['emailWeeklyDigest'] as bool?) ?? true;
        _emailTips = (prefs['emailTips'] as bool?) ?? false;
        _emailNewFeatures = (prefs['emailNewFeatures'] as bool?) ?? true;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('parents').doc(uid).update({
        'notificationPrefs': {
          'emailSessionComplete': _emailSessionComplete,
          'emailWeeklyDigest': _emailWeeklyDigest,
          'emailTips': _emailTips,
          'emailNewFeatures': _emailNewFeatures,
        },
      });
    } catch (_) {}
    if (mounted) setState(() => _saving = false);
  }

  void _toggle(String field, bool value) {
    setState(() {
      switch (field) {
        case 'emailSessionComplete':
          _emailSessionComplete = value;
        case 'emailWeeklyDigest':
          _emailWeeklyDigest = value;
        case 'emailTips':
          _emailTips = value;
        case 'emailNewFeatures':
          _emailNewFeatures = value;
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsCard(
          icon: Icons.notifications_none_rounded,
          title: 'Notificaciones',
          child: Column(
            children: [
              _NotifGroup(
                title: 'CORREO ELECTRÓNICO',
                items: [
                  _NotifItem(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF27AE60),
                    title: 'Sesión completada',
                    subtitle: 'Recibe un email cuando tu hijo/a termine una sesión de práctica.',
                    value: _emailSessionComplete,
                    onChanged: (v) => _toggle('emailSessionComplete', v),
                  ),
                  _NotifItem(
                    icon: Icons.calendar_today_rounded,
                    iconColor: const Color(0xFF3498DB),
                    title: 'Resumen semanal',
                    subtitle: 'Un resumen del progreso de tus hijos cada lunes.',
                    value: _emailWeeklyDigest,
                    onChanged: (v) => _toggle('emailWeeklyDigest', v),
                  ),
                  _NotifItem(
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: const Color(0xFFF39C12),
                    title: 'Consejos de aprendizaje',
                    subtitle: 'Artículos y sugerencias para mejorar el aprendizaje en casa.',
                    value: _emailTips,
                    onChanged: (v) => _toggle('emailTips', v),
                  ),
                  _NotifItem(
                    icon: Icons.new_releases_outlined,
                    iconColor: _kNavy,
                    title: 'Novedades de EduPlay',
                    subtitle: 'Nuevos juegos, funciones y actualizaciones de la plataforma.',
                    value: _emailNewFeatures,
                    onChanged: (v) => _toggle('emailNewFeatures', v),
                  ),
                ],
              ),
              if (_saving) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: _kNavy, strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Guardando preferencias...',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 40),
        const _SettingsFooter(),
      ],
    );
  }
}

class _NotifGroup extends StatelessWidget {
  const _NotifGroup({required this.title, required this.items});
  final String title;
  final List<_NotifItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: _kNavy.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: item,
            )),
      ],
    );
  }
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _kNavy,
          ),
        ],
      ),
    );
  }
}

// ── Security section ──────────────────────────────────────────────────────────

class _SecuritySection extends StatefulWidget {
  const _SecuritySection();

  @override
  State<_SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<_SecuritySection> {
  bool _deleting = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day}/${dt.month}/${dt.year} a las ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get _providerLabel {
    final providers = _user?.providerData.map((p) => p.providerId).toList() ?? [];
    if (providers.contains('google.com')) return 'Google';
    if (providers.contains('microsoft.com')) return 'Microsoft';
    return 'Correo electrónico';
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final passwordCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Eliminar cuenta',
          style: GoogleFonts.fredoka(color: _kRed, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta acción eliminará permanentemente tu cuenta y todos los datos asociados (perfiles de niños, sesiones de práctica, etc.). Esta acción no se puede deshacer.',
              style: GoogleFonts.nunito(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Introduce tu contraseña para confirmar:',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              style: GoogleFonts.nunito(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tu contraseña actual',
                hintStyle:
                    GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar cuenta',
              style: GoogleFonts.nunito(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);

      // Delete Firestore data
      final db = FirebaseFirestore.instance;
      final uid = user.uid;
      // Delete child profiles subcollection
      final profilesSnap = await db
          .collection('parents')
          .doc(uid)
          .collection('child_profiles')
          .get();
      for (final doc in profilesSnap.docs) {
        await doc.reference.delete();
      }
      // Delete parent doc
      await db.collection('parents').doc(uid).delete();
      // Delete subscription
      await db.collection('subscriptions').doc(uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      // AuthGate will handle redirect
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'No se pudo eliminar la cuenta.';
      if (e.code == 'wrong-password') {
        msg = 'Contraseña incorrecta.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.nunito()),
          backgroundColor: _kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final meta = user?.metadata;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Account info card ──────────────────────────────────────────────
        _SettingsCard(
          icon: Icons.shield_outlined,
          title: 'Seguridad de la cuenta',
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Correo electrónico',
                value: user?.email ?? '—',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.login_rounded,
                label: 'Método de acceso',
                value: _providerLabel,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Cuenta creada',
                value: _formatDate(meta?.creationTime?.toLocal()),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Último inicio de sesión',
                value: _formatDate(meta?.lastSignInTime?.toLocal()),
              ),
              const SizedBox(height: 20),
              // Verified badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: user?.emailVerified == true
                      ? const Color(0xFFD5F5E3)
                      : const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      user?.emailVerified == true
                          ? Icons.verified_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color: user?.emailVerified == true
                          ? const Color(0xFF27AE60)
                          : const Color(0xFF856404),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      user?.emailVerified == true
                          ? 'Correo verificado'
                          : 'Correo no verificado',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: user?.emailVerified == true
                            ? const Color(0xFF27AE60)
                            : const Color(0xFF856404),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Active sessions note ───────────────────────────────────────────
        _SettingsCard(
          icon: Icons.devices_rounded,
          title: 'Sesiones activas',
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kLavender,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.computer_rounded,
                        color: _kNavy, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesión actual',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        Text(
                          'EduPlay Web · Activo ahora',
                          style: GoogleFonts.nunito(
                              fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5F5E3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Activo',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF27AE60),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: Text(
                    'Cerrar todas las sesiones',
                    style:
                        GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kNavy,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Danger zone ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kRed.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: _kRed),
                  const SizedBox(width: 10),
                  Text(
                    'Zona de peligro',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _kRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Estas acciones son permanentes e irreversibles. Procede con precaución.',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleting
                      ? null
                      : () => _confirmDeleteAccount(context),
                  icon: _deleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: _kRed, strokeWidth: 2))
                      : const Icon(Icons.delete_forever_rounded, size: 18),
                  label: Text(
                    _deleting ? 'Eliminando...' : 'Eliminar mi cuenta',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kRed,
                    side: const BorderSide(color: _kRed),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        const _SettingsFooter(),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
        Icon(icon, size: 16, color: _kNavy.withValues(alpha: 0.5)),
        const SizedBox(width: 10),
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
        ),
      ],
    );
  }
}
