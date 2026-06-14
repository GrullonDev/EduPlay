import 'dart:math' show sin, pi;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);

// ─────────────────────────────────────────────────────────────────────────────

/// Child-facing page. Opened when the child clicks the session link
/// (e.g. http://app.edu-play.com/practice-session?pin=123456).
/// Pre-fills the PIN from the URL query string if present.
class SessionEntryPage extends StatefulWidget {
  const SessionEntryPage({super.key});

  @override
  State<SessionEntryPage> createState() => _SessionEntryPageState();
}

class _SessionEntryPageState extends State<SessionEntryPage>
    with SingleTickerProviderStateMixin {
  final List<String> _digits = [];
  bool _checking = false;
  bool _error = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  static const _kPinLength = 6;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    // Pre-fill PIN from URL query params (Flutter web)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = Uri.base;
      final pin = uri.queryParameters['pin'];
      if (pin != null && pin.length == _kPinLength) {
        setState(() {
          _digits.addAll(pin.split(''));
        });
        _submitPin(pin);
      }
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPin(String pin) async {
    setState(() {
      _checking = true;
      _error = false;
    });

    // Children have no Firebase account. Sign in anonymously so Firestore
    // Security Rules allow reading active sessions and writing game scores.
    // If the parent happens to be on the same device we keep their session.
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      try {
        await auth.signInAnonymously();
      } catch (_) {
        // Proceed anyway — the query may still work if rules allow public reads.
      }
    }

    final session = await PracticeSessionsService.findByPin(pin);
    if (!mounted) return;
    if (session != null) {
      Navigator.pushReplacementNamed(
        context,
        RouterPaths.practiceKiosk,
        arguments: session,
      );
    } else {
      setState(() {
        _checking = false;
        _error = true;
        _digits.clear();
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  void _addDigit(String d) {
    if (_digits.length >= _kPinLength || _checking) return;
    setState(() {
      _error = false;
      _digits.add(d);
    });
    if (_digits.length == _kPinLength) {
      _submitPin(_digits.join());
    }
  }

  void _delete() {
    if (_digits.isEmpty || _checking) return;
    setState(() => _digits.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kNavyDark, _kNavy, Color(0xFF2D2A8A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(child: _centeredContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(
              'EduPlay',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Practice Session',
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _centeredContent() => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rocket illustration
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🚀', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter Session PIN',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your parent shared a 6-digit PIN\nto start your practice session',
                style: GoogleFonts.nunito(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    sin(_shakeAnim.value * 3 * pi) * 10,
                    0,
                  ),
                  child: child,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_kPinLength, (i) {
                    final filled = i < _digits.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 44,
                      height: 52,
                      decoration: BoxDecoration(
                        color: filled
                            ? (_error
                                ? const Color(0xFFC0392B)
                                : Colors.white)
                            : Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _error
                              ? const Color(0xFFC0392B)
                              : Colors.white.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: filled
                          ? Text(
                              _digits[i],
                              style: GoogleFonts.fredoka(
                                fontSize: 24,
                                color: _error ? Colors.white : _kNavy,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),
              AnimatedOpacity(
                opacity: _error ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'Invalid PIN — please try again',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFFFF6E6C),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Numpad
              if (_checking)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else
                _NumPad(onDigit: _addDigit, onDelete: _delete),
            ],
          ),
        ),
      );
}

// ── Numpad ────────────────────────────────────────────────────────────────────

class _NumPad extends StatelessWidget {
  const _NumPad({required this.onDigit, required this.onDelete});

  final void Function(String) onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              if (k.isEmpty) return const SizedBox(width: 72, height: 72);
              return _NumKey(
                label: k,
                onTap: () {
                  if (k == '⌫') {
                    onDelete();
                  } else {
                    onDigit(k);
                  }
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _NumKey extends StatefulWidget {
  const _NumKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.all(6),
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: widget.label == '⌫'
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.fredoka(
              fontSize: widget.label == '⌫' ? 20 : 26,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

