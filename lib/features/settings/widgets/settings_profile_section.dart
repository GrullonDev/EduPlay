import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';
import 'package:edu_play/features/settings/domain/repositories/settings_repository.dart';
import 'package:edu_play/features/settings/widgets/settings_section_card.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);

class SettingsProfileSection extends StatefulWidget {
  const SettingsProfileSection({super.key, SettingsRepository? repository})
      : _repository = repository;

  final SettingsRepository? _repository;

  @override
  State<SettingsProfileSection> createState() => SettingsProfileSectionState();
}

class SettingsProfileSectionState extends State<SettingsProfileSection> {
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

  AccountSecurityRepository get _securityRepository {
    init();
    return sl<AccountSecurityRepository>();
  }

  SettingsRepository get _repository {
    init();
    return widget._repository ?? sl<SettingsRepository>();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getParentProfile();
      if (profile != null) {
        _firstNameCtrl.text = profile.firstName;
        _lastNameCtrl.text = profile.lastName;
        _emailCtrl.text = profile.email;
        _ageCtrl.text = profile.age;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingProfile = false);
  }

  bool get _isProfileIncomplete =>
      _firstNameCtrl.text.trim().isEmpty || _lastNameCtrl.text.trim().isEmpty;

  Future<void> _saveProfile() async {
    setState(() {
      _savingProfile = true;
      _profileError = null;
      _profileSuccess = null;
    });
    try {
      await _repository.updateParentProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        age: _ageCtrl.text.trim(),
      );
      if (mounted) {
        setState(() => _profileSuccess = 'Perfil actualizado correctamente.');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _profileError = 'No se pudo guardar. Inténtalo de nuevo.',
        );
      }
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
      setState(() =>
          _pwError = 'La nueva contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (newPw != confirm) {
      setState(() => _pwError = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() => _savingPassword = true);
    try {
      await _securityRepository.changePassword(
        currentPassword: current,
        newPassword: newPw,
      );
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      if (mounted) {
        setState(() => _pwSuccess = 'Contraseña cambiada correctamente.');
      }
    } on AccountSecurityException catch (e) {
      String msg = 'No se pudo cambiar la contraseña.';
      if (e.code == 'wrong-password') {
        msg = 'La contraseña actual es incorrecta.';
      }
      if (e.code == 'weak-password') {
        msg = 'La nueva contraseña es demasiado débil.';
      }
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

    final isDesktop = ScreenSize.of(context).isDesktop;

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
        SettingsSectionCard(
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
                              ? '${_firstNameCtrl.text} ${_lastNameCtrl.text}'
                                  .trim()
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
                        child:
                            _FieldGroup(label: 'Nombre', ctrl: _firstNameCtrl)),
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
                                message: 'El correo no puede cambiarse aquí',
                                child: Icon(Icons.lock_outline_rounded,
                                    size: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _FieldGroup(label: 'Edad', ctrl: _ageCtrl)),
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
        SettingsSectionCard(
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
        const SettingsFooter(),
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
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;
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
                  fontSize: 13, color: textColor, fontWeight: FontWeight.w600),
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

class _PwField extends StatefulWidget {
  const _PwField({
    required this.label,
    required this.ctrl,
    required this.hint,
    // showPw param kept for backward compat but ignored — state manages it
    this.showPw = false,
  });
  final String label;
  final TextEditingController ctrl;
  final String hint;
  // ignore: unused_field
  final bool showPw;

  @override
  State<_PwField> createState() => _PwFieldState();
}

class _PwFieldState extends State<_PwField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(widget.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.ctrl,
          obscureText: !_visible,
          style: GoogleFonts.nunito(fontSize: 14),
          decoration: _sharedInputDec(widget.hint).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _visible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: Colors.grey[400],
              ),
              onPressed: () => setState(() => _visible = !_visible),
            ),
          ),
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
