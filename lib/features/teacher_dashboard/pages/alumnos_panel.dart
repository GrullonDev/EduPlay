// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/teacher_dashboard/domain/entities/class_member.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/teacher_classes_repository.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kLavender = Color(0xFFEEEDF8);
const _kRed = Color(0xFFC0392B);

const _kAvatarColors = [
  Color(0xFFE11D48),
  Color(0xFF3B82F6),
  Color(0xFFD97706),
  Color(0xFF16A34A),
  Color(0xFF9B59B6),
];

Color _colorFor(String seed) {
  final hash = seed.codeUnits.fold(0, (a, b) => a + b);
  return _kAvatarColors[hash % _kAvatarColors.length];
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class AlumnosPanel extends StatefulWidget {
  const AlumnosPanel({super.key, this.onNavigateTab});

  /// Lets row/bulk actions ("Asignar reto") jump to another dashboard tab
  /// (index 3 = Retos). Null when the panel is used standalone.
  final ValueChanged<int>? onNavigateTab;

  @override
  State<AlumnosPanel> createState() => _AlumnosPanelState();
}

class _AlumnosPanelState extends State<AlumnosPanel> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _classFilter;
  int _refreshTick = 0;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final Set<String> _selectedIds = {};

  void _refresh() => setState(() => _refreshTick++);

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<ClassMember> _sorted(List<ClassMember> input) {
    final list = [...input];
    int cmp(ClassMember a, ClassMember b) {
      switch (_sortColumnIndex) {
        case 1:
          return a.className.toLowerCase().compareTo(b.className.toLowerCase());
        case 2:
          return a.completedChallengeIds.length
              .compareTo(b.completedChallengeIds.length);
        case 3:
          return a.joinedAt.compareTo(b.joinedAt);
        case 0:
        default:
          return a.displayName
              .toLowerCase()
              .compareTo(b.displayName.toLowerCase());
      }
    }

    list.sort(cmp);
    return _sortAscending ? list : list.reversed.toList();
  }

  Future<void> _exportCsv(List<ClassMember> members) async {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay alumnos para exportar.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final buffer =
        StringBuffer('Nombre,Edad,Clase,Retos completados,Ingresó\n');
    for (final m in members) {
      final name = m.displayName.replaceAll(',', ' ');
      final age = m.age?.toString() ?? '';
      final className = m.className.replaceAll(',', ' ');
      final completed = m.completedChallengeIds.length.toString();
      buffer.writeln(
          '$name,$age,$className,$completed,${_formatDate(m.joinedAt)}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Datos copiados (CSV). Pégalos en Excel o Google Sheets.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _bulkRemove(List<ClassMember> selected) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quitar ${selected.length} alumnos',
          style: GoogleFonts.fredoka(
              color: _kNavy, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Quitar a ${selected.length} alumnos seleccionados de sus clases? '
          'Podrán volver a unirse más tarde con el código de cada clase.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Quitar',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = sl<TeacherClassesRepository>();
    for (final m in selected) {
      await repo.removeMember(classId: m.classId, memberId: m.id);
    }
    if (!mounted) return;
    setState(() {
      _selectedIds.clear();
      _refreshTick++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '${selected.length} alumnos fueron quitados de sus clases.')),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Alumnos',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Niños inscritos en tus clases mediante código de invitación.',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                  style: GoogleFonts.nunito(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o clase...',
                    hintStyle: GoogleFonts.nunito(
                        fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    filled: true,
                    fillColor: _kLavender,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<TeacherClass>>(
              stream: sl<TeacherClassesRepository>().watchMyClasses(),
              builder: (context, classSnap) {
                if (classSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: _kNavy, strokeWidth: 2),
                  );
                }

                final classes = classSnap.data ?? const <TeacherClass>[];
                if (classes.isEmpty) {
                  return const _EmptyAlumnos();
                }

                return FutureBuilder<List<ClassMember>>(
                  key: ValueKey('alumnos-$_refreshTick'),
                  future: sl<TeacherClassesRepository>()
                      .getMembersForClasses(classes.map((c) => c.id).toList()),
                  builder: (context, memberSnap) {
                    if (memberSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: _kNavy, strokeWidth: 2),
                      );
                    }

                    final members = memberSnap.data ?? const <ClassMember>[];
                    if (members.isEmpty) return const _EmptyAlumnos();

                    var filtered = _query.isEmpty
                        ? members
                        : members
                            .where((m) =>
                                m.displayName.toLowerCase().contains(_query) ||
                                m.className.toLowerCase().contains(_query))
                            .toList();
                    if (_classFilter != null) {
                      filtered = filtered
                          .where((m) => m.classId == _classFilter)
                          .toList();
                    }
                    filtered = _sorted(filtered);

                    // Keep selection in sync with alumnos that still exist
                    // (e.g. after one was removed by another action).
                    final validIds = members.map((m) => m.id).toSet();
                    _selectedIds.removeWhere((id) => !validIds.contains(id));
                    final selectedMembers = members
                        .where((m) => _selectedIds.contains(m.id))
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AlumnosStatsRow(members: members, wide: wide),
                        const SizedBox(height: 16),
                        _ToolbarRow(
                          wide: wide,
                          classes: classes,
                          classFilter: _classFilter,
                          onClassFilterChanged: (v) =>
                              setState(() => _classFilter = v),
                          selectedCount: selectedMembers.length,
                          canBulkAssign: selectedMembers.isNotEmpty &&
                              selectedMembers
                                      .map((m) => m.classId)
                                      .toSet()
                                      .length ==
                                  1 &&
                              widget.onNavigateTab != null,
                          onBulkAssign: () => widget.onNavigateTab?.call(3),
                          onBulkRemove: () => _bulkRemove(selectedMembers),
                          onClearSelection: () =>
                              setState(() => _selectedIds.clear()),
                          onExport: () => _exportCsv(selectedMembers.isNotEmpty
                              ? selectedMembers
                              : filtered),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Text(
                                    'Sin resultados para los filtros aplicados.',
                                    style: GoogleFonts.nunito(
                                        color: Colors.grey[500]),
                                  ),
                                )
                              : _AlumnosTable(
                                  members: filtered,
                                  total: members.length,
                                  onNavigateTab: widget.onNavigateTab,
                                  onMemberRemoved: _refresh,
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  onSort: _onSort,
                                  selectedIds: _selectedIds,
                                  onToggleSelect: (id, selected) =>
                                      setState(() {
                                    if (selected) {
                                      _selectedIds.add(id);
                                    } else {
                                      _selectedIds.remove(id);
                                    }
                                  }),
                                  onSelectAll: (selectAll) => setState(() {
                                    if (selectAll) {
                                      _selectedIds
                                          .addAll(filtered.map((m) => m.id));
                                    } else {
                                      _selectedIds.removeWhere((id) =>
                                          filtered.any((m) => m.id == id));
                                    }
                                  }),
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toolbar (class filter · bulk actions · export) ─────────────────────────────

class _ToolbarRow extends StatelessWidget {
  const _ToolbarRow({
    required this.wide,
    required this.classes,
    required this.classFilter,
    required this.onClassFilterChanged,
    required this.selectedCount,
    required this.canBulkAssign,
    required this.onBulkAssign,
    required this.onBulkRemove,
    required this.onClearSelection,
    required this.onExport,
  });

  final bool wide;
  final List<TeacherClass> classes;
  final String? classFilter;
  final ValueChanged<String?> onClassFilterChanged;
  final int selectedCount;
  final bool canBulkAssign;
  final VoidCallback onBulkAssign;
  final VoidCallback onBulkRemove;
  final VoidCallback onClearSelection;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final exportButton = OutlinedButton.icon(
      onPressed: onExport,
      icon: const Icon(Icons.download_rounded, size: 16),
      label: Text(
        selectedCount > 0 ? 'Exportar selección' : 'Exportar CSV',
        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _kNavy,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (selectedCount > 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _kNavy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '$selectedCount seleccionado${selectedCount == 1 ? '' : 's'}',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13),
            ),
            _ToolbarChipButton(
              icon: Icons.flag_rounded,
              label: 'Asignar reto',
              onTap: canBulkAssign ? onBulkAssign : null,
              disabledHint: 'Selecciona alumnos de una sola clase',
            ),
            _ToolbarChipButton(
              icon: Icons.person_remove_rounded,
              label: 'Quitar',
              onTap: onBulkRemove,
              color: const Color(0xFFFFB4B0),
            ),
            _ToolbarChipButton(
              icon: Icons.download_rounded,
              label: 'Exportar',
              onTap: onExport,
            ),
            _ToolbarChipButton(
              icon: Icons.close_rounded,
              label: 'Cancelar',
              onTap: onClearSelection,
            ),
          ],
        ),
      );
    }

    final filterDropdown = SizedBox(
      width: wide ? 220 : double.infinity,
      child: DropdownButtonFormField<String?>(
        initialValue: classFilter,
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: _kLavender,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: GoogleFonts.nunito(fontSize: 13, color: _kNavy),
        items: [
          DropdownMenuItem(
              value: null,
              child: Text('Todas las clases',
                  style: GoogleFonts.nunito(fontSize: 13))),
          ...classes.map(
            (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
          ),
        ],
        onChanged: onClassFilterChanged,
      ),
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filterDropdown,
          const SizedBox(height: 10),
          exportButton,
        ],
      );
    }

    return Row(
      children: [
        filterDropdown,
        const Spacer(),
        exportButton,
      ],
    );
  }
}

class _ToolbarChipButton extends StatelessWidget {
  const _ToolbarChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.disabledHint,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final chip = Material(
      color: Colors.white.withValues(alpha: enabled ? 0.15 : 0.06),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color ?? Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: (color ?? Colors.white)
                      .withValues(alpha: enabled ? 1 : 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!enabled && disabledHint != null) {
      return Tooltip(message: disabledHint!, child: chip);
    }
    return chip;
  }
}

class _AlumnosStatsRow extends StatelessWidget {
  const _AlumnosStatsRow({required this.members, required this.wide});

  final List<ClassMember> members;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final classCount = members.map((m) => m.classId).toSet().length;
    final challengesCompleted =
        members.fold<int>(0, (sum, m) => sum + m.completedChallengeIds.length);

    final cards = [
      _StatCardData(
        label: 'Total Alumnos',
        value: '${members.length}',
        icon: Icons.groups_rounded,
        color: const Color(0xFF3B82F6),
        bg: const Color(0xFFDBEAFE),
      ),
      _StatCardData(
        label: 'Clases con Alumnos',
        value: '$classCount',
        icon: Icons.class_rounded,
        color: const Color(0xFFD97706),
        bg: const Color(0xFFFEF3C7),
      ),
      _StatCardData(
        label: 'Retos Completados',
        value: '$challengesCompleted',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFE11D48),
        bg: const Color(0xFFFCE7F3),
      ),
    ];

    if (!wide) {
      return Column(
        children: cards
            .map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StatCard(data: d),
                ))
            .toList(),
      );
    }
    return Row(
      children: cards
          .map((d) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _StatCard(data: d),
                ),
              ))
          .toList(),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});
  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(data.icon, color: data.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.value,
                    style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _kNavy)),
                Text(data.label,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Table ─────────────────────────────────────────────────────────────────────

class _AlumnosTable extends StatelessWidget {
  const _AlumnosTable({
    required this.members,
    required this.total,
    this.onNavigateTab,
    this.onMemberRemoved,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.selectedIds,
    required this.onToggleSelect,
    required this.onSelectAll,
  });
  final List<ClassMember> members;
  final int total;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onMemberRemoved;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onToggleSelect;
  final ValueChanged<bool> onSelectAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(_kLavender),
                        columnSpacing: 28,
                        sortColumnIndex: sortColumnIndex,
                        sortAscending: sortAscending,
                        showCheckboxColumn: true,
                        onSelectAll: (value) => onSelectAll(value ?? false),
                        columns: [
                          _column('Alumno', onSort: onSort),
                          _column('Clase', onSort: onSort),
                          _column('Retos completados', onSort: onSort),
                          _column('Ingresó', onSort: onSort),
                          _column(''),
                        ],
                        rows: members.map((m) {
                          final color = _colorFor(
                              m.displayName.isEmpty ? m.id : m.displayName);
                          final initial = m.displayName.isNotEmpty
                              ? m.displayName[0].toUpperCase()
                              : '?';
                          return DataRow(
                            selected: selectedIds.contains(m.id),
                            onSelectChanged: (value) =>
                                onToggleSelect(m.id, value ?? false),
                            cells: [
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        color.withValues(alpha: 0.15),
                                    child: Text(initial,
                                        style: GoogleFonts.fredoka(
                                            color: color,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.displayName.isEmpty
                                            ? '—'
                                            : m.displayName,
                                        style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w700,
                                            color: _kNavy,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        m.age != null
                                            ? '${m.age} años'
                                            : 'Edad —',
                                        style: GoogleFonts.nunito(
                                            fontSize: 11,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  m.className.isEmpty ? '—' : m.className,
                                  style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: color),
                                ),
                              )),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_events_rounded,
                                      size: 15,
                                      color: m.completedChallengeIds.isEmpty
                                          ? Colors.grey[350]
                                          : const Color(0xFFD97706)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${m.completedChallengeIds.length}',
                                    style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700]),
                                  ),
                                ],
                              )),
                              DataCell(Text(
                                _formatDate(m.joinedAt),
                                style: GoogleFonts.nunito(
                                    fontSize: 12, color: Colors.grey[500]),
                              )),
                              DataCell(_ActionsMenu(
                                member: m,
                                onNavigateTab: onNavigateTab,
                                onRemoved: onMemberRemoved,
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Text(
              members.length == total
                  ? 'Mostrando ${members.length} alumno${members.length == 1 ? '' : 's'}'
                  : 'Mostrando ${members.length} de $total alumnos',
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _column(String label,
          {void Function(int columnIndex, bool ascending)? onSort}) =>
      DataColumn(
        label: Text(
          label,
          style: GoogleFonts.nunito(
              fontSize: 12, fontWeight: FontWeight.w800, color: _kNavy),
        ),
        onSort: onSort,
      );
}

class _ActionsMenu extends StatefulWidget {
  const _ActionsMenu(
      {required this.member, this.onNavigateTab, this.onRemoved});

  final ClassMember member;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onRemoved;

  @override
  State<_ActionsMenu> createState() => _ActionsMenuState();
}

class _ActionsMenuState extends State<_ActionsMenu> {
  bool _busy = false;

  Future<void> _remove(BuildContext context) async {
    final name = widget.member.displayName.isEmpty
        ? 'este alumno'
        : widget.member.displayName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quitar alumno',
          style: GoogleFonts.fredoka(
              color: _kNavy, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Quitar a $name de "${widget.member.className}"? '
          'Podrá volver a unirse más tarde con el código de la clase.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Quitar',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await sl<TeacherClassesRepository>().removeMember(
        classId: widget.member.classId,
        memberId: widget.member.id,
      );
      widget.onRemoved?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name fue quitado de la clase.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo quitar al alumno. Intenta de nuevo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showDetail(BuildContext context) {
    final m = widget.member;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          m.displayName.isEmpty ? 'Alumno' : m.displayName,
          style: GoogleFonts.fredoka(
              color: _kNavy, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                  label: 'Clase',
                  value: m.className.isEmpty ? '—' : m.className),
              _DetailRow(
                  label: 'Materia',
                  value: m.classSubject.isEmpty ? '—' : m.classSubject),
              _DetailRow(
                  label: 'Edad', value: m.age != null ? '${m.age} años' : '—'),
              _DetailRow(
                  label: 'Le interesa',
                  value: m.focusSubject.isEmpty ? '—' : m.focusSubject),
              _DetailRow(
                  label: 'Correo', value: m.email.isEmpty ? '—' : m.email),
              _DetailRow(label: 'Ingresó', value: _formatDate(m.joinedAt)),
              _DetailRow(
                  label: 'Retos completados',
                  value: '${m.completedChallengeIds.length}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey[500], size: 20),
      tooltip: 'Acciones',
      onSelected: (value) {
        switch (value) {
          case 'detail':
            _showDetail(context);
            break;
          case 'assign':
            widget.onNavigateTab?.call(3);
            break;
          case 'remove':
            _remove(context);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'detail',
          child:
              _MenuRow(icon: Icons.visibility_outlined, label: 'Ver detalle'),
        ),
        if (widget.onNavigateTab != null)
          const PopupMenuItem(
            value: 'assign',
            child: _MenuRow(icon: Icons.flag_outlined, label: 'Asignar reto'),
          ),
        const PopupMenuDivider(height: 8),
        const PopupMenuItem(
          value: 'remove',
          child: _MenuRow(
            icon: Icons.person_remove_outlined,
            label: 'Quitar de la clase',
            color: _kRed,
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? _kNavy),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? _kNavy),
          ),
        ],
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600]),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.nunito(fontSize: 13, color: _kNavy),
              ),
            ),
          ],
        ),
      );
}

class _EmptyAlumnos extends StatelessWidget {
  const _EmptyAlumnos();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧑‍🎓', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes alumnos',
            style: GoogleFonts.fredoka(
                fontSize: 20, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una clase en "Mis Clases" y comparte el código\npara que tus alumnos se unan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
