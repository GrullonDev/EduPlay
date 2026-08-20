// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/parent_child_stats_service.dart';
import 'package:edu_play/features/parents_dashboard/widgets/parent_child_activity_sheet.dart';
import 'package:edu_play/utils/child_portal_link.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);

class ParentChildProfilesGrid extends StatelessWidget {
  const ParentChildProfilesGrid({
    super.key,
    required this.profiles,
    required this.stats,
    required this.onDelete,
  });

  final List<ChildProfile> profiles;
  final Map<String, ChildGameplayStats> stats;
  final ValueChanged<ChildProfile> onDelete;

  @override
  Widget build(BuildContext context) {
    final cols =
        ScreenSize.of(context).isTablet || ScreenSize.of(context).isDesktop
            ? 2
            : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.6,
      ),
      itemCount: profiles.length,
      itemBuilder: (_, i) => _ChildCard(
        profile: profiles[i],
        stats: stats[profiles[i].id],
        onDelete: () => onDelete(profiles[i]),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.profile,
    required this.stats,
    required this.onDelete,
  });

  final ChildProfile profile;
  final ChildGameplayStats? stats;
  final VoidCallback onDelete;

  int get _level => stats?.level ?? profile.level;

  double get _levelProgress => stats?.levelProgress ?? profile.levelProgress;

  String get _levelLabel => 'Nivel ${_level.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProfileAvatar(profile: profile, levelLabel: _levelLabel),
          const SizedBox(width: 12),
          Expanded(
            child: _ProfileInfo(
              profile: profile,
              levelProgress: _levelProgress,
            ),
          ),
          const SizedBox(width: 10),
          _ProfileActions(
            profile: profile,
            stats: stats,
            onDelete: onDelete,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: Colors.grey[400],
            ),
            onPressed: () => _showOptions(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pin_rounded, color: _kNavy),
              title: Text(
                'Ver PIN de acceso',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPinDialog(context, profile);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: Text(
                'Eliminar perfil',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.levelLabel});

  final ChildProfile profile;
  final String levelLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: profile.avatarColor.withValues(alpha: 0.15),
          child: Text(
            profile.name[0].toUpperCase(),
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: profile.avatarColor,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: _kNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              levelLabel,
              style: GoogleFonts.nunito(
                fontSize: 7,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (profile.isOnline)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.profile, required this.levelProgress});

  final ChildProfile profile;
  final double levelProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                profile.name,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDF8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                profile.focusSubject,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _kNavy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          profile.isOnline
              ? 'Jugando ahora'
              : 'Ultima vez: ${profile.lastSeen}',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color:
                profile.isOnline ? const Color(0xFF2ECC71) : Colors.grey[500],
            fontWeight: profile.isOnline ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso de Nivel',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '${(levelProgress * 100).toInt()}%',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFF3F4F6),
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.profile,
    required this.stats,
    required this.onDelete,
  });

  final ChildProfile profile;
  final ChildGameplayStats? stats;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _showPinDialog(context, profile),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _kNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pin_rounded,
                  size: 12,
                  color: _kNavy.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'PIN',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _kNavy.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _showActivityDetail(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kNavy,
            side: BorderSide(color: Colors.grey.shade200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Detalle de Actividad',
            style:
                GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        if (ReleaseFlags.teacherExperienceEnabled) ...[
          const SizedBox(height: 6),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              RouterPaths.browseTeachers,
              arguments: profile,
            ),
            icon: const Icon(Icons.person_search_rounded, size: 12),
            label: Text(
              'Asignar Maestro',
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kCoral,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ],
    );
  }

  void _showActivityDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ParentChildActivitySheet(profile: profile, stats: stats),
    );
  }
}

void _showPinDialog(BuildContext context, ChildProfile profile) {
  showDialog(
    context: context,
    builder: (_) => _PinRevealDialog(profile: profile),
  );
}

class _PinRevealDialog extends StatelessWidget {
  const _PinRevealDialog({required this.profile});

  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profile.avatarColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    profile.name[0].toUpperCase(),
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: profile.avatarColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PIN de ${profile.name}',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comparte este codigo con ${profile.name}\npara que pueda acceder a su perfil.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDF8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: profile.pin.split('').map((digit) {
                    return Container(
                      width: 52,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          digit,
                          style: GoogleFonts.fredoka(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: _kNavy,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: profile.pin));
                      _showCopiedMessage(context, 'PIN copiado');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(
                      'Copiar PIN',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kNavy,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: childPortalUrl(profile)),
                      );
                      _showCopiedMessage(context, 'Enlace copiado');
                    },
                    icon: const Icon(Icons.link_rounded, size: 16),
                    label: Text(
                      'Copiar enlace',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kNavy,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCopiedMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunito()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _kNavy,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
