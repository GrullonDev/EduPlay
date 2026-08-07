import 'package:flutter/material.dart';

import 'package:edu_play/features/friends/pages/friends_view.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';

const _kBg = Color(0xFFF8F7FF);

/// Standalone routed page for the parent "Amigos" nav tab.
class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  String _parentName = 'Mamá';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    String name = _parentName;
    try {
      name = await ChildProfilesService.getParentName();
    } catch (_) {
      // Keep the fallback name — Friends still works without it.
    }
    if (!mounted) return;
    setState(() {
      _parentName = name;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          EduPlayNavBar.parent(
            activeParentTab: ParentTab.amigos,
            parentName: _parentName,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : FriendsView(
                    identity: parentIdentity(_parentName),
                    subtitle:
                        'Conecta con otras familias de EduPlay para coordinar retos y compartir el progreso de tus hijos.',
                  ),
          ),
        ],
      ),
    );
  }
}
