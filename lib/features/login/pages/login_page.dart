import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/login/bloc/login_bloc.dart';
import 'package:edu_play/features/login/pages/login_layout.dart';
import 'package:edu_play/utils/injection_container.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.userType});

  /// Context the user came from: 'parent' or 'teacher'. Customizes the
  /// copy shown on the login screen.
  final String? userType;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginBloc>(
      create: (context) => LoginBloc(
        context: context,
        authRepository: sl.get<AuthRepository>(),
        userType: userType,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C63FF), // Primary
                Color(0xFF00BFA6), // Secondary
              ],
            ),
          ),
          child: LoginLayout(userType: userType),
        ),
      ),
    );
  }
}
