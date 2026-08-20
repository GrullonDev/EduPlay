// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Age Gate ────────────────────────────────────────────────────────────────
// Shown when a child doesn't have a PIN yet. Asks their age to decide who
// registers them: a parent (under 15) or themselves (15+).

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);

/// Age at/above which a child may create their own account instead of
/// needing a parent to register them.
const kSelfRegistrationMinAge = 15;

enum _Stage { asking, needsParent }

class AgeGatePage extends StatefulWidget {
  const AgeGatePage({super.key});

  @override
  State<AgeGatePage> createState() => _AgeGatePageState();
}

class _AgeGatePageState extends State<AgeGatePage> {
  _Stage _stage = _Stage.asking;
  int _age = 10;

  void _continue() {
    if (_age >= kSelfRegistrationMinAge) {
      Navigator.of(context).pushNamed(
        RouterPaths.registerStudent,
        arguments: _age,
      );
    } else {
      setState(() => _stage = _Stage.needsParent);
    }
  }

  void _goToParentRegistration() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouterPaths.registerParents,
      (route) => false,
    );
  }

  void _playAsGuest() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouterPaths.studentDashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kNavy, _kNavyDark],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (Navigator.canPop(context))
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 20),
                  ),
                ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: _stage == _Stage.asking
                        ? _AskingAge(
                            age: _age,
                            onAgeChanged: (v) => setState(() => _age = v),
                            onContinue: _continue,
                            onPlayAsGuest: _playAsGuest,
                          )
                        : _NeedsParent(
                            onRegisterWithParent: _goToParentRegistration,
                            onBackToPin: () =>
                                setState(() => _stage = _Stage.asking),
                            onPlayAsGuest: _playAsGuest,
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

class _AskingAge extends StatelessWidget {
  const _AskingAge({
    required this.age,
    required this.onAgeChanged,
    required this.onContinue,
    required this.onPlayAsGuest,
  });

  final int age;
  final ValueChanged<int> onAgeChanged;
  final VoidCallback onContinue;
  final VoidCallback onPlayAsGuest;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(Icons.cake_rounded, size: 34, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¿Cuántos años tienes?',
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Así sabemos cómo ayudarte a registrarte',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            '$age años',
            style: GoogleFonts.fredoka(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _kCoral,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayColor: _kCoral.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: age.toDouble(),
            min: 4,
            max: 18,
            divisions: 14,
            label: '$age años',
            onChanged: (v) => onAgeChanged(v.round()),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kCoral,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Continuar',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        GestureDetector(
          onTap: onPlayAsGuest,
          child: Text(
            'Jugar como invitado →',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _NeedsParent extends StatelessWidget {
  const _NeedsParent({
    required this.onRegisterWithParent,
    required this.onBackToPin,
    required this.onPlayAsGuest,
  });

  final VoidCallback onRegisterWithParent;
  final VoidCallback onBackToPin;
  final VoidCallback onPlayAsGuest;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(Icons.family_restroom_rounded,
                size: 34, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Pide ayuda a tu\npapá o mamá',
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Un adulto necesita crear tu cuenta para que puedas jugar y guardar tu progreso.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onRegisterWithParent,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kCoral,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Registrarme con mi papá o mamá',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: onBackToPin,
          child: Text(
            'Ya tengo un código, volver',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: onPlayAsGuest,
          child: Text(
            'Jugar como invitado →',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }
}
