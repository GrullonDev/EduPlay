import 'package:flutter/material.dart';

import 'package:edu_play/features/landing/widgets/landing_navbar.dart';
import 'package:edu_play/features/landing/widgets/landing_hero_section.dart';
import 'package:edu_play/features/landing/widgets/landing_stats_section.dart';
import 'package:edu_play/features/landing/widgets/landing_families_section.dart';
import 'package:edu_play/features/landing/widgets/landing_games_section.dart';
import 'package:edu_play/features/landing/widgets/landing_testimonials_section.dart';
import 'package:edu_play/features/landing/widgets/landing_footer.dart';

/// Public landing page presenting EduPlay to students, families and
/// teachers, with navigation to play, register or log in.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _gamesKey = GlobalKey();
  final _familiesKey = GlobalKey();
  final _testimonialsKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          LandingNavBar(
            onNavigateToGames: () => _scrollTo(_gamesKey),
            onNavigateToFamilies: () => _scrollTo(_familiesKey),
            onNavigateToCommunity: () => _scrollTo(_testimonialsKey),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LandingHeroSection(
                    onSeeGames: () => _scrollTo(_gamesKey),
                  ),
                  const LandingStatsSection(),
                  Container(
                    key: _familiesKey,
                    child: const LandingFamiliesSection(),
                  ),
                  Container(
                    key: _gamesKey,
                    child: const LandingGamesSection(),
                  ),
                  Container(
                    key: _testimonialsKey,
                    child: const LandingTestimonialsSection(),
                  ),
                  const LandingFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
