// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'EduPlay';

  @override
  String get navCurriculum => 'Currículo';

  @override
  String get navGames => 'Juegos';

  @override
  String get navForTeachers => 'Para Profesores';

  @override
  String get navPricing => 'Precios';

  @override
  String get navLogin => 'Iniciar sesión';

  @override
  String get navStartFree => 'Empieza Gratis';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSubtitle => 'Administra tu cuenta y preferencias';

  @override
  String get pageNotFound => 'Página no encontrada';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortLevel => 'Nivel';

  @override
  String get summaryExplorer => 'Explorador';

  @override
  String get summaryGamesAssigned => 'Juegos asignados';

  @override
  String get summaryAccess => 'Acceso';

  @override
  String get summaryPinProtected => 'Protegido con PIN';

  @override
  String get kioskPlay => 'Jugar';

  @override
  String get kioskGames => 'Juegos';

  @override
  String get kioskTotalScore => 'Puntaje total';

  @override
  String get kioskCompleted => 'Completados';

  @override
  String get kioskSessionSummary => 'Resumen de la sesión';

  @override
  String get kioskYourGames => 'Tus juegos';

  @override
  String get kioskCompleteAllGames =>
      '¡Completa todos los juegos para terminar tu sesión!';

  @override
  String get kioskNoGamesFound => 'No se encontraron juegos para esta sesión.';

  @override
  String get kioskPracticeMode => 'Modo práctica';

  @override
  String get kioskDone => 'Listo';

  @override
  String kioskScoreLabel(int score) {
    return 'Puntaje: $score';
  }

  @override
  String get kioskFinishGame => 'Terminar juego';

  @override
  String kioskPracticeModeWithChild(String childName) {
    return 'Modo práctica • $childName';
  }

  @override
  String kioskGreatJob(String childName) {
    return '¡Buen trabajo, $childName!';
  }

  @override
  String kioskCompletedAllGames(int count) {
    return '¡Completaste los $count juegos!';
  }

  @override
  String get kioskAskParent =>
      'Pídele a tu papá o mamá que vea tu reporte de progreso.';

  @override
  String kioskPointsSuffix(int score) {
    return '$score pts';
  }

  @override
  String kioskProgressLabel(int completed, int total) {
    return '$completed de $total juegos completados';
  }

  @override
  String get kioskExitButton => '¡Listo! 🎉';

  @override
  String kioskGameNotFound(String gameId) {
    return 'Juego no encontrado: $gameId';
  }

  @override
  String funEnglishAskEmoji(String emoji) {
    return '¿Qué es esto? $emoji';
  }

  @override
  String funEnglishAskEnglish(String word) {
    return '¿Cómo se dice \'$word\' en inglés?';
  }

  @override
  String funEnglishAskSpanish(String word) {
    return '¿Cómo se dice \'$word\' en español?';
  }

  @override
  String get gameIntroObjectiveLabel => 'Qué vas a practicar';

  @override
  String gameIntroDifficultyLabel(String difficulty) {
    return 'Dificultad: $difficulty';
  }

  @override
  String get gameIntroStart => '¡Comenzar!';

  @override
  String get answerCorrectTitle => '¡Correcto!';

  @override
  String get answerIncorrectTitle => '¡Casi!';

  @override
  String answerCorrectAnswerLabel(String answer) {
    return 'Respuesta correcta: $answer';
  }

  @override
  String get answerNextButton => 'Siguiente';
}
