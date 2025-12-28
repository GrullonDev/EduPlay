import 'package:edu_play/features/sticker_album/data/sticker_repository.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:flutter/material.dart';

class StickerAlbumPage extends StatefulWidget {
  const StickerAlbumPage({super.key});

  @override
  State<StickerAlbumPage> createState() => _StickerAlbumPageState();
}

class _StickerAlbumPageState extends State<StickerAlbumPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Álbum de Estampas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
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
                          size: 40,
                          color: isUnlocked ? sticker.color : Colors.grey[500],
                        ),
                        if (isUnlocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              sticker.name,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
