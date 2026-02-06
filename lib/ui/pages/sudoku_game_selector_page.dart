// lib/ui/pages/sudoku_game_selector_page.dart
// This file is the restored, clean selector page (moved from _impl).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_progress.dart';
import '../../models/game_package.dart';
import '../../models/sudoku_puzzle.dart';
import '../../services/persistence_service.dart';
import '../../providers/sudoku_provider.dart';
import 'sudoku_home_page.dart';
import '../../l10n/app_localizations.dart';

class SudokuGameSelectorPage extends ConsumerStatefulWidget {
  const SudokuGameSelectorPage({super.key});

  @override
  ConsumerState<SudokuGameSelectorPage> createState() =>
      _SudokuGameSelectorPageState();
}

class _SudokuGameSelectorPageState
    extends ConsumerState<SudokuGameSelectorPage> {
  final _persistence = PersistenceService();

  String _selectedDifficultyKey = 'Easy';
  // Difficulty labels are localized via AppLocalizations
  String getDifficultyLabel(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'Easy':
        return loc.difficultyEasy;
      case 'Medium':
        return loc.difficultyMedium;
      case 'Hard':
        return loc.difficultyHard;
      case 'Special':
        return loc.difficultySpecial;
      default:
        return key;
    }
  }

  late Future<List<GamePackage>> _packagesFuture;

  @override
  void initState() {
    super.initState();
    _packagesFuture = _loadPackagesFor(_selectedDifficultyKey);
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  Future<List<GamePackage>> _loadPackagesFor(String difficultyKey) async {
    final all = await _persistence.loadAllGames();

    final Map<int, List<GameProgress>> grouped = {};
    for (final gp in all.values) {
      if (gp.difficulty != difficultyKey) continue;
      grouped.putIfAbsent(gp.packageNumber, () => []);
      grouped[gp.packageNumber]!.add(gp);
    }

    final List<GamePackage> packages = [];
    for (var p = 1; p <= 20; p++) {
      final savedGames = grouped[p] ?? [];
      final List<GameProgress> games = List.generate(10, (i) {
        final gameNumber = i + 1;
        final found = savedGames.firstWhere(
          (g) => g.gameNumber == gameNumber,
          orElse: () => GameProgress(
            difficulty: difficultyKey,
            packageNumber: p,
            gameNumber: gameNumber,
            puzzle: SudokuPuzzle.empty(),
            isCompleted: false,
          ),
        );
        return found;
      });
      packages.add(GamePackage(
          difficulty: difficultyKey, packageNumber: p, games: games));
    }

    return packages;
  }

  void _onDifficultySelected(String key) {
    setState(() {
      _selectedDifficultyKey = key;
      _packagesFuture = _loadPackagesFor(key);
    });
  }

  Future<void> _openGame(GameProgress game) async {
    try {
      final notifier = ref.read(sudokuNotifierProvider.notifier);
      await notifier.loadOrCreateGame(
        difficulty: game.difficulty,
        packageNumber: game.packageNumber,
        gameNumber: game.gameNumber,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SudokuHomePage()),
      );

      final packagesFuture = _loadPackagesFor(_selectedDifficultyKey);
      setState(() {
        _packagesFuture = packagesFuture;
      });
    } catch (e, st) {
      debugPrint('Erro ao abrir jogo: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir jogo: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.selectorTitle),
        centerTitle: true,
        // Removido o menu "Dúvidas" nesta tela — o ícone estava aparecendo indevidamente
        actions: [],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildDifficultyChips(theme),
          const Divider(height: 8),
          Expanded(child: _buildPackages()),
        ],
      ),
    );
  }

  Widget _buildDifficultyChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
          children: ['Easy','Medium','Hard','Special'].map((key) {
          final label = getDifficultyLabel(context, key);
          final selected = key == _selectedDifficultyKey;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => _onDifficultySelected(key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackages() {
    return FutureBuilder<List<GamePackage>>(
      future: _packagesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData) {
          return Center(child: Text(AppLocalizations.of(context)!.selectorNoPackages));
        }

        final packages = snap.data!;
        final theme = Theme.of(context);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: packages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, idx) {
            final pkg = packages[idx];
            final total = pkg.games.length;
            final done = pkg.games.where((g) => g.isCompleted).length;

            final totalElapsedSeconds = pkg.games.fold<int>(
              0,
              (acc, gp) => acc + gp.puzzle.elapsedTime.inSeconds,
            );
            final totalElapsed = Duration(seconds: totalElapsedSeconds);

            return GestureDetector(
              onTap: () => _showPackageDialog(pkg),
              child: Card(
                elevation: 3,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.selectorPackage(pkg.packageNumber),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        backgroundColor: Colors.grey[300],
                        color: done == total ? Colors.green : Colors.blueAccent,
                      ),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.statisticsGamesCompleted(done, total)),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.selectorTime(_formatDuration(totalElapsed)),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      /*const SizedBox(height: 6),
                      //Text(
                      //  AppLocalizations.of(context)!.selectorDifficulty(getDifficultyLabel(context, pkg.difficulty)),
                      //  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant),
                      ),*/
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPackageDialog(GamePackage pkg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectorPackageDialog(getDifficultyLabel(context, pkg.difficulty), pkg.packageNumber)),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: pkg.games.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, idx) {
                final g = pkg.games[idx];
                final color = g.isCompleted
                    ? Colors.green
                    : (g.puzzle.grid.any((row) => row.any((v) => v != 0))
                        ? Colors.orange
                        : Colors.grey.shade300);

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _openGame(g);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${g.gameNumber}',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.actionClose))],
        );
      },
    );
  }
}
