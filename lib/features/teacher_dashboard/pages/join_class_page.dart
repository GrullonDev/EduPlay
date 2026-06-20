import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/teacher_dashboard/services/teacher_classes_service.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);
const _kLavender = Color(0xFFEEEDF8);

// ── Page ──────────────────────────────────────────────────────────────────────

/// Accessed at /#/join-class?code=XXXXXX
/// Can be opened by parents or students. Shows class details; tapping Join
/// calls TeacherClassesService.joinClass().
class JoinClassPage extends StatefulWidget {
  /// Pre-filled code from route args or URL fragment.
  final String? codeFromArgs;

  const JoinClassPage({super.key, this.codeFromArgs});

  @override
  State<JoinClassPage> createState() => _JoinClassPageState();
}

class _JoinClassPageState extends State<JoinClassPage> {
  late final TextEditingController _codeCtrl;
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  TeacherClass? _found;
  String? _error;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    final preCode = widget.codeFromArgs ?? _codeFromUrl();
    _codeCtrl = TextEditingController(text: preCode ?? '');
    if (preCode != null && preCode.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup());
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // Parse /#/join-class?code=XXXX from the URL fragment on web
  String? _codeFromUrl() {
    if (!kIsWeb) return null;
    try {
      final fragment = Uri.base.fragment; // e.g. "/join-class?code=AB3DEF"
      final qIdx = fragment.indexOf('?');
      if (qIdx == -1) return null;
      final params = Uri.splitQueryString(fragment.substring(qIdx + 1));
      return params['code'];
    } catch (_) {
      return null;
    }
  }

  Future<void> _lookup() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _found = null;
    });

    try {
      final tc = await TeacherClassesService.findByCode(code);
      if (!mounted) return;
      if (tc == null) {
        setState(() => _error = 'Código no encontrado. Verifica e inténtalo.');
      } else {
        setState(() => _found = tc);
      }
    } catch (_) {
      setState(() => _error = 'Error al buscar la clase. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _join() async {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        _nameCtrl.text.trim().isEmpty ? (user?.displayName ?? 'Alumno') : _nameCtrl.text.trim();
    final email = user?.email ?? '';

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await TeacherClassesService.joinClass(
        classId: _found!.id,
        displayName: displayName,
        email: email,
        role: 'student',
      );
      if (!mounted) return;
      setState(() => _joined = true);
    } catch (e) {
      setState(() => _error = 'No se pudo unir. ¿Ya eres miembro de esta clase?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        title: Text(
          'Unirse a una clase',
          style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _joined ? _SuccessView(tc: _found!) : _FormView(state: this),
          ),
        ),
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({required this.state});
  final _JoinClassPageState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Illustration
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _kNavy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏫', style: TextStyle(fontSize: 48)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Ingresa el código de clase',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tu profesor te habrá compartido un código de 6 caracteres.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[500]),
          ),
        ),
        const SizedBox(height: 32),

        // Code field
        Text('Código de clase',
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151))),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: state._codeCtrl,
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  letterSpacing: 4,
                  color: _kNavy,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: _inputDec('AB3DEF'),
                onSubmitted: (_) => state._lookup(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: state._loading ? null : state._lookup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: state._loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Buscar',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            ),
          ],
        ),

        // Error
        if (state._error != null) ...[
          const SizedBox(height: 10),
          Text(state._error!,
              style: GoogleFonts.nunito(fontSize: 12, color: _kCoral)),
        ],

        // Found class preview
        if (state._found != null) ...[
          const SizedBox(height: 24),
          _ClassPreview(tc: state._found!),
          const SizedBox(height: 20),

          // Name field (optional if logged in)
          if (FirebaseAuth.instance.currentUser?.displayName == null ||
              FirebaseAuth.instance.currentUser!.displayName!.isEmpty) ...[
            Text('Tu nombre',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151))),
            const SizedBox(height: 6),
            TextField(
              controller: state._nameCtrl,
              style: GoogleFonts.nunito(fontSize: 14),
              decoration: _inputDec('Nombre que verá tu profe'),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state._loading ? null : state._join,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kCoral,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: state._loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      '¡Unirme a la clase!',
                      style: GoogleFonts.fredoka(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Class preview card ────────────────────────────────────────────────────────

class _ClassPreview extends StatelessWidget {
  const _ClassPreview({required this.tc});
  final TeacherClass tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kNavy.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _kLavender,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('📚', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tc.name,
                  style: GoogleFonts.fredoka(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _kNavy),
                ),
                Text(
                  '${tc.subject} · ${tc.gradeLevel}',
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_outline_rounded,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${tc.studentCount} alumnos',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
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
              '¡Encontrada!',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27AE60),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success ───────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.tc});
  final TeacherClass tc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFD5F5E3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(Icons.check_rounded,
                size: 40, color: Color(0xFF27AE60)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¡Ya eres miembro!',
          style: GoogleFonts.fredoka(
              fontSize: 24, fontWeight: FontWeight.w700, color: _kNavy),
        ),
        const SizedBox(height: 8),
        Text(
          'Te has unido a "${tc.name}" correctamente.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[500]),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamedAndRemoveUntil(
                    RouterPaths.root, (_) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Ir al inicio',
              style: GoogleFonts.fredoka(
                  fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

InputDecoration _inputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
