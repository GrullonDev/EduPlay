import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/math_adventure/bloc/math_adventure_bloc.dart';

class MathAdventureHeader extends StatelessWidget {
  const MathAdventureHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MathAdventureProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoPill(
          icon: Icons.star_rounded,
          color: Colors.amber,
          label: '${bloc.score}',
          context: context,
        ),
        _buildInfoPill(
          icon: Icons.favorite_rounded,
          color: Colors.red,
          label: '${bloc.lives}',
          context: context,
        ),
      ],
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required Color color,
    required String label,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D3142),
                ),
          ),
        ],
      ),
    );
  }
}
