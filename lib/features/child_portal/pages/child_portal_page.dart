import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/utils/child_portal_link.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Persistence key ───────────────────────────────────────────────────────────

const _kPinKey = 'edu_play_child_pin';

// ── Color tokens ──────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kLavender = Color(0xFFEEEDF8);
const _kBg = Color(0xFFF8F7FF);

// ── Child Portal Page ─────────────────────────────────────────────────────────
//
// Accessible at /#/child-portal
//
// Entry modes:
//   1. With PIN (via route args or URL fragment query param):
//      Validates PIN → shows the child's profile + active practice sessions.
//   2. Without PIN (guest browse):
//      Shows a friendly "Ask your parent to create a profile" screen.

class ChildPortalPage extends StatefulWidget {
  const ChildPortalPage({super.key, this.pinFromArgs});

  /// PIN passed programmatically via Navigator arguments.
  final String? pinFromArgs;

  @override
  State<ChildPortalPage> createState() => _ChildPortalPageState();
}

class _ChildPortalPageState extends State<ChildPortalPage> {
  _PortalState _state = const _Loading();
  bool _pinError = false; // true when last PIN lookup failed

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  Future<void> _init() async {
    // Priority 1: profile data embedded in URL (new-style share link).
    final urlProfile = childProfileFromUrl();
    final urlPin = widget.pinFromArgs ?? pinFromUrl();

    if (urlProfile != null && urlPin != null) {
      // Persist so the child can return without the full link.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPinKey, urlPin);
      final sessions = await _loadSessions(urlProfile.id);
      if (!mounted) return;
      setState(
          () => _state = _ProfileView(profile: urlProfile, sessions: sessions));
      return;
    }

    // Priority 2: PIN passed via route args / URL without embedded data.
    if (urlPin != null && urlPin.isNotEmpty) {
      await _resolvePin(urlPin);
      return;
    }

    // Priority 3: cached PIN from a previous visit (returning child).
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_kPinKey);
    if (savedPin != null && savedPin.isNotEmpty) {
      await _resolvePin(savedPin, fromCache: true);
      return;
    }

    // No PIN anywhere → show welcome (PIN entry + guest option).
    if (mounted) setState(() => _state = const _Welcome());
  }

  // ── PIN resolution ─────────────────────────────────────────────────────────

  Future<void> _resolvePin(String pin, {bool fromCache = false}) async {
    if (mounted) setState(() => _state = const _Loading());

    // Ensure anonymous auth so Firestore reads are permitted.
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance
            .signInAnonymously()
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        if (mounted) setState(() => _state = const _Welcome());
        return;
      }
    }

    final profile = await ChildProfilesService.findByPinGlobal(pin);
    if (!mounted) return;

    if (profile == null) {
      // Cached PIN no longer valid (profile deleted) → clear and show welcome.
      if (fromCache) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_kPinKey);
      }
      setState(() {
        _pinError = !fromCache; // show error only for manually typed PINs
        _state = const _Welcome();
      });
      return;
    }

    // Persist PIN for future visits.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPinKey, pin);

    final sessions = await _loadSessions(profile.id);
    if (!mounted) return;
    setState(() => _state = _ProfileView(profile: profile, sessions: sessions));
  }

  // ── Callbacks used by child views ──────────────────────────────────────────

  void _onPinEntered(String pin) {
    _pinError = false;
    _resolvePin(pin);
  }

  void _onGuest() => setState(() => _state = const _Guest());
  void _onBackToWelcome() => setState(() => _state = const _Welcome());

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<List<PracticeSession>> _loadSessions(String childId) async {
    try {
      return await PracticeSessionsService.getActiveSessionsByChildId(childId);
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (_state) {
          _Loading() => const _LoadingView(),
          _Welcome() => _WelcomeView(
              onPinSubmitted: _onPinEntered,
              onGuest: _onGuest,
              hadError: _pinError,
            ),
          _Guest() => _GuestView(onBack: _onBackToWelcome),
          _ProfileView(profile: final p, sessions: final s) =>
            _ChildProfileView(profile: p, sessions: s),
        },
      ),
    );
  }
}

// ── State types ───────────────────────────────────────────────────────────────

sealed class _PortalState {
  const _PortalState();
}

class _Loading extends _PortalState {
  const _Loading();
}

/// First-time / no saved PIN — shows PIN entry + guest option.
class _Welcome extends _PortalState {
  const _Welcome();
}

/// Explicit guest mode — child chose to skip PIN entry.
class _Guest extends _PortalState {
  const _Guest();
}

class _ProfileView extends _PortalState {
  const _ProfileView({required this.profile, required this.sessions});
  final ChildProfile profile;
  final List<PracticeSession> sessions;
}

// ── Loading view ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2),
    );
  }
}

// ── Welcome view (home screen with inline PIN entry) ──────────────────────────

class _WelcomeView extends StatefulWidget {
  const _WelcomeView({
    required this.onPinSubmitted,
    required this.onGuest,
    this.hadError = false,
  });
  final ValueChanged<String> onPinSubmitted;
  final VoidCallback onGuest;
  final bool hadError;

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  late bool _hasError;

  @override
  void initState() {
    super.initState();
    _hasError = widget.hadError;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onDigit(int idx, String value) {
    if (_hasError) setState(() => _hasError = false);
    if (value.isEmpty) {
      // Backspace
      if (idx > 0) _focusNodes[idx - 1].requestFocus();
      setState(() {});
      return;
    }
    // Only keep last digit in case of extra input
    final digit = value[value.length - 1];
    if (!RegExp(r'[0-9]').hasMatch(digit)) {
      _controllers[idx].clear();
      return;
    }
    _controllers[idx].text = digit;
    _controllers[idx].selection = TextSelection.fromPosition(
      const TextPosition(offset: 1),
    );
    setState(() {});

    if (idx < 3) {
      _focusNodes[idx + 1].requestFocus();
    } else {
      // All 4 digits filled
      _focusNodes[3].unfocus();
      final pin = _pin;
      if (pin.length == 4) widget.onPinSubmitted(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _FunBackground()),
        SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mascot
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text('🚀', style: TextStyle(fontSize: 44)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            '¡Bienvenido a EduPlay!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // "Ask adult" banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text('👋',
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Pide a un adulto que cree un PIN para ti,\n¡o ingrésalo si ya tienes uno!',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Game previews
                          const _GamePreviewRow(),
                          const SizedBox(height: 36),

                          // PIN label
                          Text(
                            'INGRESA TU PIN',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 4-box PIN entry
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (i) {
                              final filled = _controllers[i].text.isNotEmpty;
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                width: 56,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: _hasError
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.white.withValues(
                                          alpha: filled ? 0.18 : 0.07),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _hasError
                                        ? Colors.red.withValues(alpha: 0.6)
                                        : Colors.white.withValues(
                                            alpha: filled ? 0.55 : 0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    style: GoogleFonts.fredoka(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    obscureText: filled,
                                    obscuringCharacter: '●',
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    onChanged: (v) => _onDigit(i, v),
                                  ),
                                ),
                              );
                            }),
                          ),

                          if (_hasError) ...[
                            const SizedBox(height: 8),
                            Text(
                              'PIN incorrecto. Pide a tu papá o mamá que lo revise.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: const Color(0xFFFF6E6C),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Skip to guest
                          TextButton(
                            onPressed: widget.onGuest,
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Colors.white.withValues(alpha: 0.55),
                            ),
                            child: Text(
                              'Continuar sin PIN  →',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EduPlay · Aprende jugando',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RouterPaths.login),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '¿Eres padre o profesor?  Entrar →',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ), // SafeArea
      ],
    );
  }
}

// ── Guest view (explicit guest mode after skipping PIN) ───────────────────────

class _GuestView extends StatelessWidget {
  const _GuestView({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _FunBackground()),
        SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70, size: 20),
                ),
              ),

              // Content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text('🌟', style: TextStyle(fontSize: 44)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Explorando como invitado',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '¡Echa un vistazo a los juegos!\nPide a tu papá o mamá que cree un perfil para guardar tu progreso.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const _GamePreviewRow(),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                context, RouterPaths.gamesCatalog),
                            // no profile arg → guest mode in catalog
                            icon: const Icon(Icons.grid_view_rounded, size: 18),
                            label: Text(
                              'Ver todos los juegos',
                              style: GoogleFonts.fredoka(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kCoral,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EduPlay · Aprende jugando',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RouterPaths.login),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '¿Eres padre o profesor?  Entrar →',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ), // SafeArea
      ],
    );
  }
}

class _GamePreviewRow extends StatelessWidget {
  const _GamePreviewRow();

  static const _previews = [
    _SubjectData(
      icon: '🔢',
      label: 'Matemáticas',
      tag: 'POPULAR',
      gradientA: Color(0xFF1565C0),
      gradientB: Color(0xFF42A5F5),
      accentColor: Color(0xFF64B5F6),
    ),
    _SubjectData(
      icon: '📖',
      label: 'Palabras',
      tag: 'NUEVO',
      gradientA: Color(0xFF6A1B9A),
      gradientB: Color(0xFFAB47BC),
      accentColor: Color(0xFFCE93D8),
    ),
    _SubjectData(
      icon: '🌍',
      label: 'Ciencias',
      tag: 'TOP',
      gradientA: Color(0xFF1B5E20),
      gradientB: Color(0xFF43A047),
      accentColor: Color(0xFF81C784),
    ),
    _SubjectData(
      icon: '🎨',
      label: 'Arte',
      tag: '🔥',
      gradientA: Color(0xFFE65100),
      gradientB: Color(0xFFFFA726),
      accentColor: Color(0xFFFFCC80),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: _previews.map((p) => _SubjectCard(data: p)).toList(),
    );
  }
}

class _SubjectData {
  const _SubjectData({
    required this.icon,
    required this.label,
    required this.tag,
    required this.gradientA,
    required this.gradientB,
    required this.accentColor,
  });
  final String icon;
  final String label;
  final String tag;
  final Color gradientA;
  final Color gradientB;
  final Color accentColor;
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.data});
  final _SubjectData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.gradientA, data.gradientB],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.gradientB.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shine overlay in top-right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          // Tag badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data.tag,
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.95),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          // Icon + label
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(data.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                Text(
                  data.label,
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
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

// ── Authenticated child profile view ─────────────────────────────────────────

class _ChildProfileView extends StatelessWidget {
  const _ChildProfileView({
    required this.profile,
    required this.sessions,
  });

  final ChildProfile profile;
  final List<PracticeSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header band ──────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kNavy, Color(0xFF3A36A0)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: [
                  // Top row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(
                                context, RouterPaths.childPortal);
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                      ),
                      const Spacer(),
                      // Points badge — sum of all session scores
                      _PortalPointsBadge(sessions: sessions),
                      const SizedBox(width: 12),
                      // Catalog shortcut
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouterPaths.gamesCatalog,
                          arguments: profile,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.grid_view_rounded,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                'Juegos',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: profile.avatarColor.withValues(alpha: 0.25),
                      border: Border.all(
                        color: profile.avatarColor.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    '¡Hola, ${profile.name}! 👋',
                    style: GoogleFonts.fredoka(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.levelLabel} · ${profile.focusSubject}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Level progress bar
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Progreso de nivel',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(profile.levelProgress * 100).toInt()}%',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: profile.levelProgress,
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              profile.avatarColor,
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

        // ── Session list ─────────────────────────────────────────────────────
        Expanded(
          child: sessions.isEmpty
              ? _EmptySessionsView(childName: profile.name, profile: profile)
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Sesiones activas',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca una sesión para comenzar a jugar',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sessions.map(
                      (s) => _SessionCard(
                        session: s,
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouterPaths.practiceKiosk,
                          arguments: s,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptySessionsView extends StatelessWidget {
  const _EmptySessionsView({required this.childName, this.profile});
  final String childName;
  final ChildProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              '¡Todo al día, $childName!',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tu papá o mamá todavía no ha creado\nuna sesión de práctica para ti.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                RouterPaths.gamesCatalog,
                arguments: profile,
              ),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(
                'Explorar juegos',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kNavy,
                side: BorderSide(color: _kNavy.withValues(alpha: 0.3)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final PracticeSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = session.completedCount;
    final total = session.totalCount;
    final progress = session.progressFraction;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: const Center(
                    child: Icon(Icons.sports_esports_rounded,
                        color: _kNavy, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesión de práctica',
                        style: GoogleFonts.fredoka(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                      Text(
                        '$completed de $total juegos completados',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kCoral,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '¡Jugar!',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: _kLavender,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1 ? const Color(0xFF27AE60) : _kCoral,
                ),
              ),
            ),
            if (progress == 1) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF27AE60), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '¡Sesión completada! 🎉',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF27AE60),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Fun background ────────────────────────────────────────────────────────────
/// Replaces the flat navy gradient with colorful radial glow blobs and
/// floating decorative stars/dots, giving both welcome screens a playful feel.
class _FunBackground extends StatelessWidget {
  const _FunBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient — richer than flat navy
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF16125C), Color(0xFF231B72), Color(0xFF12104A)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // ── Colored glow blobs ──
        // Coral blob — top right
        const Positioned(
          top: -100,
          right: -80,
          child: _GlowBlob(
            size: 340,
            color: Color(0xFFFF6E6C),
            opacity: 0.18,
          ),
        ),
        // Teal blob — bottom left
        const Positioned(
          bottom: -120,
          left: -90,
          child: _GlowBlob(
            size: 380,
            color: Color(0xFF00D2D3),
            opacity: 0.13,
          ),
        ),
        // Gold blob — center left
        const Positioned(
          top: 180,
          left: -100,
          child: _GlowBlob(
            size: 240,
            color: Color(0xFFFFD32A),
            opacity: 0.10,
          ),
        ),
        // Purple blob — bottom right
        const Positioned(
          bottom: 100,
          right: -60,
          child: _GlowBlob(
            size: 200,
            color: Color(0xFF9B59B6),
            opacity: 0.12,
          ),
        ),
        // ── Floating decorative stars/dots ──
        const _FloatingStar(top: 60, left: 28, size: 18, opacity: 0.35),
        const _FloatingStar(top: 140, right: 44, size: 12, opacity: 0.25),
        const _FloatingStar(top: 320, left: 60, size: 10, opacity: 0.20),
        const _FloatingStar(bottom: 200, right: 36, size: 16, opacity: 0.30),
        const _FloatingStar(bottom: 280, left: 100, size: 8, opacity: 0.22),
        const _FloatingStar(top: 500, right: 80, size: 14, opacity: 0.18),
        // Bright accent dots
        const _AccentDot(
            top: 90, right: 110, color: Color(0xFFFFD32A), size: 7),
        const _AccentDot(top: 200, left: 30, color: Color(0xFF00D2D3), size: 5),
        const _AccentDot(
            bottom: 350, right: 55, color: Color(0xFFFF6E6C), size: 6),
        const _AccentDot(
            bottom: 160, left: 55, color: Color(0xFFFFD32A), size: 8),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob(
      {required this.size, required this.color, required this.opacity});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _FloatingStar extends StatelessWidget {
  const _FloatingStar({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.opacity,
  });
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: 0.4,
        child: Icon(
          Icons.star_rounded,
          size: size,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.color,
    required this.size,
  });
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: size * 2,
              spreadRadius: size * 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Portal points badge ───────────────────────────────────────────────────────
/// Reads the total score from completed sessions and shows a points chip.
class _PortalPointsBadge extends StatelessWidget {
  const _PortalPointsBadge({required this.sessions});
  final List<PracticeSession> sessions;

  int get _totalPoints {
    int total = 0;
    for (final s in sessions) {
      for (final v in s.scoreMap.values) {
        total += v;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final pts = _totalPoints;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$pts pts',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.amber[200],
            ),
          ),
        ],
      ),
    );
  }
}
