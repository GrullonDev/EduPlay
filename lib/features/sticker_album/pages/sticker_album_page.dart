import 'package:edu_play/core/audio/sound_manager.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';

class StickerAlbumPage extends StatelessWidget {
  const StickerAlbumPage({super.key, required this.unlockedIds});

  final List<String> unlockedIds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Álbum de Estampas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StickerAlbumGrid(unlockedIds: unlockedIds),
    );
  }
}

/// Grid of [allStickers], unlocked ones tappable to show their detail.
/// Extracted so it can be embedded directly inside the student dashboard's
/// "Logros" section as well as shown as its own page. Purely presentational
/// — the caller owns fetching/deriving [unlockedIds].
class StickerAlbumGrid extends StatelessWidget {
  const StickerAlbumGrid({
    super.key,
    required this.unlockedIds,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<String> unlockedIds;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  void _showDetail(BuildContext context, Sticker sticker) {
    SoundManager().playPop();
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        type: DialogType.reward,
        title: sticker.name,
        content: sticker.description,
        buttonText: 'Cerrar',
        onButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlockedSet = unlockedIds.toSet();
    // The first locked sticker in order is the next one the child can earn —
    // give it a gentle pulse to draw the eye without making the whole grid busy.
    final nextToUnlockIndex =
        allStickers.indexWhere((s) => !unlockedSet.contains(s.id));

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = ScreenSize.fromConstraints(constraints);
        final cols = gridCols(s, mobile: 3, tablet: 4, desktop: 6);
        final iconSize = s.when(mobile: 36.0, tablet: 44.0, desktop: 52.0);
        final labelFontSize = s.isMobile ? 10.0 : 12.0;

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding ?? EdgeInsets.all(s.isMobile ? 12 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: s.isMobile ? 8 : 10,
            mainAxisSpacing: s.isMobile ? 8 : 10,
          ),
          itemCount: allStickers.length,
          itemBuilder: (context, index) {
            final sticker = allStickers[index];
            final isUnlocked = unlockedSet.contains(sticker.id);

            return _StaggeredEntrance(
              index: index,
              child: _StickerAlbumCell(
                sticker: sticker,
                isUnlocked: isUnlocked,
                pulse: !isUnlocked && index == nextToUnlockIndex,
                iconSize: iconSize,
                labelFontSize: labelFontSize,
                onTap: isUnlocked ? () => _showDetail(context, sticker) : null,
              ),
            );
          },
        );
      },
    );
  }
}

/// Fades + scales a cell in, with an index-based delay so the grid "pops in"
/// one card after another instead of appearing all at once.
class _StaggeredEntrance extends StatelessWidget {
  const _StaggeredEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index * 60).clamp(0, 600);
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final clamped = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clamped,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _StickerAlbumCell extends StatelessWidget {
  const _StickerAlbumCell({
    required this.sticker,
    required this.isUnlocked,
    required this.pulse,
    required this.iconSize,
    required this.labelFontSize,
    required this.onTap,
  });

  final Sticker sticker;
  final bool isUnlocked;
  final bool pulse;
  final double iconSize;
  final double labelFontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isUnlocked ? sticker.color : Colors.grey,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: sticker.color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? sticker.icon : Icons.question_mark,
            size: iconSize,
            color: isUnlocked ? sticker.color : Colors.grey[500],
          ),
          if (isUnlocked)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                sticker.name,
                style: TextStyle(
                    fontSize: labelFontSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: pulse ? _Pulse(child: card) : card,
    );
  }
}

/// Gentle looping opacity pulse for the next sticker the child can unlock.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}
