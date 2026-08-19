// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/store/bloc/store_bloc.dart';
import 'package:edu_play/features/store/models/store_item.dart';

const _kNavy = Color(0xFF1E1B6A);

/// Renders the same avatar circle formula used across the dashboard (see
/// `StudentTopNavBar` in student_dashboard_navigation.dart) so a preview
/// here always matches what actually shows up once equipped.
class AvatarPreviewCircle extends StatelessWidget {
  const AvatarPreviewCircle({
    super.key,
    required this.colorHex,
    required this.icon,
    required this.initial,
    this.radius = 44,
  });

  final String? colorHex;
  final IconData? icon;
  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          colorHex != null ? Color(int.parse('0xFF$colorHex')) : _kNavy,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: radius * 0.7)
          : Text(
              initial,
              style: GoogleFonts.fredoka(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }
}

/// Shows a before/after avatar preview and asks for confirmation before
/// equipping a color or icon. Returns true if the user confirmed.
Future<bool> showAvatarPreviewDialog(
  BuildContext context, {
  required StoreBloc storeBloc,
  required StoreItem item,
}) async {
  final bloc = storeBloc.dashboardBloc;
  final currentColorHex = bloc.equippedAvatarColorHex;
  final currentIcon = item.category == StoreCategory.avatarIcon
      ? null
      : (bloc.equippedAvatarIcon != null
          ? _iconFor(bloc.equippedAvatarIcon!)
          : null);
  final initial =
      bloc.displayName.isNotEmpty ? bloc.displayName[0].toUpperCase() : 'E';

  final newColorHex =
      item.category == StoreCategory.avatarColor ? item.colorHex : currentColorHex;
  final newIcon =
      item.category == StoreCategory.avatarIcon ? item.icon : currentIcon;

  return await showDialog<bool>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vista previa de tu avatar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          AvatarPreviewCircle(
                            colorHex: currentColorHex,
                            icon: currentIcon,
                            initial: initial,
                            radius: 36,
                          ),
                          const SizedBox(height: 6),
                          Text('Antes',
                              style: GoogleFonts.nunito(
                                  fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.arrow_forward_rounded, color: Colors.grey[400]),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          AvatarPreviewCircle(
                            colorHex: newColorHex,
                            icon: newIcon,
                            initial: initial,
                            radius: 44,
                          ),
                          const SizedBox(height: 6),
                          Text('Después',
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kNavy)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Equipar'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancelar',
                        style: GoogleFonts.nunito(color: Colors.grey[500])),
                  ),
                ],
              ),
            ),
          ),
        ),
      ) ??
      false;
}

IconData? _iconFor(String iconId) => avatarIconsById[iconId];
