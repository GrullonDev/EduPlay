import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF3F2FF);

// ── Demo data ─────────────────────────────────────────────────────────────────

const _kClasses = [
  _ClassData(
    level: 'Primaria',
    levelColor: Color(0xFFE11D48),
    name: '3º A – Primaria',
    subject: 'Tutoría General',
    students: 24,
    engagement: 0.92,
    engagementColor: Color(0xFF16A34A),
  ),
  _ClassData(
    level: 'Secundaria',
    levelColor: Color(0xFF3B82F6),
    name: '2º B – Matemáticas',
    subject: 'Álgebra & Lógica',
    students: 31,
    engagement: 0.76,
    engagementColor: Color(0xFFE11D48),
  ),
  _ClassData(
    level: 'Bachillerato',
    levelColor: Color(0xFFD97706),
    name: '1º C – Física',
    subject: 'Cinemática',
    students: 28,
    engagement: 0.88,
    engagementColor: Color(0xFF16A34A),
  ),
];

// 7-day engagement percentages Mon–Sun
const _kEngagement = [0.55, 0.68, 0.60, 0.75, 0.85, 0.78, 0.70];
const _kDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

const _kRetos = [
  ('🚀', 'Misión Espacial', '3º A', '85% completado'),
  ('🧮', 'Maestros del Cálculo', '2º B', '42% completado'),
  ('🎨', 'Arte Moderno', '1º C', 'Nuevo reto'),
];

// ─────────────────────────────────────────────────────────────────────────────

class MisClasesPanel extends StatelessWidget {
  const MisClasesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(),
          const SizedBox(height: 20),
          _QuickStats(),
          const SizedBox(height: 24),
          _ClassGrid(),
          const SizedBox(height: 28),
          wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _EngagementChart()),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: _RetosEnCurso()),
                    ],
                  ),
                )
              : Column(children: [
                  _EngagementChart(),
                  const SizedBox(height: 20),
                  _RetosEnCurso(),
                ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestión de Aulas',
                style: GoogleFonts.fredoka(
                    fontSize: 26, color: _kNavy, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Supervisa el progreso y el compromiso de tus\nestudiantes en tiempo real.',
              style:
                  GoogleFonts.nunito(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
          label: Text('Add New Class',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kCoral,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ── Quick stats row ───────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const stats = [
      (Icons.school_rounded, 'TOTAL ESTUDIANTES', '142', Color(0xFF3B82F6)),
      (Icons.bolt_rounded, 'ENGAGEMENT PROMEDIO', '84%', Color(0xFFEC4899)),
      (Icons.assignment_rounded, 'TAREAS PENDIENTES', '12', Color(0xFFF59E0B)),
      (
        Icons.trending_up_rounded,
        'CRECIMIENTO MENSUAL',
        '+5.2%',
        Color(0xFF10B981)
      ),
    ];

    return LayoutBuilder(builder: (_, c) {
      final cols = c.maxWidth >= 600 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.0,
        children: stats
            .map((s) => _QuickStatPill(
                  icon: s.$1,
                  label: s.$2,
                  value: s.$3,
                  color: s.$4,
                ))
            .toList(),
      );
    });
  }
}

class _QuickStatPill extends StatelessWidget {
  const _QuickStatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
              Text(value,
                  style: GoogleFonts.fredoka(
                      fontSize: 18,
                      color: _kNavy,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Class grid ────────────────────────────────────────────────────────────────

class _ClassGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;
    final cols = wide ? 3 : 1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: wide ? 1.1 : 1.6,
      children: [
        ..._kClasses.map((c) => _ClassCard(cls: c)),
        _AddClassCard(),
      ],
    );
  }
}

class _ClassData {
  const _ClassData({
    required this.level,
    required this.levelColor,
    required this.name,
    required this.subject,
    required this.students,
    required this.engagement,
    required this.engagementColor,
  });
  final String level;
  final Color levelColor;
  final String name;
  final String subject;
  final int students;
  final double engagement;
  final Color engagementColor;
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});
  final _ClassData cls;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: cls.levelColor, width: 3)),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge + menu
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cls.levelColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cls.level,
                  style: GoogleFonts.nunito(
                      color: cls.levelColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
            const Spacer(),
            Icon(Icons.more_vert_rounded,
                size: 18, color: Colors.grey.shade400),
          ]),
          const SizedBox(height: 10),
          Text(cls.name,
              style: GoogleFonts.fredoka(
                  fontSize: 15, color: _kNavy, fontWeight: FontWeight.w700)),
          Text(cls.subject,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.person_outline_rounded,
                size: 14, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 4),
            Text('${cls.students} Estudiantes',
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Text('Engagement: ',
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.grey.shade500)),
            Text('${(cls.engagement * 100).round()}%',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: cls.engagementColor,
                    fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: cls.engagement,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(cls.engagementColor),
            ),
          ),
          const Spacer(),
          Row(children: [
            // Mini avatar stack
            SizedBox(
              width: 48,
              height: 24,
              child: Stack(
                children: List.generate(
                    3,
                    (i) => Positioned(
                          left: i * 14.0,
                          child: CircleAvatar(
                            radius: 11,
                            backgroundColor: [
                              const Color(0xFFDBEAFE),
                              const Color(0xFFFCE7F3),
                              const Color(0xFFD1FAE5)
                            ][i],
                            child: Text(['S', 'L', 'M'][i],
                                style: GoogleFonts.nunito(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: [
                                      const Color(0xFF3B82F6),
                                      const Color(0xFFEC4899),
                                      const Color(0xFF10B981)
                                    ][i])),
                          ),
                        )),
              ),
            ),
            Text('+${cls.students - 3}',
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.grey.shade400)),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Text('View Group →',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: _kNavy,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _AddClassCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFE0DEFF),
              width: 2,
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEDF8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  size: 24, color: Color(0xFFAAAAAA)),
            ),
            const SizedBox(height: 10),
            Text('Add New Class',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Configurar una nueva sección',
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.grey.shade400),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Engagement chart ──────────────────────────────────────────────────────────

class _EngagementChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Tendencia de Engagement',
                style: GoogleFonts.fredoka(
                    fontSize: 15, color: _kNavy, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDF8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Últimos 7 días',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: _kNavy,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_kDays.length, (i) {
                final isToday = i == 4; // Friday
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: _kEngagement[i],
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? _kNavy
                                    : _kNavy.withValues(alpha: 0.35),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(_kDays[i],
                          style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: isToday ? _kNavy : Colors.grey.shade400,
                              fontWeight:
                                  isToday ? FontWeight.w800 : FontWeight.w500)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Retos en Curso ────────────────────────────────────────────────────────────

class _RetosEnCurso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Retos en Curso',
              style: GoogleFonts.fredoka(
                  fontSize: 15, color: _kNavy, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ..._kRetos.map((r) =>
              _RetoRow(emoji: r.$1, name: r.$2, cls: r.$3, status: r.$4)),
          const Divider(height: 20),
          GestureDetector(
            onTap: () {},
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFFE0DEFF), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Ver Todos los Retos',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: _kNavy,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetoRow extends StatelessWidget {
  const _RetoRow({
    required this.emoji,
    required this.name,
    required this.cls,
    required this.status,
  });
  final String emoji;
  final String name;
  final String cls;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEDF8),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kNavy)),
              Text('$cls • $status',
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded,
            size: 18, color: Color(0xFFCCCCDD)),
      ]),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3))
      ],
    );
