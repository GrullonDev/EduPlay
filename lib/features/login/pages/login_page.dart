import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/login/bloc/login_bloc.dart';
import 'package:edu_play/features/login/pages/login_layout.dart';
import 'package:edu_play/utils/injection_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.userType});

  /// Pre-selected role passed from the landing page: 'parent' or 'teacher'.
  /// When null the page shows the role-selector step first.
  final String? userType;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // null  → show role picker
  // set   → show login form for that role
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = _initialRole(widget.userType);
  }

  String? _initialRole(String? requestedRole) {
    if (ReleaseFlags.teacherExperienceEnabled) return requestedRole;
    return requestedRole == 'teacher' ? 'parent' : (requestedRole ?? 'parent');
  }

  void _onRoleSelected(String role) {
    setState(() => _selectedRole = role);
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: no role chosen yet — show the role selector screen
    if (_selectedRole == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: RoleSelectorLayout(onRoleSelected: _onRoleSelected),
      );
    }

    // Step 2: role chosen — build the login form
    return ChangeNotifierProvider<LoginBloc>(
      key: ValueKey(_selectedRole),
      create: (context) => LoginBloc(
        context: context,
        authRepository: sl.get<AuthRepository>(),
        userType: _selectedRole,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoginLayout(
          userType: _selectedRole,
          onChangeRole: widget.userType == null &&
                  ReleaseFlags.teacherExperienceEnabled
              ? () => setState(() => _selectedRole = null)
              : null,
        ),
      ),
    );
  }
}
