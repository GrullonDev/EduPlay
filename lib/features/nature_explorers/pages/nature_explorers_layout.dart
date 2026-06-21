import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/nature_explorers/bloc/nature_explorers_bloc.dart';

class NatureExplorersLayout extends StatelessWidget {
  const NatureExplorersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NatureExplorersProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = ScreenSize.fromConstraints(constraints);
        return _NatureExplorersContent(provider: provider, s: s);
      },
    );
  }
}

class _NatureExplorersContent extends StatelessWidget {
  const _NatureExplorersContent({required this.provider, required this.s});
  final NatureExplorersProvider provider;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final cols = s.when(mobile: 2, tablet: 3, desktop: 4);
    final iconSize = s.when(mobile: 44.0, tablet: 56.0, desktop: 64.0);
    final scoreFontSize = s.isMobile ? 14.0 : 18.0;
    final targetFontSize = s.isMobile ? 26.0 : 32.0;

    return Column(
      children: [
        // Header / Score
        Padding(
          padding: EdgeInsets.all(s.isMobile ? 12.0 : 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: s.isMobile ? 14 : 20,
                      vertical: s.isMobile ? 8 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Nivel: ${provider.level}  |  Puntos: ${provider.score}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: scoreFontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Instruction
        Container(
          margin: EdgeInsets.symmetric(
              vertical: s.isMobile ? 12 : 20, horizontal: s.isMobile ? 12 : 0),
          padding: EdgeInsets.all(s.isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Encuentra:',
                style: TextStyle(
                    fontSize: s.isMobile ? 16 : 20, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                provider.targetName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: targetFontSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),

        // Feedback Message
        if (provider.feedbackMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                  horizontal: s.isMobile ? 16 : 24,
                  vertical: s.isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: provider.feedbackColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                provider.feedbackMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: s.isMobile ? 15 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Game Grid
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(s.isMobile ? 12.0 : 16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: s.isMobile ? 12 : 16,
                mainAxisSpacing: s.isMobile ? 12 : 16,
                childAspectRatio: 1.0,
              ),
              itemCount: provider.currentItems.length,
              itemBuilder: (context, index) {
                final item = provider.currentItems[index];
                return GestureDetector(
                  onTap: () => provider.checkItem(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: iconSize, color: item.color),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
