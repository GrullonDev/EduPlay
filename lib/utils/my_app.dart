import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/login/pages/login_page.dart';
import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
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
        ChangeNotifierProvider(
          create: (_) => MenuProvider(context: context),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginPage(),
        initialRoute: RouterPaths.root,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
