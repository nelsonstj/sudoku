// lib/ui/pages/sudoku_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/sudoku_puzzle.dart';
import '../../providers/sudoku_provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import 'dart:async';

class SudokuHomePage extends ConsumerStatefulWidget {
  const SudokuHomePage({super.key});

  @override
  ConsumerState<SudokuHomePage> createState() => _SudokuHomePageState();
}

class _SudokuHomePageState extends ConsumerState<SudokuHomePage> {
  int? selectedRow;
  int? selectedCol;
  int? selectedValue;
  Timer? _timer;
  List<List<bool>>? _checkedConflicts;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final notifier = ref.read(sudokuNotifierProvider.notifier);
      notifier.incrementElapsedTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    ref.listen<SudokuState>(
      sudokuNotifierProvider,
      (previous, next) {
        final prevCompleted = previous?.currentGame?.isCompleted ?? false;
        final nowCompleted = next.currentGame?.isCompleted ?? false;
        if (!prevCompleted && nowCompleted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Sudoku concluído! Parabéns!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );

    final state = ref.watch(sudokuNotifierProvider);
    final notifier = ref.read(sudokuNotifierProvider.notifier);
    final settings = ref.watch(settingsProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final game = state.currentGame;
    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.appTitle)),
        body: Center(child: Text(loc.homeNoGameLoaded)),
      );
    }

    final SudokuPuzzle puzzle = game.puzzle;
    // Update conflicts matrix in real-time if enabled
    if (settings.realtimeErrorChecking && _checkedConflicts == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only update if realtime is enabled and user hasn't manually checked
        if (mounted && settings.realtimeErrorChecking && _checkedConflicts == null) {
          setState(() {
            _checkedConflicts = notifier.getConflictsMatrix();
          });
        }
      });
    }
    // Reset conflicts matrix when realtime is disabled
    if (!settings.realtimeErrorChecking && _checkedConflicts != null) {
      setState(() {
        _checkedConflicts = null;
      });
    }
    // Map difficulty to localized label (kept local mapping for values)
    // Localize difficulty label using generated localizations
    final difficultyPt = (() {
      switch (game.difficulty) {
        case 'Easy':
          return loc.difficultyEasy;
        case 'Medium':
          return loc.difficultyMedium;
        case 'Hard':
          return loc.difficultyHard;
        case 'Special':
          return loc.difficultySpecial;
        default:
          return game.difficulty;
      }
    })();
    final title = loc.gameTitleReduce(difficultyPt);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: loc.actionNothingToUndo,
            icon: const Icon(Icons.undo),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final notifier = ref.read(sudokuNotifierProvider.notifier);
              final ok = await notifier.undoLastAction();
              if (!mounted) return;
              if (!ok) {
                messenger.showSnackBar(SnackBar(content: Text(loc.actionNothingToUndo)));
              } else {
                setState(() {
                  selectedRow = null;
                  selectedCol = null;
                  selectedValue = null;
                  _checkedConflicts = null;
                });
                messenger.showSnackBar(SnackBar(content: Text(loc.actionUndone)));
              }
            },
          ),
          IconButton(
            tooltip: loc.actionRestart,
            icon: const Icon(Icons.restart_alt),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final loc = AppLocalizations.of(context)!;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc.actionResetConfirm),
                  content: Text(loc.actionResetConfirmContent),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.actionCancel)),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.actionRestart)),
                  ],
                ),
              );
              if (confirmed != true) return;
              await notifier.restartCurrentGame();
              if (!mounted) return;
              setState(() {
                selectedRow = null;
                selectedCol = null;
                selectedValue = null;
                _checkedConflicts = null;
              });
              messenger.showSnackBar(SnackBar(content: Text(loc.actionGameRestarted)));
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Dúvidas',
            icon: const Icon(Icons.help_outline),
            onSelected: (value) async {
              final notifier = ref.read(sudokuNotifierProvider.notifier);
              final messenger = ScaffoldMessenger.of(context);
                  final loc = AppLocalizations.of(context)!;
                  switch (value) {
                case 'checar':
                  final notifier = ref.read(sudokuNotifierProvider.notifier);
                  final conflicts = notifier.getConflictsMatrix();
                  final count = conflicts.expand((r) => r).where((v) => v).length;
                  if (!mounted) return;
                  setState(() { _checkedConflicts = conflicts; });
                  if (count == 0) {
                    messenger.showSnackBar(SnackBar(content: Text(loc.actionNoErrorsFound)));
                  } else {
                    messenger.showSnackBar(SnackBar(content: Text(loc.actionFoundConflicts(count))));
                  }
                  break;
                case 'dica':
                  final hint = notifier.getHint();
                    if (hint == null) {
                    if (!mounted) return;
                    messenger.showSnackBar(SnackBar(content: Text(loc.actionNoHint)));
                  } else {
                    if (!mounted) return;
                    setState(() {
                      selectedRow = hint['row'];
                      selectedCol = hint['col'];
                      _checkedConflicts = null;
                    });
                    messenger.showSnackBar(SnackBar(content: Text(loc.actionHint('${hint['col']! + 1}', '${hint['row']! + 1}', '${hint['value']}'))));
                  }
                  break;
                case 'resolver_proximo':
                  final res = await notifier.solveNextCell();
                  if (!mounted) return;
                  if (res == null) {
                    messenger.showSnackBar(SnackBar(content: Text(loc.actionNothingToSolve)));
                  } else {
                    setState(() {
                      selectedRow = res['row'];
                      selectedCol = res['col'];
                      _checkedConflicts = null;
                    });
                    messenger.showSnackBar(SnackBar(content: Text(loc.actionSolved('${res['row']! + 1}', '${res['col']! + 1}', '${res['value']}'))));
                  }
                  break;
                case 'resolver_tudo':
                  // confirmar
                  final toCorrect = (() {
                    int c = 0;
                    for (var r = 0; r < 9; r++) {
                      for (var col = 0; col < 9; col++) {
                        if (!puzzle.fixed[r][col] && puzzle.grid[r][col] != puzzle.solution[r][col]) {
                          c++;
                        }
                      }
                    }
                    return c;
                  })();
                  if (toCorrect == 0) {
                    if (!mounted) return;
                    messenger.showSnackBar(SnackBar(content: Text(loc.actionNoCellsToCorrect)));
                    break;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(loc.menuSolveAll),
                      content: Text(loc.actionSolveConfirm(toCorrect)),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.actionCancel)),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.menuSolveAll)),
                      ],
                    ),
                  );
                  if (confirmed != true) break;
                  final corrected = await notifier.autoCorrectCurrentGame();
                  if (!mounted) return;
                  setState(() { _checkedConflicts = null; });
                  messenger.showSnackBar(SnackBar(content: Text(loc.actionCorrectedCells(corrected))));
                  break;
                default:
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'checar', child: Text(loc.menuCheckErrors)),
              PopupMenuItem(value: 'dica', child: Text(loc.menuHint)),
              PopupMenuItem(value: 'resolver_proximo', child: Text(loc.menuSolveNext)),
              PopupMenuItem(value: 'resolver_tudo', child: Text(loc.menuSolveAll)),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcula o tamanho máximo possível para o grid (quadrado)
            final maxGridSize = (constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight) *
                0.9;

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔹 Cabeçalho
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            /*Text(
                              loc.selectorDifficulty(difficultyPt),
                              style: const TextStyle(fontSize: 16),
                            ),*/
                            Text(loc.gameTitlePkg(game.packageNumber.toString(), game.gameNumber.toString()),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text('⏱ ${game.puzzle.formattedElapsedTime}',
                              style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔹 SudokuGrid centralizado e limitado
                      Center(
                        child: SizedBox(
                          width: maxGridSize,
                          height: maxGridSize,
                          child: SudokuGrid(
                            puzzle: puzzle,
                            selectedRow: selectedRow,
                            selectedCol: selectedCol,
                            selectedValue: selectedRow != null && selectedCol != null
                                ? puzzle.grid[selectedRow!][selectedCol!]
                                : null,
                            highlightedConflicts: _checkedConflicts,
                            largerNumbers: settings.largerNumbers,
                            highlightRowCol: settings.highlightRowCol,
                            onCellTap: (r, c) {
                              setState(() {
                                selectedRow = r;
                                selectedCol = c;
                                _checkedConflicts = null;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 NumberPad com tamanho proporcional
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: NumberPad(
                            onNumberSelected: (n) async {
                              if (selectedRow == null || selectedCol == null) return;
                              await notifier.setCell(selectedRow!, selectedCol!, n);
                              if (!mounted) return;
                              setState(() {
                                _checkedConflicts = null;
                              });
                            },
                            onClear: () async {
                              if (selectedRow == null || selectedCol == null) return;
                              await notifier.clearCell(selectedRow!, selectedCol!);
                              if (!mounted) return;
                              setState(() {
                                _checkedConflicts = null;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
