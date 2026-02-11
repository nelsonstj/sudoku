// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Automático (Sistema)';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsUndoStack => 'Desfazer até...';

  @override
  String get settingsErrorChecking => 'Detecção de Erros';

  @override
  String get settingsRealtimeErrors => 'Verificação de erros em tempo real';

  @override
  String get settingsDisplay => 'Exibição';

  @override
  String get settingsLargerNumbers => 'Números maiores no grid';

  @override
  String get settingsHighlightRowCol => 'Destacar linha e coluna';

  @override
  String get settingsDeleteProgress => 'Apagar Progresso';

  @override
  String get settingsDeleteConfirmTitle => 'Confirmar';

  @override
  String get settingsDeleteConfirmContent => 'Apagar todo o progresso dos jogos? Esta ação não pode ser desfeita.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Apagar';

  @override
  String get actionResetConfirm => 'Reiniciar jogo';

  @override
  String get actionResetConfirmContent => 'Deseja reiniciar este jogo? O progresso atual será perdido.';

  @override
  String get actionRestart => 'Reiniciar';

  @override
  String get actionProgressCleared => 'Progresso apagado.';

  @override
  String get actionGameRestarted => 'Jogo reiniciado.';

  @override
  String get actionNothingToUndo => 'Nada a desfazer.';

  @override
  String get actionUndone => 'Última ação desfeita.';

  @override
  String get actionNoErrorsFound => 'Nenhum erro encontrado.';

  @override
  String actionFoundConflicts(Object count) {
    return 'Foram encontradas $count inconsistências.';
  }

  @override
  String get actionNoHint => 'Sem dica disponível.';

  @override
  String actionHint(Object col, Object row, Object value) {
    return 'Dica: linha $row, coluna $col → $value';
  }

  @override
  String actionSolved(Object col, Object row, Object value) {
    return 'Resolvido: linha $row, coluna $col → $value';
  }

  @override
  String get actionNothingToSolve => 'Nada a resolver.';

  @override
  String actionCorrectedCells(Object count) {
    return 'Corrigidas $count células.';
  }

  @override
  String get actionNoCellsToCorrect => 'Não há células a corrigir.';

  @override
  String actionSolveConfirm(Object count) {
    return 'Resolver completamente o jogo ($count células)?';
  }

  @override
  String get selectorTitle => 'Seleção de Jogos';

  @override
  String get selectorNoPackages => 'Nenhum pacote encontrado.';

  @override
  String selectorPackage(Object num) {
    return 'Pacote $num';
  }

  @override
  String selectorTime(Object time) {
    return 'Tempo: $time';
  }

  @override
  String selectorDifficulty(Object diff) {
    return 'Dificuldade: $diff';
  }

  @override
  String selectorContinueLabel(Object game, Object pkg) {
    return 'Continuar: Pacote $pkg • Jogo $game';
  }

  @override
  String get statisticsTitle => 'Estatísticas';

  @override
  String get statisticsNoGames => 'Nenhum jogo registrado ainda.';

  @override
  String get statisticsProgressByPackage => 'Progresso por pacote:';

  @override
  String statisticsGamesCompleted(Object completed, Object total) {
    return 'Jogos: $completed / $total';
  }

  @override
  String statisticsLastPlayed(Object date) {
    return 'Último jogo: $date';
  }

  @override
  String get statisticsTotalTime => 'Tempo total geral';

  @override
  String versionPrefix(Object build, Object version) {
    return 'Versão: $version+$build';
  }

  @override
  String get menuPlay => 'Jogar';

  @override
  String get menuStatistics => 'Estatísticas';

  @override
  String get menuSettings => 'Configurações';

  @override
  String get menuShare => 'Compartilhar';

  @override
  String get menuCheckErrors => 'Checar erros';

  @override
  String get menuHint => 'Dica para o próximo número';

  @override
  String get menuSolveNext => 'Resolver próximo número';

  @override
  String get menuSolveAll => 'Resolver o jogo';

  @override
  String get homeNoGameLoaded => 'Nenhum jogo carregado.';

  @override
  String get appFooter => 'Desenvolvido por KN';

  @override
  String gameTitle(Object diff, Object game, Object pkg) {
    return '$diff • Pacote $pkg • Jogo $game';
  }

  @override
  String gameTitleReduce(Object diff) {
    return '$diff';
  }

  @override
  String gameTitlePkg(Object game, Object pkg) {
    return 'Pacote $pkg • Jogo $game';
  }

  @override
  String selectorPackageDialog(Object diff, Object num) {
    return 'Pacote $num — $diff';
  }

  @override
  String get actionClose => 'Fechar';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get difficultySpecial => 'Especial';
}
