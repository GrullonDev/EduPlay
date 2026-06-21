import 'package:edu_play/features/sticker_album/data/sticker_repository.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';

class StickerAlbumPage extends StatelessWidget {
  const StickerAlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Álbum de Estampas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const StickerAlbumGrid(),
    );
  }
}

/// Grid of [allStickers], unlocked ones tappable to show their detail.
/// Extracted so it can be embedded directly inside the student dashboard's
/// "Logros" section as well as shown as its own page.
class StickerAlbumGrid extends StatefulWidget {
  const StickerAlbumGrid({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  State<StickerAlbumGrid> createState() => _StickerAlbumGridState();
}

class _StickerAlbumGridState extends State<StickerAlbumGrid> {
  final StickerRepository _repository = StickerRepository();
  List<String> _unlockedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    final ids = await _repository.getUnlockedStickers();
    if (!mounted) return;
    setState(() {
      _unlockedIds = ids;
      _isLoading = false;
    });
  }

  void _showDetail(Sticker sticker) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sticker.icon, size: 80, color: sticker.color),
            const SizedBox(height: 20),
            Text(sticker.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(sticker.description, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = ScreenSize.fromConstraints(constraints);
        final cols = gridCols(s, mobile: 3, tablet: 4, desktop: 6);
        final iconSize = s.when(mobile: 36.0, tablet: 44.0, desktop: 52.0);
        final labelFontSize = s.isMobile ? 10.0 : 12.0;

        return GridView.builder(
          padding: widget.padding ?? EdgeInsets.all(s.isMobile ? 12 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: s.isMobile ? 8 : 10,
            mainAxisSpacing: s.isMobile ? 8 : 10,
          ),
          itemCount: allStickers.length,
          itemBuilder: (context, index) {
            final sticker = allStickers[index];
            final isUnlocked = _unlockedIds.contains(sticker.id);

            return GestureDetector(
              onTap: isUnlocked ? () => _showDetail(sticker) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.white : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isUnlocked ? Colors.deepPurple : Colors.grey,
                    width: isUnlocked ? 2 : 1,
                  ),
                  boxShadow: isUnlocked
                      ? [
                          const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2))
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
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
