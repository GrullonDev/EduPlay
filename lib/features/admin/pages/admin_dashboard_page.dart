// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/admin/domain/entities/platform_stats.dart';
import 'package:edu_play/features/admin/domain/repositories/admin_dashboard_repository.dart';
import 'package:edu_play/features/admin/pages/admin_classes_page.dart';
import 'package:edu_play/features/admin/pages/admin_store_catalog_page.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/responsive.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);
const _kLav = Color(0xFFEEEDF8);

// ── Model ─────────────────────────────────────────────────────────────────────

// ── Page ──────────────────────────────────────────────────────────────────────

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminDashboardRepository _repository = sl<AdminDashboardRepository>();
  late Future<PlatformStats?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _load();
  }

  Future<PlatformStats?> _load() {
    return _repository.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        title: Text(
          'Panel de administración',
          style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => setState(() => _statsFuture = _load()),
          ),
        ],
      ),
      body: FutureBuilder<PlatformStats?>(
        future: _statsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: _kNavy, strokeWidth: 2));
          }
          if (snap.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 48, color: _kCoral),
                  const SizedBox(height: 16),
                  Text(
                    'Acceso restringido',
                    style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _kNavy),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Solo los administradores de la plataforma\npueden ver este panel.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final stats = snap.data!;
          return _StatsView(stats: stats);
        },
      ),
    );
  }
}

// ── Stats view ────────────────────────────────────────────────────────────────

class _StatsView extends StatelessWidget {
  const _StatsView({required this.stats});
  final PlatformStats stats;

  @override
  Widget build(BuildContext context) {
    final wide = ScreenSize.of(context).isDesktop;
    return SingleChildScrollView(
      padding: EdgeInsets.all(wide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de la plataforma',
            style: GoogleFonts.fredoka(
                fontSize: 22, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(height: 20),

          // Stat cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                emoji: '👨‍👩‍👧',
                label: 'Padres registrados',
                value: stats.totalParents,
                color: const Color(0xFF3B82F6),
              ),
              _StatCard(
                emoji: '👶',
                label: 'Perfiles de niños',
                value: stats.totalChildren,
                color: const Color(0xFF8B5CF6),
              ),
              _StatCard(
                emoji: '🎮',
                label: 'Sesiones de práctica',
                value: stats.totalSessions,
                color: _kCoral,
              ),
              _StatCard(
                emoji: '🏫',
                label: 'Clases de profesores',
                value: stats.totalClasses,
                color: const Color(0xFF16A34A),
              ),
              _StatCard(
                emoji: '⭐',
                label: 'Suscriptores Pro',
                value: stats.proSubscribers,
                color: const Color(0xFFD97706),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Conversion rate
          Text(
            'Tasa de conversión',
            style: GoogleFonts.fredoka(
                fontSize: 18, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(height: 12),
          _ConversionCard(
            pro: stats.proSubscribers,
            total: stats.totalParents,
          ),

          const SizedBox(height: 36),

          // Quick admin actions
          Text(
            'Acciones rápidas',
            style: GoogleFonts.fredoka(
                fontSize: 18, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.storefront_rounded,
            label: 'Catálogo de la Tienda',
            subtitle: 'Precios, PRO, nivel y temporadas',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminStoreCatalogPage()),
            ),
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.school_rounded,
            label: 'Ver todas las clases',
            subtitle: '${stats.totalClasses} clases activas',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminClassesPage()),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value.toString(),
            style: GoogleFonts.fredoka(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ConversionCard extends StatelessWidget {
  const _ConversionCard({required this.pro, required this.total});
  final int pro;
  final int total;

  @override
  Widget build(BuildContext context) {
    final rate = total > 0 ? (pro / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$rate%',
                style: GoogleFonts.fredoka(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pro de $total usuarios son Pro',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'free → pro',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? pro / total : 0,
              minHeight: 10,
              backgroundColor: _kLav,
              valueColor: const AlwaysStoppedAnimation(_kCoral),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kLav,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: _kNavy),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kNavy)),
                  Text(subtitle,
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
