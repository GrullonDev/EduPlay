import 'package:edu_play/features/fun_english/bloc/fun_english_bloc.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/utils/responsive.dart';
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
              Color(0xFF16125C),
              Color(0xFF231B72),
              Color(0xFF12104A),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header (Score & Lives)
              LayoutBuilder(
                builder: (context, constraints) {
                  final s = ScreenSize.fromConstraints(constraints);
                  return Padding(
                    padding: EdgeInsets.all(s.isMobile ? 12.0 : 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatPill(Icons.star_rounded, '${bloc.score}',
                            Colors.amber, s),
                        Flexible(
                          child: Text(
                            'Inglés Divertido 🇬🇧',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: s.isMobile ? 18 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _buildStatPill(Icons.favorite_rounded, '${bloc.lives}',
                            Colors.red, s),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Question Card
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final s = ScreenSize.fromConstraints(constraints);
                    return Center(
                      child: SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.all(s.isMobile ? 16 : 24),
                          padding: EdgeInsets.all(s.isMobile ? 20 : 32),
                          constraints: const BoxConstraints(maxWidth: 600),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
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
                                  fontSize: s.isMobile ? 22 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: s.isMobile ? 24 : 40),

                              // Options Grid
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: List.generate(
                                    bloc.currentOptions.length, (index) {
                                  return _OptionButton(
                                    text: bloc.currentOptions[index],
                                    onTap: () => bloc.checkAnswer(index),
                                    s: s,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

  Widget _buildStatPill(IconData icon, String text, Color color, ScreenSize s) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: s.isMobile ? 10 : 16, vertical: s.isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: s.isMobile ? 20 : 28),
          SizedBox(width: s.isMobile ? 4 : 8),
          Text(text,
              style: GoogleFonts.nunito(
                  fontSize: s.isMobile ? 15 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton(
      {required this.text, required this.onTap, required this.s});
  final String text;
  final VoidCallback onTap;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final btnWidth = s.isDesktop ? 160.0 : (s.isTablet ? 148.0 : 130.0);
    final btnHeight = s.isMobile ? 64.0 : 80.0;
    final fontSize = s.isMobile ? 15.0 : 18.0;

    return SizedBox(
      width: btnWidth,
      height: btnHeight,
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
          style: GoogleFonts.nunito(
              fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
