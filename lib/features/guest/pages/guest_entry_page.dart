import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edu_play/features/guest/bloc/guest_entry_bloc.dart';
import 'package:edu_play/utils/app_theme.dart';

class GuestEntryPage extends StatelessWidget {
  const GuestEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuestEntryProvider(context: context),
      child: const _GuestEntryLayout(),
    );
  }
}

class _GuestEntryLayout extends StatelessWidget {
  const _GuestEntryLayout();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuestEntryProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)], // Light Blue Sky
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title / Greeting
                  Text(
                    '¡Hola Amigo!',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '¿Cómo te llamas?',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name Input Card
                  Container(
                    width: size.width > 600 ? 500 : double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: provider.nameController,
                      style: GoogleFonts.nunito(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Tu nombre aquí',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.shade300),
                        icon: const Icon(Icons.person,
                            color: AppTheme.secondaryColor, size: 32),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    '¿Cuántos años tienes?',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),

                  // Big Age Number Display
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor, // Orange
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '${provider.selectedAge}',
                      style: GoogleFonts.nunito(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Age Slider
                  SizedBox(
                    width: size.width > 600 ? 500 : double.infinity,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.secondaryColor,
                        inactiveTrackColor: Colors.white,
                        thumbColor: AppTheme.primaryColor,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 15.0),
                        overlayColor:
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: provider.selectedAge.toDouble(),
                        min: 3,
                        max: 12,
                        divisions: 9,
                        label: '${provider.selectedAge} años',
                        onChanged: (value) {
                          provider.setAge(value.round());
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Play Button
                  SizedBox(
                    width: 250,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () => provider.enterAsGuest(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        elevation: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_fill,
                              color: Colors.white, size: 32),
                          const SizedBox(width: 10),
                          Text(
                            '¡A JUGAR!',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
