// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'Automatic (System)';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsUndoStack => 'Undo stack size';

  @override
  String get settingsErrorChecking => 'Error Detection';

  @override
  String get settingsRealtimeErrors => 'Real-time error checking';

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsLargerNumbers => 'Larger numbers in grid';

  @override
  String get settingsHighlightRowCol => 'Highlight row and column';

  @override
  String get settingsDeleteProgress => 'Delete Progress';

  @override
  String get settingsDeleteConfirmTitle => 'Confirm';

  @override
  String get settingsDeleteConfirmContent => 'Delete all game progress? This action cannot be undone.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionResetConfirm => 'Restart game';

  @override
  String get actionResetConfirmContent => 'Do you want to restart this game? Current progress will be lost.';

  @override
  String get actionRestart => 'Restart';

  @override
  String get actionProgressCleared => 'Progress cleared.';

  @override
  String get actionGameRestarted => 'Game restarted.';

  @override
  String get actionNothingToUndo => 'Nothing to undo.';

  @override
  String get actionUndone => 'Last action undone.';

  @override
  String get actionNoErrorsFound => 'No errors found.';

  @override
  String actionFoundConflicts(Object count) {
    return '$count inconsistencies found.';
  }

  @override
  String get actionNoHint => 'No hint available.';

  @override
  String actionHint(Object col, Object row, Object value) {
    return 'Hint: row $row, col $col → $value';
  }

  @override
  String actionSolved(Object col, Object row, Object value) {
    return 'Resolved: row $row, col $col → $value';
  }

  @override
  String get actionNothingToSolve => 'Nothing to solve.';

  @override
  String actionCorrectedCells(Object count) {
    return '$count cells corrected.';
  }

  @override
  String get actionNoCellsToCorrect => 'There are no cells to correct.';

  @override
  String actionSolveConfirm(Object count) {
    return 'Solve the whole puzzle ($count cells)?';
  }

  @override
  String get selectorTitle => 'Game Selection';

  @override
  String get selectorNoPackages => 'No packages found.';

  @override
  String selectorPackage(Object num) {
    return 'Package $num';
  }

  @override
  String selectorTime(Object time) {
    return 'Time: $time';
  }

  @override
  String selectorDifficulty(Object diff) {
    return 'Difficulty: $diff';
  }

  @override
  String selectorContinueLabel(Object game, Object pkg) {
    return 'Continue: Package $pkg • Game $game';
  }

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsNoGames => 'No games recorded yet.';

  @override
  String get statisticsProgressByPackage => 'Progress by package:';

  @override
  String statisticsGamesCompleted(Object completed, Object total) {
    return 'Games completed: $completed / $total';
  }

  @override
  String statisticsLastPlayed(Object date) {
    return 'Last played: $date';
  }

  @override
  String get statisticsTotalTime => 'Total time';

  @override
  String versionPrefix(Object build, Object version) {
    return 'Version: $version+$build';
  }

  @override
  String get menuPlay => 'Play';

  @override
  String get menuStatistics => 'Statistics';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuShare => 'Share';

  @override
  String get menuCheckErrors => 'Check errors';

  @override
  String get menuHint => 'Hint for next number';

  @override
  String get menuSolveNext => 'Solve next number';

  @override
  String get menuSolveAll => 'Solve the puzzle';

  @override
  String get homeNoGameLoaded => 'No game loaded.';

  @override
  String get appFooter => 'Built by KN';

  @override
  String gameTitle(Object diff, Object game, Object pkg) {
    return '$diff • Package $pkg • Game $game';
  }

  @override
  String gameTitleReduce(Object diff) {
    return '$diff';
  }

  @override
  String gameTitlePkg(Object game, Object pkg) {
    return 'Package $pkg • Game $game';
  }

  @override
  String selectorPackageDialog(Object diff, Object num) {
    return 'Package $num — $diff';
  }

  @override
  String get actionClose => 'Close';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultySpecial => 'Special';
}
