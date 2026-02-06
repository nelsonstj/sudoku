// lib/providers/sudoku_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/sudoku_puzzle.dart';
import '../models/game_progress.dart';
import '../core/sudoku_generator.dart';
import '../services/persistence_service.dart';
import '../services/statistics_service.dart';
import 'settings_provider.dart';

/// Provider global do serviço de persistência (assume que existe em services)
final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  return PersistenceService();
});

/// Estado do Sudoku atual (aponta para um GameProgress salvo/criado)
class SudokuState {
  final GameProgress? currentGame;
  final bool isLoading;
  final List<List<bool>> conflicts;

  const SudokuState({this.currentGame, this.isLoading = false, this.conflicts = const [
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
    [false,false,false,false,false,false,false,false,false],
  ]});

  SudokuState copyWith({GameProgress? currentGame, bool? isLoading, List<List<bool>>? conflicts}) {
    return SudokuState(
      currentGame: currentGame ?? this.currentGame,
      isLoading: isLoading ?? this.isLoading,
      conflicts: conflicts ?? this.conflicts,
    );
  }
}

/// Notifier responsável por carregar, criar e salvar jogos por key (difficulty/package/game)
class SudokuNotifier extends StateNotifier<SudokuState> {
  final Ref ref;
  final SudokuGenerator _generator = SudokuGenerator();
    // Stack of previous GameProgress snapshots for multi-level undo
    final List<GameProgress> _undoStack = [];
    // configured via SettingsProvider

  SudokuNotifier(this.ref) : super(const SudokuState(isLoading: false));

  /// Carrega jogo salvo pelo key (difficulty, packageNumber, gameNumber)
  /// ou cria um novo caso não exista.
  Future<void> loadOrCreateGame({
  required String difficulty,
  required int packageNumber,
  required int gameNumber,
}) async {
  state = state.copyWith(isLoading: true);
  try {
    final persistence = ref.read(persistenceServiceProvider);
    final key = '${difficulty}_p${packageNumber}_g$gameNumber';
    final saved = await persistence.loadGame(key);
    if (saved != null) {
      final settings = ref.read(settingsProvider);
      final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(saved) : state.conflicts;
      state = state.copyWith(currentGame: saved, isLoading: false, conflicts: conflicts);
      return;
    }

    // criar novo
    final solution = _generator.generateFullSolution();
    final grid = _generator.createPuzzleFromSolution(solution, difficulty);
    final fixed = List.generate(9, (r) => List.generate(9, (c) => grid[r][c] != 0));
    final puzzle = SudokuPuzzle(
      grid: grid,
      fixed: fixed,
      solution: solution,
      difficulty: difficulty,
      elapsedTime: Duration.zero,
      isCompleted: false,
    );
    final newGame = GameProgress(
      difficulty: difficulty,
      packageNumber: packageNumber,
      gameNumber: gameNumber,
      puzzle: puzzle,
      isCompleted: false,
    );

    _pushSnapshot();
    await persistence.saveGame(newGame);
    final settings = ref.read(settingsProvider);
    final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(newGame) : state.conflicts;
    state = state.copyWith(currentGame: newGame, isLoading: false, conflicts: conflicts);
    try {
      ref.invalidate(allGamesProvider);
    } catch (_) {}
  } catch (e, st) {
    debugPrint('loadOrCreateGame error: $e\n$st');
    state = state.copyWith(isLoading: false);
    rethrow; // deixa o caller tratar (o _openGame que colocamos já trata)
  }
}

  /// Atualiza a célula (e salva o progresso)
  Future<void> setCell(int row, int col, int value) async {
    final current = state.currentGame;
    if (current == null) return;

    // não permite editar células fixas
    if (current.puzzle.isFixed(row, col)) return;

    final updatedPuzzle = current.puzzle.copyWithCell(row, col, value);

    final updatedGame = GameProgress(
      difficulty: current.difficulty,
      packageNumber: current.packageNumber,
      gameNumber: current.gameNumber,
      puzzle: updatedPuzzle,
      isCompleted: updatedPuzzle.isSolvedCorrectly(),
      lastPlayed: DateTime.now(),
    );

    _pushSnapshot();
    final settings = ref.read(settingsProvider);
    final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(updatedGame) : state.conflicts;
    state = state.copyWith(currentGame: updatedGame, conflicts: conflicts);

    final persistence = ref.read(persistenceServiceProvider);
    await persistence.saveGame(updatedGame);
      try {
        ref.invalidate(allGamesProvider);
      } catch (_) {}
  }

  /// Limpa célula (wrapper)
  Future<void> clearCell(int row, int col) async {
    await setCell(row, col, 0);
  }

  /// Marca o jogo atual como concluído (força completed = true) e salva
  Future<void> markCompleted() async {
    final current = state.currentGame;
    if (current == null) return;

    final completedGame = GameProgress(
      difficulty: current.difficulty,
      packageNumber: current.packageNumber,
      gameNumber: current.gameNumber,
      puzzle: current.puzzle,
      isCompleted: true,
      lastPlayed: DateTime.now(),
    );

    _pushSnapshot();
    final settings = ref.read(settingsProvider);
    final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(completedGame) : state.conflicts;
    state = state.copyWith(currentGame: completedGame, conflicts: conflicts);

    final persistence = ref.read(persistenceServiceProvider);
    await persistence.saveGame(completedGame);
    try {
      ref.invalidate(allGamesProvider);
    } catch (_) {}
  }

  /// Reinicia o jogo atual gerando um novo puzzle para a mesma chave.
  /// Salva um snapshot antes para permitir desfazer (undo).
  Future<void> restartCurrentGame() async {
    final current = state.currentGame;
    if (current == null) return;

    _pushSnapshot();

    // generate new puzzle for same difficulty/package/game
    final solution = _generator.generateFullSolution();
    final grid = _generator.createPuzzleFromSolution(solution, current.difficulty);
    final fixed = List.generate(9, (r) => List.generate(9, (c) => grid[r][c] != 0));
    final puzzle = SudokuPuzzle(
      grid: grid,
      fixed: fixed,
      solution: solution,
      difficulty: current.difficulty,
      elapsedTime: Duration.zero,
      isCompleted: false,
    );

    final newGame = current.copyWith(
      puzzle: puzzle,
      isCompleted: false,
      lastPlayed: DateTime.now(),
    );

    final persistence = ref.read(persistenceServiceProvider);
    await persistence.saveGame(newGame);

    final settings = ref.read(settingsProvider);
    final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(newGame) : state.conflicts;
    state = state.copyWith(currentGame: newGame, conflicts: conflicts);

    try {
      ref.invalidate(allGamesProvider);
    } catch (_) {}
  }

  /// Reseta o estado em memória do SudokuNotifier (usado após limpar persistência)
  Future<void> resetState() async {
    state = const SudokuState(isLoading: false);
    _undoStack.clear();
  }

  /// Aplica correções automáticas no jogo atual comparando com a solução.
  /// Retorna o número de células corrigidas.
  Future<int> autoCorrectCurrentGame() async {
    final current = state.currentGame;
    if (current == null) return 0;

    final puzzle = current.puzzle;
    // clone grid
    final newGrid = puzzle.grid.map((r) => List<int>.from(r)).toList();
    int corrected = 0;

    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzle.fixed[r][c]) continue; // não altera células fixas
        final sol = puzzle.solution[r][c];
        if (newGrid[r][c] != sol) {
          newGrid[r][c] = sol;
          corrected++;
        }
      }
    }

    if (corrected == 0) return 0;

    // verifica se agora está resolvido
    bool solved = true;
    for (var r = 0; r < 9 && solved; r++) {
      for (var c = 0; c < 9; c++) {
        if (newGrid[r][c] != puzzle.solution[r][c]) {
          solved = false;
          break;
        }
      }
    }

    final updatedPuzzle = puzzle.copyWith(grid: newGrid, isCompleted: solved);

    final updatedGame = current.copyWith(
      puzzle: updatedPuzzle,
      isCompleted: solved,
      lastPlayed: DateTime.now(),
    );

    final persistence = ref.read(persistenceServiceProvider);
    await persistence.saveGame(updatedGame);

    final settings = ref.read(settingsProvider);
    final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(updatedGame) : state.conflicts;
    state = state.copyWith(currentGame: updatedGame, conflicts: conflicts);

    try {
      ref.invalidate(allGamesProvider);
    } catch (_) {}

    return corrected;
  }

  /// Undo: restaura o snapshot anterior se disponível.
  /// Retorna true se uma restauração foi aplicada.
  Future<bool> undoLastAction() async {
    if (_undoStack.isEmpty) return false;
    final snapshot = _undoStack.removeLast();
    final persistence = ref.read(persistenceServiceProvider);
    await persistence.saveGame(snapshot);
    final settings = ref.read(settingsProvider);
    final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(snapshot) : state.conflicts;
    state = state.copyWith(currentGame: snapshot, conflicts: conflicts);
    try {
      ref.invalidate(allGamesProvider);
    } catch (_) {}
    return true;
  }

  bool get canUndo => _undoStack.isNotEmpty;

  /// Push current state onto undo stack (if present). Maintains a maximum stack depth.
  void _pushSnapshot() {
    final current = state.currentGame;
    if (current == null) return;
    final settings = ref.read(settingsProvider);
    final max = settings.undoStackLimit;
    // push a deep copy (GameProgress is assumed immutable except via copyWith)
    _undoStack.add(current);
    if (_undoStack.length > max) {
      _undoStack.removeAt(0);
    }
  }

  /// Internal: compute conflicts for a given game (true = célula em conflito).
  List<List<bool>> _computeConflictsFor(GameProgress? current) {
    final conflicts = List.generate(9, (_) => List.filled(9, false));
    if (current == null) return conflicts;
    final puzzle = current.puzzle;

    // mismatches with solution
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final v = puzzle.grid[r][c];
        if (v != 0 && puzzle.solution.isNotEmpty) {
          if (puzzle.solution[r][c] != v) conflicts[r][c] = true;
        }
      }
    }

    // duplicates rows
    for (var r = 0; r < 9; r++) {
      final map = <int, List<int>>{};
      for (var c = 0; c < 9; c++) {
        final v = puzzle.grid[r][c];
        if (v == 0) continue;
        map.putIfAbsent(v, () => []).add(c);
      }
      for (final e in map.entries) {
        if (e.value.length > 1) {
          for (final c in e.value) {
            conflicts[r][c] = true;
          }
        }
      }
    }

    // duplicates cols
    for (var c = 0; c < 9; c++) {
      final map = <int, List<int>>{};
      for (var r = 0; r < 9; r++) {
        final v = puzzle.grid[r][c];
        if (v == 0) continue;
        map.putIfAbsent(v, () => []).add(r);
      }
      for (final e in map.entries) {
        if (e.value.length > 1) {
          for (final r in e.value) {
            conflicts[r][c] = true;
          }
        }
      }
    }

    // duplicates boxes
    for (var br = 0; br < 3; br++) {
      for (var bc = 0; bc < 3; bc++) {
        final map = <int, List<List<int>>>{};
        for (var r = br * 3; r < br * 3 + 3; r++) {
          for (var c = bc * 3; c < bc * 3 + 3; c++) {
            final v = puzzle.grid[r][c];
            if (v == 0) continue;
            map.putIfAbsent(v, () => []).add([r, c]);
          }
        }
        for (final e in map.entries) {
          if (e.value.length > 1) {
            for (final rc in e.value) {
              conflicts[rc[0]][rc[1]] = true;
            }
          }
        }
      }
    }

    return conflicts;
  }

  /// Retorna a matriz de conflitos do jogo atual (consulta configurações para checagem em tempo real)
  List<List<bool>> getConflictsMatrix() {
    final settings = ref.read(settingsProvider);
    if (!settings.realtimeErrorChecking) {
      return state.conflicts;
    }
    return _computeConflictsFor(state.currentGame);
  }

  /// Retorna uma dica para o próximo número sem alterar o estado.
  /// Retorna null se não houver sugestão.
  Map<String, int>? getHint() {
    final current = state.currentGame;
    if (current == null) return null;
    final puzzle = current.puzzle;

    // Prefer empty cells (0). Retorna a primeira encontrada com a solução.
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzle.fixed[r][c]) continue;
        if (puzzle.grid[r][c] == 0) {
          return {'row': r, 'col': c, 'value': puzzle.solution[r][c]};
        }
      }
    }

    // Se não houver vazios, procura a primeira célula incorreta
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzle.fixed[r][c]) continue;
        if (puzzle.grid[r][c] != puzzle.solution[r][c]) {
          return {'row': r, 'col': c, 'value': puzzle.solution[r][c]};
        }
      }
    }

    return null;
  }

  /// Resolve apenas o próximo número (preenche a próxima célula não fixa com a solução).
  /// Retorna um mapa com row/col/value preenchidos, ou null se nada a corrigir.
  Future<Map<String, int>?> solveNextCell() async {
    final current = state.currentGame;
    if (current == null) return null;
    final puzzle = current.puzzle;

    // encontra primeira célula não fixa que esteja errada ou vazia
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzle.fixed[r][c]) continue;
        final sol = puzzle.solution[r][c];
        if (puzzle.grid[r][c] != sol) {
          final newGrid = puzzle.grid.map((row) => List<int>.from(row)).toList();
          newGrid[r][c] = sol;
          final updatedPuzzle = puzzle.copyWith(grid: newGrid);
          final updatedGame = current.copyWith(puzzle: updatedPuzzle, lastPlayed: DateTime.now(), isCompleted: updatedPuzzle.isSolvedCorrectly());
          final persistence = ref.read(persistenceServiceProvider);
          await persistence.saveGame(updatedGame);
          final settings = ref.read(settingsProvider);
          final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(updatedGame) : state.conflicts;
          state = state.copyWith(currentGame: updatedGame, conflicts: conflicts);
          try { ref.invalidate(allGamesProvider); } catch (_) {}
          return {'row': r, 'col': c, 'value': sol};
        }
      }
    }

    return null;
  }

  /// Carrega todos os jogos salvos e filtra por dificuldade (útil para a tela de seleção)
  Future<List<GameProgress>> getAllGamesByDifficulty(String difficulty) async {
    final persistence = ref.read(persistenceServiceProvider);
    final all = await persistence.loadAllGames(); // Map<String, GameProgress>
    final list = all.values.where((g) => g.difficulty == difficulty).toList();

    // Garantir que existam entradas para todos os pacotes e jogos: se não existir,
    // podemos criar pacotes placeholders (não salvos) para exibir na UI.
    // Aqui apenas ordenamos e retornamos o salvo.
    list.sort((a, b) {
      final p = a.packageNumber.compareTo(b.packageNumber);
      return p != 0 ? p : a.gameNumber.compareTo(b.gameNumber);
    });

    return list;
  }

  Future<void> incrementElapsedTime() async {
    final current = state.currentGame;
    if (current == null || current.isCompleted) return;

    // Atualiza apenas o tempo do puzzle
    final updatedPuzzle = current.puzzle.copyWith(
      elapsedTime: current.puzzle.elapsedTime + const Duration(seconds: 1),
    );

    // Cria um novo GameProgress via copyWith
    final updated = current.copyWith(
      puzzle: updatedPuzzle,
      isCompleted: updatedPuzzle.isSolvedCorrectly(),
      lastPlayed: DateTime.now(), // adiciona a data/hora
    );

    // Atualiza o estado local
    final settings = ref.read(settingsProvider);
    final conflicts = settings.realtimeErrorChecking ? _computeConflictsFor(updated) : state.conflicts;
    state = state.copyWith(currentGame: updated, conflicts: conflicts);

    // Persiste em background (opcional salvar a cada X segundos)
    try {
      final persistence = ref.read(persistenceServiceProvider);
      await persistence.saveGame(updated);
      try {
        ref.invalidate(allGamesProvider);
      } catch (_) {}
    } catch (_) {
      // Ignore ou logue erros silenciosamente
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final persistence = ref.read(persistenceServiceProvider);
    final allMap = await persistence.loadAllGames(); // Map<String, GameProgress>
    final allGames = allMap.values.toList(); // List<GameProgress>

    final perDifficulty = StatisticsService.getStatsPerDifficulty(allGames);
    final totalOverall = StatisticsService.getTotalOverall(allGames);

    return {
      'perDifficulty': perDifficulty,
      'totalOverall': totalOverall,
    };
  }
}

/// Provider para o SudokuNotifier
final sudokuNotifierProvider =
    StateNotifierProvider<SudokuNotifier, SudokuState>((ref) {
  return SudokuNotifier(ref);
});

/// Provider que carrega todos os jogos salvos (mapeamento key -> GameProgress)
final allGamesProvider = FutureProvider<Map<String, GameProgress>>((ref) async {
  final persistence = ref.read(persistenceServiceProvider);
  return await persistence.loadAllGames();
});
