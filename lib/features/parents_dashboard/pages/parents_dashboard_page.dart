import 'package:edu_play/features/parents_dashboard/bloc/parents_dashboard_bloc.dart';
import 'package:edu_play/features/sticker_album/data/sticker_repository.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ParentsDashboardPage extends StatelessWidget {
  const ParentsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParentsDashboardBloc(),
      child: const _DashboardLayout(),
    );
  }
}

class _DashboardLayout extends StatefulWidget {
  const _DashboardLayout();

  @override
  State<_DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<_DashboardLayout> {
  int _stickerCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    final list = await StickerRepository().getUnlockedStickers();
    if (mounted) {
      setState(() {
        _stickerCount = list.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ParentsDashboardBloc>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Zona de Padres',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple, // More serious color for parents
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () {}, // Bloc reloads automatically on create, but we could expose a method
          )
        ],
      ),
      body: bloc.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bloc.children.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bloc.children.length,
                  itemBuilder: (context, index) {
                    final child = bloc.children[index];
                    final scores = bloc.getScoresForChild(child['id']);
                    return _buildChildCard(child, scores);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouterPaths.stickerAlbum),
        label: const Text('Ver Álbum'),
        icon: const Icon(Icons.star),
        backgroundColor: Colors.amber,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text('No hay niños registrados',
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChildCard(
      Map<String, dynamic> child, List<Map<String, dynamic>> scores) {
    final avatarKey = child['avatar'] ?? 'lion';
    final avatarIcon = _getAvatarIcon(avatarKey);
    final favoriteGame = _calculateFavoriteGame(scores);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Icon(avatarIcon, size: 30, color: Colors.blue[800]),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child['name'],
                          style: GoogleFonts.nunito(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('${child['age']} años • $_stickerCount Estampas',
                          style: GoogleFonts.nunito(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Partidas', '${scores.length}'),
                _buildStat('Juego Favorito', favoriteGame),
                _buildStat('Puntos Totales', '${_calculateTotalScore(scores)}'),
              ],
            ),

            const SizedBox(height: 20),
            Text('Historial Reciente',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Recent Scores (Max 3)
            ...scores.take(3).map((score) => _buildScoreRow(score)),

            if (scores.length > 3)
              Center(
                  child: TextButton(
                      onPressed: () {}, child: const Text('Ver todo')))
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple)),
        Text(label,
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildScoreRow(Map<String, dynamic> score) {
    // safe parsing
    final points = score['score'] as int;
    final gameName = score['game_type'] as String;
    // Simple progress visualization: assuming 10 or 100 max? Let's cap at 100 for visual
    final progress = (points / 20.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(_getGameIcon(gameName), size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
              child: Text(gameName, style: GoogleFonts.nunito(fontSize: 14))),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: _getScoreColor(points)),
          ),
          const SizedBox(width: 10),
          Text('$points pts',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 10) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  IconData _getAvatarIcon(String key) {
    switch (key) {
      case 'lion':
        return Icons.pets;
      case 'robot':
        return Icons.smart_toy;
      case 'rocket':
        return Icons.rocket_launch;
      case 'star':
        return Icons.star;
      case 'music':
        return Icons.music_note;
      case 'painter':
        return Icons.brush;
      default:
        return Icons.face;
    }
  }

  IconData _getGameIcon(String gameType) {
    if (gameType.contains('Matemática')) return Icons.calculate;
    if (gameType.contains('Palabras')) return Icons.abc;
    if (gameType.contains('Inglés')) return Icons.language;
    if (gameType.contains('Tesoro')) return Icons.map;
    return Icons.videogame_asset;
  }

  String _calculateFavoriteGame(List<Map<String, dynamic>> scores) {
    if (scores.isEmpty) return '-';
    final counts = <String, int>{};
    for (var s in scores) {
      final type = s['game_type'] as String;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    var sortedKeys = counts.keys.toList(growable: false)
      ..sort((k1, k2) => counts[k2]!.compareTo(counts[k1]!));
    return sortedKeys.first;
  }

  int _calculateTotalScore(List<Map<String, dynamic>> scores) {
    return scores.fold(0, (sum, item) => sum + (item['score'] as int));
  }
}
