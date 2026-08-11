import 'package:edu_play/features/parents_dashboard/domain/repositories/parent_dashboard_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);

class ParentQuickControlsCard extends StatefulWidget {
  const ParentQuickControlsCard({super.key});

  @override
  State<ParentQuickControlsCard> createState() =>
      _ParentQuickControlsCardState();
}

class _ParentQuickControlsCardState extends State<ParentQuickControlsCard> {
  final ParentDashboardRepository _repository = sl<ParentDashboardRepository>();

  ParentQuickControls _controls = const ParentQuickControls();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadControls();
  }

  Future<void> _loadControls() async {
    try {
      final controls = await _repository.getQuickControls();
      if (mounted) setState(() => _controls = controls);
    } catch (_) {}
  }

  Future<void> _saveControls(ParentQuickControls controls) async {
    setState(() {
      _controls = controls;
      _saving = true;
    });
    try {
      await _repository.saveQuickControls(controls);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _dailyLimitLabel {
    final h = _controls.dailyLimitMinutes ~/ 60;
    final m = _controls.dailyLimitMinutes % 60;
    if (m == 0) return 'Activo · $h ${h == 1 ? 'hora' : 'horas'}';
    return 'Activo · ${h}h ${m}m';
  }

  String get _bedtimeLabel =>
      'Desde las ${_controls.bedtimeHour.toString().padLeft(2, '0')}:00';

  Future<void> _pickDailyLimit() async {
    final options = [
      (label: '30 minutos', minutes: 30),
      (label: '1 hora', minutes: 60),
      (label: '1.5 horas', minutes: 90),
      (label: '2 horas', minutes: 120),
      (label: '3 horas', minutes: 180),
    ];
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(
          'Límite Diario',
          style: GoogleFonts.fredoka(fontSize: 18, color: _kNavy),
        ),
        children: options
            .map(
              (o) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, o.minutes),
                child: Text(
                  o.label,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: _controls.dailyLimitMinutes == o.minutes
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (chosen != null && mounted) {
      await _saveControls(_controls.copyWith(dailyLimitMinutes: chosen));
    }
  }

  Future<void> _pickBedtimeHour() async {
    final hours = [18, 19, 20, 21, 22];
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(
          'Hora de Dormir',
          style: GoogleFonts.fredoka(fontSize: 18, color: _kNavy),
        ),
        children: hours
            .map(
              (h) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, h),
                child: Text(
                  '${h.toString().padLeft(2, '0')}:00',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: _controls.bedtimeHour == h
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (chosen != null && mounted) {
      await _saveControls(_controls.copyWith(bedtimeHour: chosen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kNavyDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_alt_rounded,
                size: 16,
                color: Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(
                'CONTROLES RÁPIDOS',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              if (_saving) ...[
                const Spacer(),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 1.5,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Daily limit
          GestureDetector(
            onTap: _pickDailyLimit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Límite Diario',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _dailyLimitLabel,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Bedtime
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _controls.bedtimeEnabled ? _pickBedtimeHour : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo Dormir',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _controls.bedtimeEnabled
                              ? _bedtimeLabel
                              : 'Desactivado',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Switch(
                  value: _controls.bedtimeEnabled,
                  onChanged: (v) async {
                    await _saveControls(_controls.copyWith(bedtimeEnabled: v));
                  },
                  activeThumbColor: const Color(0xFF2ECC71),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: WidgetStateProperty.all(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active Sessions card ──────────────────────────────────────────────────────
