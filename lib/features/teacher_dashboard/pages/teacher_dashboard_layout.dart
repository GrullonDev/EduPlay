import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import 'package:edu_play/features/teacher_dashboard/pages/mis_clases_panel.dart';
import 'package:edu_play/features/teacher_dashboard/pages/retos_panel.dart';
import 'package:edu_play/features/teacher_dashboard/pages/rendimiento_panel.dart';
import 'package:edu_play/features/teacher_dashboard/pages/informes_panel.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kBg = Color(0xFFF3F2FF);
const _kSidebarBg = Color(0xFFFFFFFF);
const _kActiveItem = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);

// ─────────────────────────────────────────────────────────────────────────────

class TeacherDashboardLayout extends StatefulWidget {
  const TeacherDashboardLayout({super.key});

  @override
  State<TeacherDashboardLayout> createState() => _TeacherDashboardLayoutState();
}

class _TeacherDashboardLayoutState extends State<TeacherDashboardLayout> {
  int _selectedIndex = 0;
  final bool _sidebarOpen = false; // for mobile drawer

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Panel Principal'),
    _NavItem(icon: Icons.groups_rounded, label: 'Mis Clases'),
    _NavItem(icon: Icons.emoji_events_rounded, label: 'Retos'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Rendimiento'),
    _NavItem(icon: Icons.description_rounded, label: 'Informes'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    final bloc = context.watch<TeacherDashboardBloc>();

    return Scaffold(
      backgroundColor: _kBg,
      // Mobile: sidebar as drawer
      drawer: wide
          ? null
          : Drawer(
              width: 240,
              child: _Sidebar(
                selectedIndex: _selectedIndex,
                navItems: _navItems,
                onSelect: (i) {
                  setState(() => _selectedIndex = i);
                  Navigator.of(context).pop();
                },
              ),
            ),
      body: Row(
        children: [
          // Desktop sidebar
          if (wide)
            SizedBox(
              width: 240,
              child: _Sidebar(
                selectedIndex: _selectedIndex,
                navItems: _navItems,
                onSelect: (i) => setState(() => _selectedIndex = i),
              ),
            ),

          // Main area
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  onMenuTap:
                      wide ? null : () => Scaffold.of(context).openDrawer(),
                  searchHint: const [
                    'Buscar alumnos, retos...',
                    'Buscar clase...',
                    'Buscar reto...',
                    'Buscar alumno...',
                    'Buscar informes...',
                  ][_selectedIndex.clamp(0, 4)],
                ),
                Expanded(
                  child: bloc.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBody(bloc),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TeacherDashboardBloc bloc) {
    switch (_selectedIndex) {
      case 0:
        return _OverviewPanel(bloc: bloc);
      case 1:
        return const MisClasesPanel();
      case 2:
        return const RetosPanel();
      case 3:
        return const RendimientoPanel();
      default:
        return const InformesPanel();
    }
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kSidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Docente',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gestión Académica',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: navItems.length,
              itemBuilder: (_, i) {
                final active = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? _kActiveItem : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          navItems[i].icon,
                          size: 18,
                          color: active ? Colors.white : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          navItems[i].label,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: 24),
                // Nuevo Reporte button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(
                    'Nuevo Reporte',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 4),
                _SidebarTextBtn(
                  icon: Icons.help_outline_rounded,
                  label: 'Ayuda',
                  onTap: () {},
                ),
                _SidebarTextBtn(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar Sesión',
                  onTap: () => Navigator.of(context)
                      .pushReplacementNamed(RouterPaths.root),
                  color: const Color(0xFFC0392B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTextBtn extends StatelessWidget {
  const _SidebarTextBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade600;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: c),
      label: Text(label,
          style: GoogleFonts.nunito(
              color: c, fontSize: 13, fontWeight: FontWeight.w600)),
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    this.onMenuTap,
    this.searchHint = 'Buscar alumnos, retos...',
  });

  final VoidCallback? onMenuTap;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          if (onMenuTap != null) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: _kNavy),
              onPressed: onMenuTap,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            'EduDash Pro',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kNavy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 24),
          // Search
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      size: 18, color: Color(0xFFAAAAAA)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: GoogleFonts.nunito(
                            fontSize: 13, color: const Color(0xFFAAAAAA)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Icons
          const _TopIcon(Icons.notifications_none_rounded),
          const SizedBox(width: 4),
          const _TopIcon(Icons.settings_outlined),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: _kNavy,
            child: Text('E',
                style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, size: 22, color: Colors.grey.shade600),
        onPressed: () {},
        splashRadius: 20,
      );
}

// ── Overview Panel ────────────────────────────────────────────────────────────

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 32 : 16,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          _GreetingRow(),
          const SizedBox(height: 24),

          // Stat cards
          _StatCardsRow(bloc: bloc),
          const SizedBox(height: 24),

          // Chart + Right panel
          wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 6,
                          child: _WeeklyProgressCard(
                              weeklyTotals: bloc.weeklyTotals)),
                      const SizedBox(width: 20),
                      Expanded(
                          flex: 4,
                          child: _InsightsPanel(students: bloc.students)),
                    ],
                  ),
                )
              : Column(children: [
                  _WeeklyProgressCard(weeklyTotals: bloc.weeklyTotals),
                  const SizedBox(height: 20),
                  _InsightsPanel(students: bloc.students),
                ]),

          const SizedBox(height: 24),

          // Bottom: Challenges + Subject performance
          wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _ChallengesCard(challenges: bloc.challenges)),
                    const SizedBox(width: 20),
                    Expanded(
                        child:
                            _SubjectCard(performance: bloc.subjectPerformance)),
                  ],
                )
              : Column(
                  children: [
                    _ChallengesCard(challenges: bloc.challenges),
                    const SizedBox(height: 20),
                    _SubjectCard(performance: bloc.subjectPerformance),
                  ],
                ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Greeting row ──────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    final dateLabel = '${months[now.month]} ${now.year}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, Profe Elena!',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Aquí tienes el resumen de tus clases para hoy.',
              style:
                  GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {},
          icon:
              const Icon(Icons.calendar_today_rounded, size: 15, color: _kNavy),
          label: Text(
            dateLabel,
            style: GoogleFonts.nunito(
                color: _kNavy, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _kNavy, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ── Stat cards row ────────────────────────────────────────────────────────────

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final total = bloc.totalStudents == 0 ? 32 : bloc.totalStudents;
    final pct = (bloc.averageProgress * 100).round();
    final completionPct = pct == 0 ? 88 : pct;

    return LayoutBuilder(builder: (_, c) {
      final cards = [
        _StatCardData(
          label: 'Total Estudiantes',
          value: '$total',
          badge: '+4% vs mes ant.',
          badgeColor: const Color(0xFF3B82F6),
          badgeBg: const Color(0xFFDBEAFE),
          iconBg: const Color(0xFFDBEAFE),
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFF3B82F6),
          valueColor: _kNavy,
        ),
        const _StatCardData(
          label: 'Tiempo Promedio',
          value: '45 min',
          badge: 'En meta',
          badgeColor: Color(0xFFD97706),
          badgeBg: Color(0xFFFEF3C7),
          iconBg: Color(0xFFFEF3C7),
          icon: Icons.timer_outlined,
          iconColor: Color(0xFFF59E0B),
          valueColor: Color(0xFFD97706),
        ),
        _StatCardData(
          label: 'Tasa de Completado',
          value: '$completionPct%',
          badge: 'Excelente',
          badgeColor: const Color(0xFFE11D48),
          badgeBg: const Color(0xFFFCE7F3),
          iconBg: const Color(0xFFFCE7F3),
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFFEC4899),
          valueColor: const Color(0xFFE11D48),
        ),
      ];

      final cols = c.maxWidth >= 600 ? 3 : 1;
      if (cols == 3) {
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
      return Column(
          children: cards
              .map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StatCard(data: d),
                  ))
              .toList());
    });
  }
}

class _StatCardData {
  const _StatCardData({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: data.iconColor, width: 3),
        ),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: data.iconColor, size: 20),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: data.badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data.badge,
                style: GoogleFonts.nunito(
                  color: data.badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Text(data.label,
              style: GoogleFonts.nunito(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(data.value,
              style: GoogleFonts.fredoka(
                  color: data.valueColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Weekly progress chart ─────────────────────────────────────────────────────

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.weeklyTotals});

  final List<double> weeklyTotals;

  static const _labels = ['Sem 1', 'Sem 2', 'Sem 3', 'Actual'];
  // Mock retos data (ratio to media)
  static const _retosRatios = [0.6, 0.75, 0.55, 0.85];

  @override
  Widget build(BuildContext context) {
    // Fall back to demo data if empty
    final media = weeklyTotals.isEmpty
        ? [120.0, 180.0, 150.0, 210.0]
        : weeklyTotals.take(4).toList();
    final retos = List.generate(
      media.length,
      (i) => media[i] * _retosRatios[i % _retosRatios.length],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                'Progreso Semanal Grupal',
                style: GoogleFonts.fredoka(
                    fontSize: 16, color: _kNavy, fontWeight: FontWeight.w700),
              ),
            ),
            // Legend
            const _LegendDot(color: Color(0xFF3B82F6), label: 'Media'),
            const SizedBox(width: 14),
            const _LegendDot(color: Color(0xFFEF4444), label: 'Retos'),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: _BarChart(
              labels: _labels,
              mediaValues: media,
              retosValues: retos,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600)),
        ],
      );
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.labels,
    required this.mediaValues,
    required this.retosValues,
  });

  final List<String> labels;
  final List<double> mediaValues;
  final List<double> retosValues;

  @override
  Widget build(BuildContext context) {
    final maxVal =
        [...mediaValues, ...retosValues].fold<double>(0, (m, v) => max(m, v));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(labels.length, (i) {
        final mFrac = maxVal == 0 ? 0.0 : mediaValues[i] / maxVal;
        final rFrac = maxVal == 0 ? 0.0 : retosValues[i] / maxVal;
        final isLast = labels[i] == 'Actual';
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Media bar
                    Flexible(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: mFrac.clamp(0.05, 1.0),
                        child: Container(
                          width: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                    // Retos bar
                    Flexible(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: rFrac.clamp(0.05, 1.0),
                        child: Container(
                          width: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[i],
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: isLast ? _kNavy : Colors.grey.shade500,
                  fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Insights panel ────────────────────────────────────────────────────────────

class _InsightsPanel extends StatelessWidget {
  const _InsightsPanel({required this.students});

  final List<Map<String, dynamic>> students;

  // Mock top students + refuerzo until real data available
  static const _topStudents = [
    _StudentInsight(
        name: 'Lucas García', sub: 'Top 5% este mes', xp: '+120 xp'),
    _StudentInsight(
        name: 'Sofía Pérez', sub: 'Consistencia semanal', xp: '+95 xp'),
  ];
  static const _refuerzo = [
    _StudentInsight(name: 'Mateo Rivas', sub: '3 retos pendientes', xp: null),
    _StudentInsight(
        name: 'Valeria Luna', sub: 'Baja actividad (3 días)', xp: null),
  ];

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _InsightsSection(
          title: 'Mayor Progreso',
          titleIcon: Icons.trending_up_rounded,
          titleColor: _kNavy,
          borderColor: _kNavy,
          students: _topStudents,
          isProgress: true,
        ),
        SizedBox(height: 14),
        _InsightsSection(
          title: 'Necesitan Refuerzo',
          titleIcon: Icons.warning_amber_rounded,
          titleColor: Color(0xFFE11D48),
          borderColor: Color(0xFFE11D48),
          students: _refuerzo,
          isProgress: false,
        ),
      ],
    );
  }
}

class _StudentInsight {
  const _StudentInsight(
      {required this.name, required this.sub, required this.xp});
  final String name;
  final String sub;
  final String? xp;
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({
    required this.title,
    required this.titleIcon,
    required this.titleColor,
    required this.borderColor,
    required this.students,
    required this.isProgress,
  });

  final String title;
  final IconData titleIcon;
  final Color titleColor;
  final Color borderColor;
  final List<_StudentInsight> students;
  final bool isProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(titleIcon, size: 16, color: titleColor),
              const SizedBox(width: 6),
              Text(title,
                  style: GoogleFonts.fredoka(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 12),
            ...students.map((s) => _InsightRow(
                  student: s,
                  isProgress: isProgress,
                )),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.student, required this.isProgress});

  final _StudentInsight student;
  final bool isProgress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFDBEAFE),
          child: Text(
            student.name[0],
            style: GoogleFonts.fredoka(
                color: const Color(0xFF3B82F6),
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.name,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kNavy)),
              Text(student.sub,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
        if (isProgress && student.xp != null)
          Text(student.xp!,
              style: GoogleFonts.fredoka(
                  color: const Color(0xFF16A34A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700))
        else
          const Icon(Icons.mail_outline_rounded,
              size: 18, color: Color(0xFFE11D48)),
      ]),
    );
  }
}

// ── Challenges card ───────────────────────────────────────────────────────────

class _ChallengesCard extends StatelessWidget {
  const _ChallengesCard({required this.challenges});

  final List<Map<String, dynamic>> challenges;

  @override
  Widget build(BuildContext context) {
    final active = challenges.where((c) => c['status'] == 'active').toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.emoji_events_rounded, size: 18, color: _kNavy),
            const SizedBox(width: 8),
            Text('Retos Asignados',
                style: GoogleFonts.fredoka(
                    fontSize: 16, color: _kNavy, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${active.length} activos',
                  style: GoogleFonts.nunito(
                      color: _kNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 14),
          if (active.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Sin retos activos aún.',
                    style: GoogleFonts.nunito(color: Colors.grey.shade400)),
              ),
            )
          else
            ...active.take(4).map((c) => _ChallengeTile(c: c)),
        ],
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.c});
  final Map<String, dynamic> c;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          const Icon(Icons.task_alt_rounded,
              size: 16, color: Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(c['title'] ?? '—',
                style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _kNavy)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Activo',
                style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97706))),
          ),
        ]),
      );
}

// ── Subject performance card ──────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.performance});

  final List<SubjectPerformance> performance;

  static const _demo = [
    ('Matemáticas', 0.84, Color(0xFF3B82F6)),
    ('Lenguaje', 0.76, Color(0xFF8B5CF6)),
    ('Ciencias', 0.91, Color(0xFF10B981)),
    ('Historia', 0.68, Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    final data = performance.isEmpty
        ? _demo
        : performance
            .take(4)
            .map((p) => (
                  p.subject.label,
                  (p.averageScore / 100.0).clamp(0.0, 1.0),
                  p.subject.color,
                ))
            .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.school_rounded, size: 18, color: _kNavy),
            const SizedBox(width: 8),
            Text('Rendimiento por Materia',
                style: GoogleFonts.fredoka(
                    fontSize: 16, color: _kNavy, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          ...data.map((d) => _SubjectBar(
                label: d.$1,
                fraction: d.$2,
                color: d.$3,
              )),
        ],
      ),
    );
  }
}

class _SubjectBar extends StatelessWidget {
  const _SubjectBar({
    required this.label,
    required this.fraction,
    required this.color,
  });
  final String label;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: Text(label,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kNavy))),
              Text('${(fraction * 100).round()}%',
                  style: GoogleFonts.nunito(
                      fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      );
}

// ── Placeholder panel ─────────────────────────────────────────────────────────

class _PlaceholderPanel extends StatelessWidget {
  const _PlaceholderPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFBBB9E0)),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.fredoka(
                    fontSize: 22, color: _kNavy, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message,
                style: GoogleFonts.nunito(
                    color: Colors.grey.shade500, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3)),
      ],
    );
