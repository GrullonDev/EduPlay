import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/login/bloc/login_bloc.dart';
import 'package:edu_play/features/login/pages/login_layout.dart';
import 'package:edu_play/utils/injection_container.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.userType});

  /// Context the user came from: 'parent' or 'teacher'.
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
        backgroundColor: Colors.white,
        body: LoginLayout(userType: userType),
      ),
    );
  }
}
