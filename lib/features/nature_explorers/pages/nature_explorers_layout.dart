import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/nature_explorers/bloc/nature_explorers_bloc.dart';

class NatureExplorersLayout extends StatelessWidget {
  const NatureExplorersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NatureExplorersProvider>();
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        // Header / Score
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nivel: ${provider.level}  |  Puntos: ${provider.score}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Instruction
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(20),
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
              const Text(
                'Encuentra:',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                provider.targetName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),

        // Feedback Message
        if (provider.feedbackMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: provider.feedbackColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                provider.feedbackMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Game Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLargeScreen ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
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
                        Icon(
                          item.icon,
                          size: isLargeScreen ? 64 : 48,
                          color: item.color,
                        ),
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
