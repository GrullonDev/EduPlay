import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginMainLayout extends StatelessWidget {
  const LoginMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnimatedBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Hero Logo / Title
                _buildHeroTitle(),
                const SizedBox(height: 20),

                // 2. Value Prop
                Text(
                  '¡Aprende jugando y diviértete!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4),
                      ]),
                ),
                const SizedBox(height: 60),

                // 3. Main Action: PLAY
                _buildPlayButton(context),

                const SizedBox(height: 30),

                // 4. Secondary Action: Parents/Login
                _buildParentsZoneButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTitle() {
    return Column(
      children: [
        const Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.white),
        Transform.rotate(
          angle: -0.1,
          child: Text(
            'EduPlay',
            style: GoogleFonts.fredoka(
                // Fun font
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  const Shadow(
                      color: Colors.deepPurple,
                      offset: Offset(4, 4),
                      blurRadius: 0),
                ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 70,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, RouterPaths.guestEntry),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.brown[800],
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
            side: const BorderSide(color: Colors.white, width: 3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, size: 32),
            const SizedBox(width: 10),
            Text(
              '¡JUGAR YA!',
              style:
                  GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentsZoneButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.pushNamed(context, RouterPaths.login),
      icon: const Icon(Icons.shield, color: Colors.white70),
      label: Text(
        'Zona de Padres (Acceso)',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 16,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final Widget child;
  const _AnimatedBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    // Simple static gradient for now, can be animated later
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF29B6F6), // Light Blue
              Color(0xFF81D4FA),
              Color(0xFFB3E5FC),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            const Positioned(
                top: -50, right: -50, child: _Circle(200, Colors.white12)),
            const Positioned(
                bottom: -100, left: -50, child: _Circle(300, Colors.white12)),
            child,
          ],
        ));
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
