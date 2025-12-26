import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';

class LoginMainLayout extends StatelessWidget {
  const LoginMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSizeTitle = constraints.maxWidth > 600 ? 45 : 30;
        double fontSizeSubtitle = constraints.maxWidth > 600 ? 34 : 20;
        double fontSizeButton = constraints.maxWidth > 600 ? 34 : 20;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '¡Bienvenido a EduPlay!',
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Una plataforma educativa gamificada para niños y adolecentes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSizeSubtitle,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouterPaths.login),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: fontSizeButton,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouterPaths.guestEntry),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Jugar como Invitado',
                  style: TextStyle(
                    fontSize: fontSizeButton * 0.8,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
