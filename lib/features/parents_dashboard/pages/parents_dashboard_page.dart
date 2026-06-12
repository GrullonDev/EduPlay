import 'package:edu_play/features/parents_dashboard/bloc/parents_dashboard_bloc.dart';
import 'package:edu_play/shared/widgets/dashboard_shell.dart';
import 'package:edu_play/shared/widgets/simple_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const _kNavy = Color(0xFF24235B);
const _kCoral = Color(0xFFFF6E6C);
const _kGreen = Color(0xFF2ECC71);

const _navItems = [
  DashboardNavItem(icon: Icons.family_restroom_rounded, label: 'Family Overview'),
  DashboardNavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
  DashboardNavItem(icon: Icons.credit_card_rounded, label: 'Subscription'),
  DashboardNavItem(icon: Icons.settings_rounded, label: 'Settings'),
];

class ParentsDashboardPage extends StatelessWidget {
  const ParentsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParentsDashboardBloc(),
      child: const _DashboardLayout(),
    );
  }
}

class _DashboardLayout extends StatefulWidget {
  const _DashboardLayout();

  @override
  State<_DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<_DashboardLayout> {
  int _selectedNav = 0;
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ParentsDashboardBloc>();
    final children = bloc.children;
    final selectedChild =
        children.isNotEmpty ? children[_selectedChildIndex] : null;

    final parentName = 'Maria'; // TODO: from auth profile

    Widget body;
    if (bloc.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      switch (_selectedNav) {
        case 0:
          body = _OverviewView(
            parentName: parentName,
            selectedChild: selectedChild,
            scores: selectedChild != null
                ? bloc.getScoresForChild(selectedChild['id'] as int)
                : [],
            children: children,
            selectedChildIndex: _selectedChildIndex,
            onChildChanged: (i) => setState(() => _selectedChildIndex = i),
          );
          break;
        default:
          body = _PlaceholderView(item: _navItems[_selectedNav]);
      }
    }

    return DashboardShell(
      title: 'EduPlay',
      accentColor: _kNavy,
      items: _navItems,
      selectedIndex: _selectedNav,
      onSelect: (i) => setState(() => _selectedNav = i),
      body: body,
      footer: _SidebarFooter(name: parentName),
    );
  }
}

// ── Overview ──────────────────────────────────────────────────────────────────

class _OverviewView extends StatelessWidget {
  const _OverviewView({
    required this.parentName,
    required this.selectedChild,
    required this.scores,
    required this.children,
    required this.selectedChildIndex,
    required this.onChildChanged,
  });

  final String parentName;
  final Map<String, dynamic>? selectedChild;
  final List<Map<String, dynamic>> scores;
  final List<Map<String, dynamic>> children;
  final int selectedChildIndex;
  final ValueChanged<int> onChildChanged;

  String get _childName =>
      selectedChild?['name'] as String? ?? 'tu hijo/a';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── Top header ──────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANEL DE PADRES',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: _kCoral,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¡Hola, $parentName!',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (children.isNotEmpty)
              _ChildSwitcher(
                children: children,
                selectedIndex: selectedChildIndex,
                onChanged: onChildChanged,
              ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Main content ────────────────────────────────────────────────
        if (isDesktop)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _WeeklySummaryCard(scores: scores)),
                const SizedBox(width: 20),
                Expanded(
                    flex: 3,
                    child: _RecentAchievementsCard(childName: _childName)),
              ],
            ),
          )
        else ...[
          _WeeklySummaryCard(scores: scores),
          const SizedBox(height: 16),
          _RecentAchievementsCard(childName: _childName),
        ],
        const SizedBox(height: 20),
        if (isDesktop)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _ParentalControlsCard()),
                const SizedBox(width: 20),
                Expanded(child: _UpcomingChallengesCard(scores: scores)),
              ],
            ),
          )
        else ...[
          _ParentalControlsCard(),
          const SizedBox(height: 16),
          _UpcomingChallengesCard(scores: scores),
        ],
      ],
    );
  }
}

// ── Child Switcher ────────────────────────────────────────────────────────────

class _ChildSwitcher extends StatelessWidget {
  const _ChildSwitcher({
    required this.children,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> children;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final child = children[selectedIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<int>(
        onSelected: onChanged,
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _kNavy.withValues(alpha: 0.1),
              child: const Icon(Icons.face_rounded, size: 18, color: _kNavy),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Viendo a ${child['name']}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'CAMBIAR PERFIL',
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more_rounded,
                size: 18, color: _kNavy),
          ],
        ),
        itemBuilder: (_) => [
          for (var i = 0; i < children.length; i++)
            PopupMenuItem(
              value: i,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: _kNavy.withValues(alpha: 0.1),
                    child: const Icon(Icons.face_rounded,
                        size: 14, color: _kNavy),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    children[i]['name'] as String,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Weekly Summary ────────────────────────────────────────────────────────────

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.scores});

  final List<Map<String, dynamic>> scores;

  int get _totalScore =>
      scores.fold(0, (s, item) => s + (item['score'] as int? ?? 0));

  String get _totalTime {
    final mins = _totalScore * 3; // rough: 3 min per score unit
    return '${mins ~/ 60}h ${mins % 60}m';
  }

  List<BarChartEntry> get _weekBars {
    final days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    // Distribute scores across days for demo
    final vals = List<double>.filled(7, 0);
    for (var i = 0; i < scores.length; i++) {
      vals[i % 7] += ((scores[i]['score'] as int? ?? 0) / 20.0).clamp(0, 1);
    }
    final max = vals.reduce((a, b) => a > b ? a : b);
    return List.generate(
      7,
      (i) => BarChartEntry(
        label: days[i],
        value: max > 0 ? vals[i] / max : 0,
        color:
            i == 6 ? _kNavy : const Color(0xFFD5D3F0),
      ),
    );
  }

  List<String> get _topSubjects {
    final counts = <String, int>{};
    for (final s in scores) {
      final type = s['game_type'] as String? ?? 'General';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    final sorted = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Resumen semanal',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '20 Oct – 26 Oct',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TIEMPO JUGADO',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _totalTime,
                    style: GoogleFonts.fredoka(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          size: 14, color: _kCoral),
                      const SizedBox(width: 4),
                      Text(
                        '+12% vs semana pasada',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: _kCoral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MATERIAS DESTACADAS',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._topSubjects.map(
                          (s) => _SubjectChip(label: _shortName(s)),
                        ),
                        if (_topSubjects.isEmpty) ...[
                          const _SubjectChip(
                              label: 'Matemáticas',
                              color: Color(0xFFE8E6FF)),
                          const _SubjectChip(
                              label: 'Lógica',
                              color: Color(0xFFFFE8E8)),
                          const _SubjectChip(
                              label: 'Ciencia',
                              color: Color(0xFFFFF3CC)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SimpleBarChart(bars: _weekBars, height: 180),
        ],
      ),
    );
  }

  String _shortName(String gameType) {
    if (gameType.contains('Matemática') || gameType.contains('Math')) {
      return 'Matemáticas';
    }
    if (gameType.contains('Palabras') || gameType.contains('Inglés')) {
      return 'Idiomas';
    }
    if (gameType.contains('Tesoro')) return 'Exploración';
    return gameType.length > 12 ? '${gameType.substring(0, 12)}…' : gameType;
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    this.color = const Color(0xFFE8E6FF),
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _kNavy,
        ),
      ),
    );
  }
}

// ── Recent Achievements ───────────────────────────────────────────────────────

class _RecentAchievementsCard extends StatelessWidget {
  const _RecentAchievementsCard({required this.childName});

  final String childName;

  static const _achievements = [
    ('Genio de Fracciones', 'Completado ayer', Icons.emoji_events_rounded),
    ('Racha de 5 días', 'Manteniendo el ritmo', Icons.local_fire_department_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D2B6B), Color(0xFF1A1850)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logros recientes',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          for (final (title, subtitle, icon) in _achievements) ...[
            _AchievementTile(title: title, subtitle: subtitle, icon: icon),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B8700),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Ver todos los logros',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
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

// ── Parental Controls ─────────────────────────────────────────────────────────

class _ParentalControlsCard extends StatefulWidget {
  @override
  State<_ParentalControlsCard> createState() => _ParentalControlsCardState();
}

class _ParentalControlsCardState extends State<_ParentalControlsCard> {
  bool _bedtimeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _kNavy.withValues(alpha: 0.2),
          width: 1.5,
          // Dart doesn't natively support dashed border — we use a solid
          // thin border as a close approximation.
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kCoral.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.shield_rounded, color: _kCoral, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control Parental',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                  Text(
                    'Configura límites y seguridad',
                    style: GoogleFonts.nunito(
                        color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ControlRow(
            icon: Icons.timer_outlined,
            label: 'Límite Diario',
            value: '1h 30m',
            trailing: TextButton(
              onPressed: () {},
              child: Text(
                'EDITAR',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _kNavy,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ControlRow(
            icon: Icons.bedtime_outlined,
            label: 'Hora de Dormir',
            value: '20:30',
            trailing: Switch.adaptive(
              value: _bedtimeEnabled,
              onChanged: (v) => setState(() => _bedtimeEnabled = v),
              activeColor: _kCoral,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: _kNavy,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: _kNavy,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

// ── Upcoming Challenges ───────────────────────────────────────────────────────

class _UpcomingChallengesCard extends StatelessWidget {
  const _UpcomingChallengesCard({required this.scores});

  final List<Map<String, dynamic>> scores;

  static const _demo = [
    (
      'MATEMÁTICAS',
      'Dominio del Álgebra',
      'Vence el 27/10',
      '45% completado',
      Color(0xFFFFEBEB),
      Color(0xFFE53935),
    ),
    (
      'ESCRITURA',
      'Escritura Creativa',
      'Vence el 28/10',
      'Nuevos ejercicios',
      Color(0xFFE8F5E9),
      Color(0xFF43A047),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximos Retos',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 16),
          for (final (subject, title, due, progress, bg, accent)
              in _demo) ...[
            _ChallengeItem(
              subject: subject,
              title: title,
              due: due,
              progress: progress,
              bg: bg,
              accent: accent,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  const _ChallengeItem({
    required this.subject,
    required this.title,
    required this.due,
    required this.progress,
    required this.bg,
    required this.accent,
  });

  final String subject;
  final String title;
  final String due;
  final String progress;
  final Color bg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accent, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                due,
                style: GoogleFonts.nunito(
                    fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              Text(
                progress,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Placeholder ───────────────────────────────────────────────────────────────

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.item});

  final DashboardNavItem item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            item.label,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente disponible',
            style: GoogleFonts.nunito(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ── Sidebar Footer ────────────────────────────────────────────────────────────

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _kNavy,
            child: Text(
              name[0],
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name García',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _kNavy,
                  ),
                ),
                Text(
                  'Plan Premium',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
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

// ── Shared card wrapper ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
