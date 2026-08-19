import 'package:edu_play/core/auth/auth_gate.dart';
import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';
import 'package:edu_play/utils/routes/router_switch.dart';
import 'package:edu_play/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RegisterProvider(context: context),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterParentsBloc(
            context: context,
            authRepository: sl.get<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        // AuthGate listens to Firebase auth state and routes to the
        // correct dashboard (or login) on every cold start.
        home: AuthGate(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
