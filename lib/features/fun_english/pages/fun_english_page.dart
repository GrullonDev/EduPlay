import 'package:edu_play/features/fun_english/bloc/fun_english_bloc.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';

class FunEnglishPage extends StatelessWidget {
  const FunEnglishPage({super.key});

  @override
  Widget build(BuildContext context) {
    final age = context.read<RegisterProvider>().age;
    // We might need to pass username too if we want to navigate filtering back,
    // but RegisterProvider usually holds session info. For now, assuming simple backnav.
    // If username is needed for specific args, we can grab it from somewhere else or pass it.
    // Simplifying for now.

    return ChangeNotifierProvider(
      create: (context) => FunEnglishProvider(
        context: context,
        age: int.tryParse(age) ?? 5,
        userName: 'Student', // Placeholder/Guest
      ),
      child: const _FunEnglishLayout(),
    );
  }
}

class _FunEnglishLayout extends StatelessWidget {
  const _FunEnglishLayout();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<FunEnglishProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF9A9E),
              Color(0xFFFECFEF)
            ], // Soft Red/Pink Gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header (Score & Lives)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatPill(
                        Icons.star_rounded, '${bloc.score}', Colors.amber),
                    Text(
                      'Inglés Divertido 🇬🇧',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    _buildStatPill(
                        Icons.favorite_rounded, '${bloc.lives}', Colors.red),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Question Card
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bloc.currentQuestion,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Options Grid
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: List.generate(bloc.currentOptions.length,
                              (index) {
                            return _OptionButton(
                              text: bloc.currentOptions[index],
                              onTap: () => bloc.checkAnswer(index),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Back Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OptionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140, // Fixed width for clean grid
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
        ),
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
