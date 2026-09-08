// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';
import 'package:edu_play/features/settings/widgets/settings_notifications_section.dart';
import 'package:edu_play/features/settings/widgets/settings_security_section.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kBg = Color(0xFFF8F7FF);

/// Settings screen for the teacher role.
///
/// The parent-facing [SettingsPage] (`features/settings/pages/settings_page.dart`)
/// can't be reused as-is here: it hardcodes `EduPlayNavBar.parent`, a
/// "Mamá"/parent-name header, and a Subscription section built around the
/// family plan (child limits, session limits) — none of which apply to a
/// teacher account. This page reuses only the sections that are genuinely
/// role-agnostic (Notifications, Security/account-deletion) and adds its own
/// minimal chrome instead.
class TeacherSettingsPage extends StatelessWidget {
  const TeacherSettingsPage({super.key, required this.teacherName});

  final String teacherName;

  Future<void> _logout(BuildContext context) async {
    init();
    await sl<AccountSecurityRepository>().signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouterPaths.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kNavy),
        title: Text(
          'Ajustes',
          style: GoogleFonts.fredoka(
            color: _kNavy,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profe $teacherName',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 20),
              const SettingsNotificationsSection(forTeacher: true),
              const SizedBox(height: 20),
              const SettingsSecuritySection(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, color: _kRed),
                  label: Text(
                    'Cerrar sesión',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: _kRed,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _kRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
