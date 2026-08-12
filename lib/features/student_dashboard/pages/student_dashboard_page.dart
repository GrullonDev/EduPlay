import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/student_dashboard/pages/student_dashboard_layout.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:edu_play/utils/child_portal_link.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const kChildPinKey = StudentSessionNavigationService.childPinKey;

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({
    super.key,
    this.username,
    this.childProfile,
    this.initialTab = 0,
  });

  final String? username;

  final ChildProfile? childProfile;

  final int initialTab;

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  bool _resolving = true;
  ChildProfile? _resolvedProfile;
  bool _isGuest = false;
  bool _routeNormalized = false;

  @override
  void initState() {
    super.initState();
    if (widget.childProfile != null) {
      _resolvedProfile = widget.childProfile;
      _ensureChildSession(widget.childProfile!).then((_) {
        if (!mounted) return;
        setState(() => _resolving = false);
      });
    } else if (widget.username != null) {
      _resolving = false;
    } else {
      _resolveEntry();
    }
  }

  Future<void> _resolveEntry() async {
    // Priority 1: profile embedded in a parent-shared link.
    final urlProfile = childProfileFromUrl();
    final urlPin = pinFromUrl();
    if (urlProfile != null && urlPin != null) {
      await _ensureAnonymousAuth();
      await StudentSessionNavigationService.rememberChildPin(urlPin);
      if (!mounted) return;
      setState(() {
        _resolvedProfile = urlProfile;
        _resolving = false;
      });
      return;
    }

    // Priority 2: cached PIN from a previous visit (returning child).
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(kChildPinKey);
    if (savedPin != null && savedPin.isNotEmpty) {
      final authOk = await _ensureAnonymousAuth();
      if (authOk) {
        try {
          final profile =
              await ChildProfilesService.findByPinGlobal(savedPin);
          if (profile != null) {
            if (!mounted) return;
            setState(() {
              _resolvedProfile = profile;
              _resolving = false;
            });
            return;
          }
          // Lookup succeeded and genuinely found no profile for this PIN
          // (e.g. the parent deleted/regenerated it) — only now is it safe
          // to forget it.
          await StudentSessionNavigationService.clearChildPin();
        } catch (_) {
          // Transient error (offline, permission hiccup): keep the cached
          // PIN so the next attempt can still resolve the child without
          // forcing them back to the parent for a new link.
        }
      }
      // Anonymous auth itself failed (offline/disabled): also keep the PIN
      // cached rather than logging the child out over a connectivity blip.
    }

    if (!mounted) return;
    setState(() {
      _isGuest = true;
      _resolving = false;
    });
  }

  Future<bool> _ensureAnonymousAuth() {
    return _authRepository.ensureAnonymousAuth();
  }

  Future<void> _ensureChildSession(ChildProfile profile) async {
    await _ensureAnonymousAuth();
    await StudentSessionNavigationService.rememberChildPin(profile.pin);
  }

  void _normalizeRouteIfNeeded() {
    if (_routeNormalized) return;
    final routeName = ModalRoute.of(context)?.settings.name;
    final isLegacy = routeName == RouterPaths.legacyStudentDashboard ||
        routeName == RouterPaths.legacySlashStudentDashboard;
    if (!isLegacy) return;

    _routeNormalized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        RouterPaths.studentDashboard,
        arguments: _resolvedProfile ?? widget.username,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F5F9),
        body: Center(
          child: CircularProgressIndicator(
              color: Color(0xFF1E1B6A), strokeWidth: 2.5),
        ),
      );
    }

    _normalizeRouteIfNeeded();

    final registerProvider = context.read<RegisterProvider>();
    final age =
        _resolvedProfile?.age ?? int.tryParse(registerProvider.age) ?? 6;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentDashboardBloc>(
          create: (_) => StudentDashboardBloc(
            username: widget.username,
            age: age,
            childProfile: _resolvedProfile,
            isGuest: _isGuest,
          ),
        ),
        ChangeNotifierProvider<MenuProvider>(
          create: (context) => MenuProvider(
            context: context,
            age: age,
            username: widget.username,
          ),
        ),
      ],
      child: StudentDashboardLayout(initialTab: widget.initialTab),
    );
  }
}
