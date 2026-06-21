import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/teacher_dashboard/services/teacher_classes_service.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kLavender = Color(0xFFEEEDF8);
const _kBg = Color(0xFFF3F2FF);

// ── Entry point ───────────────────────────────────────────────────────────────

class MisClasesPanel extends StatelessWidget {
  const MisClasesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = ScreenSize.of(context).isDesktop;

    return Padding(
      padding: EdgeInsets.all(wide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                'Mis Clases',
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Nueva clase',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kCoral,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Class list ────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<TeacherClass>>(
              stream: TeacherClassesService.watchMyClasses(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: _kNavy, strokeWidth: 2),
                  );
                }
                final classes = snap.data ?? [];
                if (classes.isEmpty) {
                  return _EmptyClasses(
                    onTap: () => _showCreateDialog(context),
                  );
                }
                return wide
                    ? _ClassGrid(classes: classes)
                    : _ClassList(classes: classes);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _CreateClassDialog(),
    );
  }
}

// ── Grid (desktop) ────────────────────────────────────────────────────────────

class _ClassGrid extends StatelessWidget {
  const _ClassGrid({required this.classes});
  final List<TeacherClass> classes;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: classes.length,
      itemBuilder: (_, i) => _ClassCard(tc: classes[i]),
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({required this.classes});
  final List<TeacherClass> classes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: classes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ClassCard(tc: classes[i]),
    );
  }
}

// ── Class card ────────────────────────────────────────────────────────────────

const _kLevelColors = [
  Color(0xFFE11D48),
  Color(0xFF3B82F6),
  Color(0xFFD97706),
  Color(0xFF16A34A),
  Color(0xFF9B59B6),
];

class _ClassCard extends StatefulWidget {
  const _ClassCard({required this.tc});
  final TeacherClass tc;

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard> {
  bool _codeCopied = false;

  Color get _accentColor {
    final hash = widget.tc.name.codeUnits.fold(0, (a, b) => a + b);
    return _kLevelColors[hash % _kLevelColors.length];
  }

  String get _inviteUrl {
    if (!kIsWeb) {
      return 'http://localhost:3000/#/join-class?code=${widget.tc.joinCode}';
    }
    return '${Uri.base.origin}/#/join-class?code=${widget.tc.joinCode}';
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _inviteUrl));
    setState(() => _codeCopied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _codeCopied = false);
  }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tc;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge + actions
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tc.gradeLevel,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _accentColor,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 18, color: Colors.grey),
                onSelected: (v) async {
                  if (v == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Eliminar clase',
                            style: GoogleFonts.fredoka(
                                color: _kCoral, fontSize: 18)),
                        content: Text(
                          '¿Eliminar "${tc.name}"? Esta acción no se puede deshacer.',
                          style: GoogleFonts.nunito(fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _kCoral),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Eliminar',
                                style: GoogleFonts.nunito(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await TeacherClassesService.deleteClass(tc.id);
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            size: 16, color: _kCoral),
                        const SizedBox(width: 8),
                        Text('Eliminar',
                            style: GoogleFonts.nunito(color: _kCoral)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            tc.name,
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          Text(
            tc.subject,
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
          ),

          const Spacer(),

          // Stats row
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${tc.studentCount} alumnos',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Join code + copy link
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _kLavender,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  'Código: ',
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  tc.joinCode,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _copyLink,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _codeCopied
                        ? const Icon(Icons.check_rounded,
                            key: ValueKey('check'),
                            size: 18,
                            color: Color(0xFF27AE60))
                        : const Icon(Icons.copy_rounded,
                            key: ValueKey('copy'), size: 18, color: _kNavy),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyClasses extends StatelessWidget {
  const _EmptyClasses({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏫', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(
            'Aún no tienes clases',
            style: GoogleFonts.fredoka(
                fontSize: 22, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera clase y comparte el código con tus alumnos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Crear primera clase',
              style: GoogleFonts.fredoka(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Create class dialog ───────────────────────────────────────────────────────

const _kGradeLevels = [
  'Preescolar',
  '1° Primaria',
  '2° Primaria',
  '3° Primaria',
  '4° Primaria',
  '5° Primaria',
  '6° Primaria',
  '1° Secundaria',
  '2° Secundaria',
  '3° Secundaria',
  '1° Bachillerato',
  '2° Bachillerato',
];

class _CreateClassDialog extends StatefulWidget {
  const _CreateClassDialog();

  @override
  State<_CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends State<_CreateClassDialog> {
  final _nameCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  String? _gradeLevel;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Introduce el nombre de la clase.');
      return;
    }
    if (_gradeLevel == null) {
      setState(() => _error = 'Selecciona el nivel.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tc = await TeacherClassesService.createClass(
        name: _nameCtrl.text.trim(),
        subject: _subjectCtrl.text.trim().isEmpty
            ? 'General'
            : _subjectCtrl.text.trim(),
        gradeLevel: _gradeLevel!,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      // Show the join code immediately
      await showDialog<void>(
        context: context,
        builder: (_) => _JoinCodeDialog(tc: tc),
      );
    } catch (e) {
      setState(() => _error = 'No se pudo crear la clase. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva clase',
                style: GoogleFonts.fredoka(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _kNavy),
              ),
              const SizedBox(height: 20),
              _Field(
                  label: 'Nombre de la clase *',
                  ctrl: _nameCtrl,
                  hint: 'Ej: 3° A – Primaria'),
              const SizedBox(height: 14),
              _Field(
                  label: 'Asignatura',
                  ctrl: _subjectCtrl,
                  hint: 'Ej: Matemáticas, Lengua…'),
              const SizedBox(height: 14),
              Text('Nivel *',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _gradeLevel,
                hint: Text('Selecciona el nivel',
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.grey[400])),
                items: _kGradeLevels
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                style: GoogleFonts.nunito(
                    fontSize: 14, color: const Color(0xFF111827)),
                decoration: _inputDec(''),
                onChanged: (v) => setState(() => _gradeLevel = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: GoogleFonts.nunito(fontSize: 12, color: _kCoral)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Crear clase',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar',
                      style: GoogleFonts.nunito(color: Colors.grey[500])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Join code reveal dialog ───────────────────────────────────────────────────

class _JoinCodeDialog extends StatefulWidget {
  const _JoinCodeDialog({required this.tc});
  final TeacherClass tc;

  @override
  State<_JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<_JoinCodeDialog> {
  bool _copied = false;

  String get _inviteUrl {
    if (!kIsWeb) {
      return 'http://localhost:3000/#/join-class?code=${widget.tc.joinCode}';
    }
    return '${Uri.base.origin}/#/join-class?code=${widget.tc.joinCode}';
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _inviteUrl));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5F5E3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 32, color: Color(0xFF27AE60)),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Clase creada!',
                style: GoogleFonts.fredoka(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _kNavy),
              ),
              const SizedBox(height: 8),
              Text(
                'Comparte este código o enlace con tus alumnos para que se unan a "${widget.tc.name}".',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.grey[500], height: 1.4),
              ),
              const SizedBox(height: 24),

              // Code display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: _kLavender,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.tc.joinCode,
                  style: GoogleFonts.fredoka(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                    letterSpacing: 6,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // URL copy row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 14, color: _kNavy),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _inviteUrl,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: _kNavy,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _copy,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _copied
                            ? const Icon(Icons.check_rounded,
                                key: ValueKey('c'),
                                size: 16,
                                color: Color(0xFF27AE60))
                            : const Icon(Icons.copy_rounded,
                                key: ValueKey('u'), size: 16, color: _kNavy),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('¡Entendido!',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.ctrl, required this.hint});
  final String label;
  final TextEditingController ctrl;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: GoogleFonts.nunito(fontSize: 14),
          decoration: _inputDec(hint),
        ),
      ],
    );
  }
}

InputDecoration _inputDec(String hint) => InputDecoration(
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
