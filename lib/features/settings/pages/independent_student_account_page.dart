import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/legal/pages/privacy_policy_page.dart';
import 'package:edu_play/features/settings/domain/entities/account_security_info.dart';
import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kBg = Color(0xFFF8F7FF);

/// Account page for a self-registered independent student (15+, own
/// email/password login — as opposed to a PIN-based child under a parent,
/// who has no account UI of their own). Mirrors the parent-facing "Zona de
/// peligro" in [SettingsSecuritySection], but branches the delete flow on
/// whether a guardian email was left at registration: if so, deletion
/// requires that guardian's approval instead of happening immediately.
class IndependentStudentAccountPage extends StatefulWidget {
  const IndependentStudentAccountPage({super.key});

  @override
  State<IndependentStudentAccountPage> createState() =>
      _IndependentStudentAccountPageState();
}

class _IndependentStudentAccountPageState
    extends State<IndependentStudentAccountPage> {
  final AccountSecurityRepository _repository = sl<AccountSecurityRepository>();
  bool _busy = false;
  bool _requestSent = false;

  AccountSecurityInfo? get _account => _repository.getCurrentAccount();

  Future<void> _startDeleteFlow() async {
    final guardianEmail = await _repository.getGuardianEmailOnFile();
    if (!mounted) return;

    final passwordCtrl = TextEditingController();
    var understood = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Eliminar mi cuenta',
              style: GoogleFonts.fredoka(color: _kRed, fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (guardianEmail != null) ...[
                    Text(
                      'Dejaste el correo de tu tutor ($guardianEmail) al registrarte. '
                      'Le enviaremos un mensaje pidiendo su aprobación — tu cuenta y tus datos '
                      'seguirán activos hasta que responda. Si no aprueba, no se elimina nada.',
                      style: GoogleFonts.nunito(fontSize: 13, height: 1.5),
                    ),
                  ] else ...[
                    Text(
                      'No dejaste el correo de un tutor, así que esta acción elimina tu cuenta '
                      'de inmediato y no se puede deshacer. Se elimina:',
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    _bullet('Tu cuenta y tu perfil de jugador.'),
                    _bullet('Tu progreso: puntos, racha, nivel e historial de partidas.'),
                  ],
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
                              guardianEmail != null
                                  ? 'Entiendo que se le pedirá aprobación a mi tutor antes de eliminar mi cuenta.'
                                  : 'Entiendo que esto elimina mi cuenta de inmediato y no se puede deshacer.',
                              style:
                                  GoogleFonts.nunito(fontSize: 12.5, height: 1.4),
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
                  guardianEmail != null ? 'Pedir aprobación' : 'Eliminar cuenta',
                  style: GoogleFonts.nunito(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      if (guardianEmail != null) {
        await _repository.requestDeletionWithGuardianConsent(
          password: passwordCtrl.text,
        );
        if (!mounted) return;
        setState(() {
          _requestSent = true;
          _busy = false;
        });
        return;
      }

      await _repository.deleteAccount(password: passwordCtrl.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouterPaths.login,
        (route) => false,
      );
    } on AccountSecurityException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'wrong-password'
          ? 'Contraseña incorrecta.'
          : 'No se pudo completar la solicitud.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.nunito()),
          backgroundColor: _kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _busy = false);
    }
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ', style: GoogleFonts.nunito(fontSize: 13, color: _kRed)),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.nunito(fontSize: 13, height: 1.4)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Mi cuenta',
            style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correo electrónico',
                          style: GoogleFonts.nunito(
                              fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text(account?.email ?? '-',
                          style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kNavy)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_requestSent)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5F5E3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solicitud enviada',
                            style: GoogleFonts.fredoka(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF27AE60),
                                fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Le pedimos a tu tutor que apruebe la eliminación de tu cuenta. '
                          'Mientras tanto, tu cuenta y tus datos siguen activos.',
                          style: GoogleFonts.nunito(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  )
                else
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
                            Text('Zona de peligro',
                                style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _kRed)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _startDeleteFlow,
                            icon: _busy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: _kRed, strokeWidth: 2))
                                : const Icon(Icons.delete_forever_rounded,
                                    size: 18),
                            label: Text(
                              _busy ? 'Procesando...' : 'Eliminar mi cuenta',
                              style:
                                  GoogleFonts.nunito(fontWeight: FontWeight.w700),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
