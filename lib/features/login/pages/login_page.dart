import 'package:edu_play/features/login/bloc/login_bloc.dart';
import 'package:edu_play/features/login/pages/login_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginBloc(),
      builder: (context, __) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Login',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueAccent,
            ),
          ),
        ),
        body: const LoginLayout(),
      ),
    );
  }
}
