import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre de la app, mostrado en el título de la ventana/pestaña.
  ///
  /// In es, this message translates to:
  /// **'EduPlay'**
  String get appTitle;

  /// No description provided for @navCurriculum.
  ///
  /// In es, this message translates to:
  /// **'Currículo'**
  String get navCurriculum;

  /// No description provided for @navGames.
  ///
  /// In es, this message translates to:
  /// **'Juegos'**
  String get navGames;

  /// No description provided for @navForTeachers.
  ///
  /// In es, this message translates to:
  /// **'Para Profesores'**
  String get navForTeachers;

  /// No description provided for @navPricing.
  ///
  /// In es, this message translates to:
  /// **'Precios'**
  String get navPricing;

  /// No description provided for @navLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get navLogin;

  /// No description provided for @navStartFree.
  ///
  /// In es, this message translates to:
  /// **'Empieza Gratis'**
  String get navStartFree;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Administra tu cuenta y preferencias'**
  String get settingsSubtitle;

  /// No description provided for @pageNotFound.
  ///
  /// In es, this message translates to:
  /// **'Página no encontrada'**
  String get pageNotFound;

  /// No description provided for @sortPopular.
  ///
  /// In es, this message translates to:
  /// **'Popular'**
  String get sortPopular;

  /// No description provided for @sortNewest.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get sortNewest;

  /// No description provided for @sortLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get sortLevel;

  /// No description provided for @summaryExplorer.
  ///
  /// In es, this message translates to:
  /// **'Explorador'**
  String get summaryExplorer;

  /// No description provided for @summaryGamesAssigned.
  ///
  /// In es, this message translates to:
  /// **'Juegos asignados'**
  String get summaryGamesAssigned;

  /// No description provided for @summaryAccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso'**
  String get summaryAccess;

  /// No description provided for @summaryPinProtected.
  ///
  /// In es, this message translates to:
  /// **'Protegido con PIN'**
  String get summaryPinProtected;

  /// No description provided for @kioskPlay.
  ///
  /// In es, this message translates to:
  /// **'Jugar'**
  String get kioskPlay;

  /// No description provided for @kioskGames.
  ///
  /// In es, this message translates to:
  /// **'Juegos'**
  String get kioskGames;

  /// No description provided for @kioskTotalScore.
  ///
  /// In es, this message translates to:
  /// **'Puntaje total'**
  String get kioskTotalScore;

  /// No description provided for @kioskCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completados'**
  String get kioskCompleted;

  /// No description provided for @kioskSessionSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de la sesión'**
  String get kioskSessionSummary;

  /// No description provided for @kioskYourGames.
  ///
  /// In es, this message translates to:
  /// **'Tus juegos'**
  String get kioskYourGames;

  /// No description provided for @kioskCompleteAllGames.
  ///
  /// In es, this message translates to:
  /// **'¡Completa todos los juegos para terminar tu sesión!'**
  String get kioskCompleteAllGames;

  /// No description provided for @kioskNoGamesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron juegos para esta sesión.'**
  String get kioskNoGamesFound;

  /// No description provided for @kioskPracticeMode.
  ///
  /// In es, this message translates to:
  /// **'Modo práctica'**
  String get kioskPracticeMode;

  /// No description provided for @kioskDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get kioskDone;

  /// No description provided for @kioskScoreLabel.
  ///
  /// In es, this message translates to:
  /// **'Puntaje: {score}'**
  String kioskScoreLabel(int score);

  /// No description provided for @kioskFinishGame.
  ///
  /// In es, this message translates to:
  /// **'Terminar juego'**
  String get kioskFinishGame;

  /// No description provided for @kioskPracticeModeWithChild.
  ///
  /// In es, this message translates to:
  /// **'Modo práctica • {childName}'**
  String kioskPracticeModeWithChild(String childName);

  /// No description provided for @kioskGreatJob.
  ///
  /// In es, this message translates to:
  /// **'¡Buen trabajo, {childName}!'**
  String kioskGreatJob(String childName);

  /// No description provided for @kioskCompletedAllGames.
  ///
  /// In es, this message translates to:
  /// **'¡Completaste los {count} juegos!'**
  String kioskCompletedAllGames(int count);

  /// No description provided for @kioskAskParent.
  ///
  /// In es, this message translates to:
  /// **'Pídele a tu papá o mamá que vea tu reporte de progreso.'**
  String get kioskAskParent;

  /// No description provided for @kioskPointsSuffix.
  ///
  /// In es, this message translates to:
  /// **'{score} pts'**
  String kioskPointsSuffix(int score);

  /// No description provided for @kioskProgressLabel.
  ///
  /// In es, this message translates to:
  /// **'{completed} de {total} juegos completados'**
  String kioskProgressLabel(int completed, int total);

  /// No description provided for @kioskExitButton.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! 🎉'**
  String get kioskExitButton;

  /// No description provided for @kioskGameNotFound.
  ///
  /// In es, this message translates to:
  /// **'Juego no encontrado: {gameId}'**
  String kioskGameNotFound(String gameId);

  /// No description provided for @funEnglishAskEmoji.
  ///
  /// In es, this message translates to:
  /// **'¿Qué es esto? {emoji}'**
  String funEnglishAskEmoji(String emoji);

  /// No description provided for @funEnglishAskEnglish.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se dice \'{word}\' en inglés?'**
  String funEnglishAskEnglish(String word);

  /// No description provided for @funEnglishAskSpanish.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se dice \'{word}\' en español?'**
  String funEnglishAskSpanish(String word);

  /// No description provided for @gameIntroObjectiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Qué vas a practicar'**
  String get gameIntroObjectiveLabel;

  /// No description provided for @gameIntroDifficultyLabel.
  ///
  /// In es, this message translates to:
  /// **'Dificultad: {difficulty}'**
  String gameIntroDifficultyLabel(String difficulty);

  /// No description provided for @gameIntroStart.
  ///
  /// In es, this message translates to:
  /// **'¡Comenzar!'**
  String get gameIntroStart;

  /// No description provided for @answerCorrectTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Correcto!'**
  String get answerCorrectTitle;

  /// No description provided for @answerIncorrectTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Casi!'**
  String get answerIncorrectTitle;

  /// No description provided for @answerCorrectAnswerLabel.
  ///
  /// In es, this message translates to:
  /// **'Respuesta correcta: {answer}'**
  String answerCorrectAnswerLabel(String answer);

  /// No description provided for @answerNextButton.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get answerNextButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
