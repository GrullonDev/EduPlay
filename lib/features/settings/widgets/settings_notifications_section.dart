import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/settings/domain/entities/notification_preferences.dart';
import 'package:edu_play/features/settings/domain/repositories/settings_repository.dart';
import 'package:edu_play/features/settings/widgets/settings_section_card.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);

class SettingsNotificationsSection extends StatefulWidget {
  const SettingsNotificationsSection(
      {super.key, SettingsRepository? repository})
      : _repository = repository;

  final SettingsRepository? _repository;

  @override
  State<SettingsNotificationsSection> createState() =>
      SettingsNotificationsSectionState();
}

class SettingsNotificationsSectionState
    extends State<SettingsNotificationsSection> {
  bool _loading = true;
  bool _saving = false;

  // Toggle states — keys mirror Firestore fields
  bool _emailSessionComplete = true;
  bool _emailWeeklyDigest = true;
  bool _emailTips = false;
  bool _emailNewFeatures = true;

  SettingsRepository get _repository {
    init();
    return widget._repository ?? sl<SettingsRepository>();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await _repository.getNotificationPreferences();
      setState(() {
        _emailSessionComplete = prefs.emailSessionComplete;
        _emailWeeklyDigest = prefs.emailWeeklyDigest;
        _emailTips = prefs.emailTips;
        _emailNewFeatures = prefs.emailNewFeatures;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repository.updateNotificationPreferences(
        NotificationPreferences(
          emailSessionComplete: _emailSessionComplete,
          emailWeeklyDigest: _emailWeeklyDigest,
          emailTips: _emailTips,
          emailNewFeatures: _emailNewFeatures,
        ),
      );
    } catch (_) {}
    if (mounted) setState(() => _saving = false);
  }

  void _toggle(String field, bool value) {
    setState(() {
      switch (field) {
        case 'emailSessionComplete':
          _emailSessionComplete = value;
        case 'emailWeeklyDigest':
          _emailWeeklyDigest = value;
        case 'emailTips':
          _emailTips = value;
        case 'emailNewFeatures':
          _emailNewFeatures = value;
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionCard(
          icon: Icons.notifications_none_rounded,
          title: 'Notificaciones',
          child: Column(
            children: [
              _NotifGroup(
                title: 'CORREO ELECTRÓNICO',
                items: [
                  _NotifItem(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF27AE60),
                    title: 'Sesión completada',
                    subtitle:
                        'Recibe un email cuando tu hijo/a termine una sesión de práctica.',
                    value: _emailSessionComplete,
                    onChanged: (v) => _toggle('emailSessionComplete', v),
                  ),
                  _NotifItem(
                    icon: Icons.calendar_today_rounded,
                    iconColor: const Color(0xFF3498DB),
                    title: 'Resumen semanal',
                    subtitle:
                        'Un resumen del progreso de tus hijos cada lunes.',
                    value: _emailWeeklyDigest,
                    onChanged: (v) => _toggle('emailWeeklyDigest', v),
                  ),
                  _NotifItem(
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: const Color(0xFFF39C12),
                    title: 'Consejos de aprendizaje',
                    subtitle:
                        'Artículos y sugerencias para mejorar el aprendizaje en casa.',
                    value: _emailTips,
                    onChanged: (v) => _toggle('emailTips', v),
                  ),
                  _NotifItem(
                    icon: Icons.new_releases_outlined,
                    iconColor: _kNavy,
                    title: 'Novedades de EduPlay',
                    subtitle:
                        'Nuevos juegos, funciones y actualizaciones de la plataforma.',
                    value: _emailNewFeatures,
                    onChanged: (v) => _toggle('emailNewFeatures', v),
                  ),
                ],
              ),
              if (_saving) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: _kNavy, strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Guardando preferencias...',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 40),
        const SettingsFooter(),
      ],
    );
  }
}

class _NotifGroup extends StatelessWidget {
  const _NotifGroup({required this.title, required this.items});
  final String title;
  final List<_NotifItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: _kNavy.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: item,
            )),
      ],
    );
  }
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _kNavy,
          ),
        ],
      ),
    );
  }
}
