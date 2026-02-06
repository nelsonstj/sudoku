import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Automatic (System)'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsUndoStack.
  ///
  /// In en, this message translates to:
  /// **'Undo stack size'**
  String get settingsUndoStack;

  /// No description provided for @settingsErrorChecking.
  ///
  /// In en, this message translates to:
  /// **'Error Detection'**
  String get settingsErrorChecking;

  /// No description provided for @settingsRealtimeErrors.
  ///
  /// In en, this message translates to:
  /// **'Real-time error checking'**
  String get settingsRealtimeErrors;

  /// No description provided for @settingsDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplay;

  /// No description provided for @settingsLargerNumbers.
  ///
  /// In en, this message translates to:
  /// **'Larger numbers in grid'**
  String get settingsLargerNumbers;

  /// No description provided for @settingsHighlightRowCol.
  ///
  /// In en, this message translates to:
  /// **'Highlight row and column'**
  String get settingsHighlightRowCol;

  /// No description provided for @settingsDeleteProgress.
  ///
  /// In en, this message translates to:
  /// **'Delete Progress'**
  String get settingsDeleteProgress;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Delete all game progress? This action cannot be undone.'**
  String get settingsDeleteConfirmContent;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restart game'**
  String get actionResetConfirm;

  /// No description provided for @actionResetConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restart this game? Current progress will be lost.'**
  String get actionResetConfirmContent;

  /// No description provided for @actionRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get actionRestart;

  /// No description provided for @actionProgressCleared.
  ///
  /// In en, this message translates to:
  /// **'Progress cleared.'**
  String get actionProgressCleared;

  /// No description provided for @actionGameRestarted.
  ///
  /// In en, this message translates to:
  /// **'Game restarted.'**
  String get actionGameRestarted;

  /// No description provided for @actionNothingToUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to undo.'**
  String get actionNothingToUndo;

  /// No description provided for @actionUndone.
  ///
  /// In en, this message translates to:
  /// **'Last action undone.'**
  String get actionUndone;

  /// No description provided for @actionNoErrorsFound.
  ///
  /// In en, this message translates to:
  /// **'No errors found.'**
  String get actionNoErrorsFound;

  /// No description provided for @actionFoundConflicts.
  ///
  /// In en, this message translates to:
  /// **'{count} inconsistencies found.'**
  String actionFoundConflicts(Object count);

  /// No description provided for @actionNoHint.
  ///
  /// In en, this message translates to:
  /// **'No hint available.'**
  String get actionNoHint;

  /// No description provided for @actionHint.
  ///
  /// In en, this message translates to:
  /// **'Hint: row {row}, col {col} → {value}'**
  String actionHint(Object col, Object row, Object value);

  /// No description provided for @actionSolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved: row {row}, col {col} → {value}'**
  String actionSolved(Object col, Object row, Object value);

  /// No description provided for @actionNothingToSolve.
  ///
  /// In en, this message translates to:
  /// **'Nothing to solve.'**
  String get actionNothingToSolve;

  /// No description provided for @actionCorrectedCells.
  ///
  /// In en, this message translates to:
  /// **'{count} cells corrected.'**
  String actionCorrectedCells(Object count);

  /// No description provided for @actionNoCellsToCorrect.
  ///
  /// In en, this message translates to:
  /// **'There are no cells to correct.'**
  String get actionNoCellsToCorrect;

  /// No description provided for @actionSolveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Solve the whole puzzle ({count} cells)?'**
  String actionSolveConfirm(Object count);

  /// No description provided for @selectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Selection'**
  String get selectorTitle;

  /// No description provided for @selectorNoPackages.
  ///
  /// In en, this message translates to:
  /// **'No packages found.'**
  String get selectorNoPackages;

  /// No description provided for @selectorPackage.
  ///
  /// In en, this message translates to:
  /// **'Package {num}'**
  String selectorPackage(Object num);

  /// No description provided for @selectorTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String selectorTime(Object time);

  /// No description provided for @selectorDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {diff}'**
  String selectorDifficulty(Object diff);

  /// No description provided for @selectorContinueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue: Package {pkg} • Game {game}'**
  String selectorContinueLabel(Object game, Object pkg);

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsNoGames.
  ///
  /// In en, this message translates to:
  /// **'No games recorded yet.'**
  String get statisticsNoGames;

  /// No description provided for @statisticsProgressByPackage.
  ///
  /// In en, this message translates to:
  /// **'Progress by package:'**
  String get statisticsProgressByPackage;

  /// No description provided for @statisticsGamesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Games completed: {completed} / {total}'**
  String statisticsGamesCompleted(Object completed, Object total);

  /// No description provided for @statisticsLastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played: {date}'**
  String statisticsLastPlayed(Object date);

  /// No description provided for @statisticsTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get statisticsTotalTime;

  /// No description provided for @versionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}+{build}'**
  String versionPrefix(Object build, Object version);

  /// No description provided for @menuPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get menuPlay;

  /// No description provided for @menuStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get menuStatistics;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menuShare;

  /// No description provided for @menuCheckErrors.
  ///
  /// In en, this message translates to:
  /// **'Check errors'**
  String get menuCheckErrors;

  /// No description provided for @menuHint.
  ///
  /// In en, this message translates to:
  /// **'Hint for next number'**
  String get menuHint;

  /// No description provided for @menuSolveNext.
  ///
  /// In en, this message translates to:
  /// **'Solve next number'**
  String get menuSolveNext;

  /// No description provided for @menuSolveAll.
  ///
  /// In en, this message translates to:
  /// **'Solve the puzzle'**
  String get menuSolveAll;

  /// No description provided for @homeNoGameLoaded.
  ///
  /// In en, this message translates to:
  /// **'No game loaded.'**
  String get homeNoGameLoaded;

  /// No description provided for @appFooter.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 • Built by KN'**
  String get appFooter;

  /// No description provided for @gameTitle.
  ///
  /// In en, this message translates to:
  /// **'{diff} • Package {pkg} • Game {game}'**
  String gameTitle(Object diff, Object game, Object pkg);

  /// No description provided for @gameTitleReduce.
  ///
  /// In en, this message translates to:
  /// **'{diff}'**
  String gameTitleReduce(Object diff);

  /// No description provided for @gameTitlePkg.
  ///
  /// In en, this message translates to:
  /// **'Package {pkg} • Game {game}'**
  String gameTitlePkg(Object game, Object pkg);

  /// No description provided for @selectorPackageDialog.
  ///
  /// In en, this message translates to:
  /// **'Package {num} — {diff}'**
  String selectorPackageDialog(Object diff, Object num);

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultySpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get difficultySpecial;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
