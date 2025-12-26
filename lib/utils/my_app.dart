import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/login/pages/login_page.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/login_main/login_page.dart';
import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/utils/routes/router_switch.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RegisterProvider(context: context),
        ),
          create: (_) => RegisterParentsBloc(
            context: context,
            authRepository: sl.get<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'EduPlay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const LoginPage(),
        initialRoute: RouterPaths.root,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
