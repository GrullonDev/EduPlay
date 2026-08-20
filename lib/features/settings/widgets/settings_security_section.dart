// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/legal/pages/privacy_policy_page.dart';
import 'package:edu_play/features/settings/domain/entities/account_security_info.dart';
import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';
import 'package:edu_play/features/settings/widgets/settings_section_card.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kLavender = Color(0xFFEEEDF8);

class SettingsSecuritySection extends StatefulWidget {
  const SettingsSecuritySection(
      {super.key, AccountSecurityRepository? repository})
      : _repository = repository;

  final AccountSecurityRepository? _repository;

  @override
  State<SettingsSecuritySection> createState() =>
      SettingsSecuritySectionState();
}

class SettingsSecuritySectionState extends State<SettingsSecuritySection> {
  bool _deleting = false;

  AccountSecurityRepository get _repository {
    init();
    return widget._repository ?? sl<AccountSecurityRepository>();
  }

  AccountSecurityInfo? get _account => _repository.getCurrentAccount();

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day}/${dt.month}/${dt.year} a las ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final passwordCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var understood = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Eliminar cuenta',
                style: GoogleFonts.fredoka(color: _kRed, fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Esta acción es permanente e irreversible. Al continuar, se elimina de inmediato:',
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    const _DeletionBullet(
                        'Tu cuenta de padre/madre y tus datos de perfil.'),
                    const _DeletionBullet(
                        'TODOS los perfiles de tus hijos registrados en esta cuenta.'),
                    const _DeletionBullet(
                        'El progreso de cada hijo: puntos, racha, nivel e historial de partidas.'),
                    const _DeletionBullet(
                        'Sesiones de práctica, retos asignados y tu suscripción.'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).push(
                        MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyPage()),
                      ),
                      child: Text(
                        'Leer política de privacidad →',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () =>
                          setDialogState(() => understood = !understood),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: understood,
                            activeColor: _kRed,
                            onChanged: (v) =>
                                setDialogState(() => understood = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Entiendo que esto elimina permanentemente mi cuenta y la de mis hijos, y que no se puede deshacer.',
                                style: GoogleFonts.nunito(
                                    fontSize: 12.5, height: 1.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                        hintStyle: GoogleFonts.nunito(
                            fontSize: 14, color: Colors.grey[400]),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text('Cancelar',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    disabledBackgroundColor: _kRed.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: understood
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  child: Text(
                    'Eliminar cuenta',
                    style: GoogleFonts.nunito(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    setState(() => _deleting = true);
    try {
      await _repository.deleteAccount(password: passwordCtrl.text);

      // Navigate to login after deletion
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouterPaths.login,
        (route) => false,
      );
    } on AccountSecurityException catch (e) {
      if (!context.mounted) return;
      String msg = 'No se pudo eliminar la cuenta.';
      if (e.code == 'wrong-password') {
        msg = 'Contraseña incorrecta.';
      }
      if (!context.mounted) return;
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
    final account = _account;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Account info card ──────────────────────────────────────────────
        SettingsSectionCard(
          icon: Icons.shield_outlined,
          title: 'Seguridad de la cuenta',
          child: Column(
            children: [
              SettingsInfoRow(
                icon: Icons.email_outlined,
                label: 'Correo electrónico',
                value: account?.email ?? '-',
              ),
              const SizedBox(height: 12),
              SettingsInfoRow(
                icon: Icons.login_rounded,
                label: 'Método de acceso',
                value: account?.providerLabel ?? '-',
              ),
              const SizedBox(height: 12),
              SettingsInfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Cuenta creada',
                value: _formatDate(account?.creationTime?.toLocal()),
              ),
              const SizedBox(height: 12),
              SettingsInfoRow(
                icon: Icons.access_time_rounded,
                label: 'Último inicio de sesión',
                value: _formatDate(account?.lastSignInTime?.toLocal()),
              ),
              const SizedBox(height: 20),
              // Verified badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: account?.emailVerified == true
                      ? const Color(0xFFD5F5E3)
                      : const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      account?.emailVerified == true
                          ? Icons.verified_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color: account?.emailVerified == true
                          ? const Color(0xFF27AE60)
                          : const Color(0xFF856404),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      account?.emailVerified == true
                          ? 'Correo verificado'
                          : 'Correo no verificado',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: account?.emailVerified == true
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
        SettingsSectionCard(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    await _repository.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouterPaths.login,
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: Text(
                    'Cerrar todas las sesiones',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
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
                  const Icon(Icons.warning_amber_rounded,
                      size: 20, color: _kRed),
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
                  onPressed:
                      _deleting ? null : () => _confirmDeleteAccount(context),
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
        const SettingsFooter(),
      ],
    );
  }
}

class _DeletionBullet extends StatelessWidget {
  const _DeletionBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ',
              style: GoogleFonts.nunito(fontSize: 13, color: _kRed)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
