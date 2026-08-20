// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

// Project imports:
import 'package:edu_play/utils/injection_container.dart' as di;
import 'package:edu_play/utils/my_app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('es');
  GoogleFonts.config.allowRuntimeFetching = true;
  di.init();

  runApp(const MyApp());
}
// 5794 - PIN Lilo
// 9410 - PIN Luis
// 7710 - PIN Pablo
