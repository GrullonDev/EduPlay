import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/teacher_dashboard/services/teacher_classes_service.dart';
import 'package:edu_play/utils/responsive.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Page that lets a parent browse public teacher classes that match their
/// child's age and enroll the child directly.
///
/// Must be pushed with a [ChildProfile] as the route argument:
/// ```dart
/// Navigator.pushNamed(context, RouterPaths.browseTeachers, arguments: profile);
/// ```
class BrowseTeachersPage extends StatefulWidget {
  const BrowseTeachersPage({super.key, required this.child});

  final ChildProfile child;

  @override
  State<BrowseTeachersPage> createState() => _BrowseTeachersPageState();
}

class _BrowseTeachersPageState extends State<BrowseTeachersPage> {
  List<TeacherClass> _classes = [];
  // classId → enrolled?
  final Map<String, bool> _enrolled = {};
  // classId → loading?
  final Map<String, bool> _enrolling = {};
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final classes = await TeacherClassesService.getPublicClassesForAge(
        widget.child.age,
      );
      // Check enrollment status for each class in parallel
      final enrolledResults = await Future.wait(
        classes.map((tc) => TeacherClassesService.isEnrolled(
              classId: tc.id,
              childProfileId: widget.child.id,
            )),
      );
      final enrolledMap = {
        for (var i = 0; i < classes.length; i++)
          classes[i].id: enrolledResults[i],
      };
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _enrolled.addAll(enrolledMap);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _enroll(TeacherClass tc) async {
    setState(() => _enrolling[tc.id] = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await ChildProfilesService.getParentName();
      await TeacherClassesService.joinClass(
        classId: tc.id,
        displayName: widget.child.name,
        email: '', // child profiles don't have email
        role: 'student',
        studentId: widget.child.id,
        childProfileId: widget.child.id,
        parentUid: uid,
        age: widget.child.age,
        focusSubject: widget.child.focusSubject,
      );
      if (!mounted) return;
      setState(() {
        _enrolled[tc.id] = true;
        _enrolling[tc.id] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡${widget.child.name} ha sido inscrito en "${tc.name}"!',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enrolling[tc.id] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al inscribir. Inténtalo de nuevo.',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: _kCoral,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  List<TeacherClass> get _filtered {
    if (_search.isEmpty) return _classes;
    final q = _search.toLowerCase();
    return _classes
        .where((tc) =>
            tc.name.toLowerCase().contains(q) ||
            tc.subject.toLowerCase().contains(q) ||
            tc.teacherName.toLowerCase().contains(q) ||
            tc.gradeLevel.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = ScreenSize.of(context);
    final child = widget.child;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buscar Maestro',
              style:
                  GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              'Para ${child.name} · ${child.age} años',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Child summary banner ───────────────────────────────────────────
          _ChildBanner(child: child),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              s.isMobile ? 16 : 24,
              16,
              s.isMobile ? 16 : 24,
              8,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Buscar por maestro, materia o nivel…',
                hintStyle:
                    GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _kNavy, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Results ───────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: _kNavy, strokeWidth: 2.5),
                  )
                : _filtered.isEmpty
                    ? _EmptyState(
                        hasSearch: _search.isNotEmpty,
                        childAge: child.age,
                        onRefresh: _load,
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: _kNavy,
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            s.isMobile ? 16 : 24,
                            8,
                            s.isMobile ? 16 : 24,
                            32,
                          ),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final tc = _filtered[i];
                            return _ClassDirectoryCard(
                              tc: tc,
                              isEnrolled: _enrolled[tc.id] ?? false,
                              isEnrolling: _enrolling[tc.id] ?? false,
                              onEnroll: () => _enroll(tc),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Child summary banner ──────────────────────────────────────────────────────

class _ChildBanner extends StatelessWidget {
  const _ChildBanner({required this.child});
  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _kNavy,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: child.avatarColor,
            child: Text(
              child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
              style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                child.name,
                style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              Text(
                'Nivel ${child.level} · ${child.focusSubject}',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${child.age} años',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Class directory card ──────────────────────────────────────────────────────

const _kCardColors = [
  Color(0xFF1565C0),
  Color(0xFF00695C),
  Color(0xFF6A1B9A),
  Color(0xFFBF360C),
  Color(0xFF1B5E20),
  Color(0xFF4A148C),
];

class _ClassDirectoryCard extends StatelessWidget {
  const _ClassDirectoryCard({
    required this.tc,
    required this.isEnrolled,
    required this.isEnrolling,
    required this.onEnroll,
  });

  final TeacherClass tc;
  final bool isEnrolled;
  final bool isEnrolling;
  final VoidCallback onEnroll;

  Color get _accent {
    final hash = tc.teacherUid.codeUnits.fold(0, (a, b) => a + b);
    return _kCardColors[hash % _kCardColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // ── Colour header strip ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accent, _accent.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    tc.teacherName.isNotEmpty
                        ? tc.teacherName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tc.teacherName.isNotEmpty
                            ? 'Prof. ${tc.teacherName}'
                            : 'Maestro/a',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        tc.subject,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Enrolled badge
                if (isEnrolled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 13, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          'Inscrito',
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tc.name,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 10),

                // Chips row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      icon: Icons.school_rounded,
                      label: tc.gradeLevel,
                      color: _accent,
                    ),
                    _Chip(
                      icon: Icons.cake_outlined,
                      label: tc.ageRangeLabel,
                      color: const Color(0xFF5C6BC0),
                    ),
                    _Chip(
                      icon: Icons.people_outline_rounded,
                      label: '${tc.studentCount} alumnos',
                      color: const Color(0xFF00897B),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Enroll button
                SizedBox(
                  width: double.infinity,
                  child: isEnrolled
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text(
                            'Ya inscrito en esta clase',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(
                                color: Color(0xFF2E7D32), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: isEnrolling ? null : onEnroll,
                          icon: isEnrolling
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.person_add_rounded, size: 16),
                          label: Text(
                            isEnrolling ? 'Inscribiendo…' : 'Inscribir a este maestro',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
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
    );
  }
}

// ── Small chip helper ─────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasSearch,
    required this.childAge,
    required this.onRefresh,
  });
  final bool hasSearch;
  final int childAge;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasSearch ? '🔍' : '🏫',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'Sin resultados para esa búsqueda'
                  : 'No hay clases disponibles para $childAge años',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Intenta con otro término o revisa los filtros.'
                  : 'Los maestros deben habilitar su clase como pública para '
                      'que aparezca aquí. Puedes pedir el código directamente '
                      'al maestro.',
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.nunito(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('Actualizar',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kNavy,
                side: const BorderSide(color: _kNavy, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
