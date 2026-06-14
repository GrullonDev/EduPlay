import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Child PIN Entry Page ───────────────────────────────────────────────────────
// A full-screen numpad where a child enters their 4-digit PIN to access their
// personal student dashboard. Validates against ChildProfilesService (local
// SharedPreferences). No backend needed.

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kRed = Color(0xFFC0392B);
const _kLavender = Color(0xFFEEEDF8);

class ChildPinPage extends StatefulWidget {
  const ChildPinPage({super.key});

  @override
  State<ChildPinPage> createState() => _ChildPinPageState();
}

class _ChildPinPageState extends State<ChildPinPage>
    with SingleTickerProviderStateMixin {
  final List<String> _digits = [];
  bool _loading = false;
  bool _hasError = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String d) {
    if (_digits.length >= 4 || _loading) return;
    setState(() {
      _hasError = false;
      _digits.add(d);
    });
    if (_digits.length == 4) _validate();
  }

  void _onDelete() {
    if (_digits.isEmpty || _loading) return;
    setState(() {
      _hasError = false;
      _digits.removeLast();
    });
  }

  Future<void> _validate() async {
    setState(() => _loading = true);
    final pin = _digits.join();
    final profile = await ChildProfilesService.findByPin(pin);
    if (!mounted) return;

    if (profile == null) {
      await _shakeCtrl.forward(from: 0);
      setState(() {
        _loading = false;
        _hasError = true;
        _digits.clear();
      });
    } else {
      // Navigate to student dashboard, passing the profile
      Navigator.of(context).pushReplacementNamed(
        RouterPaths.studentDashboard,
        arguments: profile,
      );
    }
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
              // Back button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70, size: 20),
                ),
              ),

              // Decorative circles
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -40,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),

              // Main content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/icon
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
                          child: Icon(
                            Icons.child_friendly_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        '¡Hola, explorador!',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escribe tu código secreto',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // PIN dots
                      AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(_shakeAnim.value, 0),
                          child: child,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (i) {
                            final filled = i < _digits.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: filled
                                    ? (_hasError ? _kRed : Colors.white)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _hasError
                                      ? _kRed.withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Error message
                      AnimatedOpacity(
                        opacity: _hasError ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Código incorrecto. Inténtalo de nuevo.',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: const Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Numpad
                      _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : _NumPad(
                              onDigit: _onDigit,
                              onDelete: _onDelete,
                            ),
                    ],
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

// ── Numpad ─────────────────────────────────────────────────────────────────────

class _NumPad extends StatelessWidget {
  const _NumPad({
    required this.onDigit,
    required this.onDelete,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'DEL'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  if (key.isEmpty) return const SizedBox(width: 70 + 24);
                  if (key == 'DEL') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _NumKey(
                        label: '',
                        icon: Icons.backspace_outlined,
                        onTap: onDelete,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _NumKey(
                      label: key,
                      onTap: () => onDigit(key),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NumKey extends StatefulWidget {
  const _NumKey({required this.label, this.icon, required this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Center(
          child: widget.icon != null
              ? Icon(widget.icon, color: Colors.white, size: 22)
              : Text(
                  widget.label,
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
