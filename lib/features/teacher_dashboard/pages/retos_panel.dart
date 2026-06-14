import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);

// ── Demo data ─────────────────────────────────────────────────────────────────

enum _RetoStatus { active, scheduled, featured, completed, draft }

class _RetoData {
  const _RetoData({
    required this.status,
    required this.title,
    required this.subject,
    required this.group,
    this.progressFraction,
    this.dueDate,
    this.startDate,
    this.finalScore,
    this.points,
    this.participationFraction,
  });
  final _RetoStatus status;
  final String title;
  final String subject;
  final String group;
  final double? progressFraction;
  final String? dueDate;
  final String? startDate;
  final int? finalScore;
  final int? points;
  final double? participationFraction;
}

const _kRetos = [
  _RetoData(
    status: _RetoStatus.active,
    title: 'Dominio de Fracciones',
    subject: 'Matemáticas',
    group: '5to Grado A',
    progressFraction: 0.78,
    dueDate: '12 Oct',
  ),
  _RetoData(
    status: _RetoStatus.scheduled,
    title: 'Vocabulario: La Granja',
    subject: 'Lenguaje',
    group: '2do Grado B',
    startDate: '15 Oct',
  ),
  _RetoData(
    status: _RetoStatus.featured,
    title: 'Exploradores Galácticos',
    subject: 'Ciencias',
    group: 'Inter-escolar',
    participationFraction: 0.92,
    points: 1250,
  ),
  _RetoData(
    status: _RetoStatus.completed,
    title: 'Ortografía Creativa',
    subject: 'Lenguaje',
    group: '4to Grado C',
    finalScore: 98,
  ),
  _RetoData(
    status: _RetoStatus.draft,
    title: 'Viaje por el Cuerpo Humano',
    subject: 'Biología',
    group: 'Pendiente asignar curso',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class RetosPanel extends StatefulWidget {
  const RetosPanel({super.key});

  @override
  State<RetosPanel> createState() => _RetosPanelState();
}

class _RetosPanelState extends State<RetosPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: wide ? 32 : 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _Header(),
          const SizedBox(height: 20),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.grey.shade200, width: 1)),
            ),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w500, fontSize: 14),
              labelColor: _kNavy,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: _kNavy,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Activos (4)'),
                Tab(text: 'Borradores (2)'),
                Tab(text: 'Historial'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cards grid
          _RetosGrid(wide: wide),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DASHBOARD EDUCATIVO',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: _kCoral,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('Retos Gamificados',
                  style: GoogleFonts.fredoka(
                      fontSize: 30,
                      color: _kNavy,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                'Motiva a tus alumnos con desafíos interactivos diseñados\npara reforzar el aprendizaje de forma divertida y competitiva.',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
          label: Text('Nuevo Reto',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
    );
  }
}

// ── Cards grid ────────────────────────────────────────────────────────────────

class _RetosGrid extends StatelessWidget {
  const _RetosGrid({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cols = wide ? 3 : 1;
    final items = [
      ..._kRetos.map((r) => _RetoCard(reto: r)),
      _CreateRetoCard(),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: wide ? 0.75 : 1.5,
      children: items,
    );
  }
}

// ── Reto card ─────────────────────────────────────────────────────────────────

class _RetoCard extends StatelessWidget {
  const _RetoCard({required this.reto});
  final _RetoData reto;

  bool get _isFeatured => reto.status == _RetoStatus.featured;
  bool get _isDraft => reto.status == _RetoStatus.draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isFeatured ? _kNavy : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _isDraft
            ? Border.all(
                color: const Color(0xFFE0DEFF),
                width: 1.5,
                style: BorderStyle.solid)
            : null,
        boxShadow: _isDraft
            ? []
            : [
                BoxShadow(
                    color: _kNavy.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + menu row
          Row(children: [
            _StatusBadge(status: reto.status),
            const Spacer(),
            if (_isFeatured)
              Icon(Icons.star_border_rounded,
                  size: 18, color: Colors.white54)
            else if (!_isDraft)
              Icon(Icons.more_vert_rounded,
                  size: 18, color: Colors.grey.shade400),
          ]),
          const SizedBox(height: 14),

          // Title
          Text(
            reto.title,
            style: GoogleFonts.fredoka(
              fontSize: 20,
              color: _isFeatured ? Colors.white : _kNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${reto.subject} • ${reto.group}',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: _isFeatured
                  ? Colors.white60
                  : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 14),

          // Middle content
          if (reto.status == _RetoStatus.active) ...[
            _progressRow('Progreso Grupal',
                reto.progressFraction ?? 0,
                Colors.amber,
                '${((reto.progressFraction ?? 0) * 100).round()}%',
                featured: false),
          ] else if (reto.status == _RetoStatus.scheduled) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFE0DEFF), width: 1,
                    style: BorderStyle.solid),
              ),
              child: Center(
                child: Text('Empieza en 2 días',
                    style: GoogleFonts.nunito(
                        color: _kNavy,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ),
          ] else if (reto.status == _RetoStatus.featured) ...[
            _progressRow('Participación Activa',
                reto.participationFraction ?? 0,
                Colors.white,
                '${((reto.participationFraction ?? 0) * 100).round()}%',
                featured: true),
          ] else if (reto.status == _RetoStatus.completed) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RESULTADO FINAL',
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${reto.finalScore}%',
                      style: GoogleFonts.fredoka(
                          fontSize: 28,
                          color: _kNavy,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const Text('🏆', style: TextStyle(fontSize: 24)),
                ]),
              ],
            ),
          ] else if (reto.status == _RetoStatus.draft) ...[
            const Spacer(),
            Row(children: [
              const Spacer(),
              Icon(Icons.arrow_forward_rounded,
                  size: 18, color: Colors.grey.shade400),
            ]),
          ],

          const Spacer(),

          // Footer row
          if (reto.status == _RetoStatus.active)
            Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 12, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text('Vence: ${reto.dueDate}',
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.grey.shade500)),
              const Spacer(),
              // Mini avatars
              SizedBox(
                width: 52,
                height: 22,
                child: Stack(
                  children: List.generate(3, (i) => Positioned(
                    left: i * 14.0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: Text(['A', 'B', 'C'][i],
                          style: const TextStyle(
                              fontSize: 8, color: Color(0xFF3B82F6))),
                    ),
                  )),
                ),
              ),
              Text('+12', style: GoogleFonts.nunito(
                  fontSize: 10, color: Colors.grey.shade400)),
            ])
          else if (reto.status == _RetoStatus.scheduled)
            Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 12, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text('Inicio: ${reto.startDate}',
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.grey.shade500)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text('Editar Detalle',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: _kNavy,
                        fontWeight: FontWeight.w700)),
              ),
            ])
          else if (reto.status == _RetoStatus.featured)
            Row(children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 14, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                '${reto.points != null ? '${(reto.points! / 1000).toStringAsFixed(1).replaceAll('.0', '')},${(reto.points! % 1000).toString().padLeft(3, '0')}' : '0'} Puntos en juego',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600),
              ),
            ])
          else if (reto.status == _RetoStatus.completed)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0DEFF)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Ver Reporte Final',
                    style: GoogleFonts.nunito(
                        color: _kNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _progressRow(
      String label, double frac, Color barColor, String pctText,
      {required bool featured}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: featured ? Colors.white60 : Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(pctText,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: featured ? Colors.white : _kNavy,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 8,
            backgroundColor: featured
                ? Colors.white.withOpacity(0.2)
                : const Color(0xFFE8E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(
                featured ? Colors.white : barColor),
          ),
        ),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final _RetoStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, color, icon) = switch (status) {
      _RetoStatus.active =>
        ('Active', const Color(0xFFDCFCE7), const Color(0xFF16A34A),
            Icons.circle),
      _RetoStatus.scheduled =>
        ('Scheduled', const Color(0xFFFEF3C7), const Color(0xFFD97706),
            Icons.access_time_rounded),
      _RetoStatus.featured =>
        ('DESTACADO', Colors.white.withOpacity(0.15), Colors.white,
            null),
      _RetoStatus.completed =>
        ('Completed', const Color(0xFFEEEDF8), const Color(0xFF6366F1),
            Icons.check_circle_rounded),
      _RetoStatus.draft =>
        ('BORRADOR', Colors.transparent, const Color(0xFF9CA3AF),
            Icons.edit_note_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: status == _RetoStatus.draft
            ? Border.all(color: const Color(0xFFE0DEFF))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: status == _RetoStatus.active ? 8 : 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 11, color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Create reto card ──────────────────────────────────────────────────────────

class _CreateRetoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _kNavy.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDF8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  size: 28, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 12),
            Text('Crear nuevo reto',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: _kNavy,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Explora la biblioteca de plantillas',
                style: GoogleFonts.nunito(
                    fontSize: 12, color: Colors.grey.shade400),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
