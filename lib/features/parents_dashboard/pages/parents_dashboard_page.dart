import 'package:edu_play/features/parents_dashboard/bloc/parents_dashboard_bloc.dart';
import 'package:edu_play/utils/app_theme.dart';
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

class _DashboardLayout extends StatelessWidget {
  const _DashboardLayout();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ParentsDashboardBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Zona de Padres',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: bloc.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bloc.children.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.family_restroom,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        'No hay niños registrados aún.',
                        style: GoogleFonts.nunito(
                            fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bloc.children.length,
                  itemBuilder: (context, index) {
                    final child = bloc.children[index];
                    final scores = bloc.getScoresForChild(child['id']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getAvatarColor(index),
                          child: Text(
                            child['name'][0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          child['name'],
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${child['age']} años',
                          style: GoogleFonts.nunito(fontSize: 16),
                        ),
                        children: [
                          if (scores.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Aún no ha jugado ningún juego.',
                                style: GoogleFonts.nunito(
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          else
                            ...scores.map((score) => ListTile(
                                  leading: Icon(
                                    _getGameIcon(score['game_type']),
                                    color: AppTheme.secondaryColor,
                                  ),
                                  title: Text(
                                    score['game_type'],
                                    style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      '${score['score']} pts',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: AppTheme.accentColor,
                                  ),
                                )),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Color _getAvatarColor(int index) {
    const colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getGameIcon(String gameType) {
    switch (gameType) {
      case 'Math Adventure':
        return Icons.calculate;
      case 'Magic Words':
        return Icons.abc;
      default:
        return Icons.videogame_asset;
    }
  }
}
