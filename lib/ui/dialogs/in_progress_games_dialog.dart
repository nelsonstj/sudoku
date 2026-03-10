import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_progress.dart';
import '../../providers/sudoku_provider.dart';
import '../../l10n/app_localizations.dart';
import '../pages/sudoku_home_page.dart';

class InProgressGamesDialog extends ConsumerStatefulWidget {
  final List<GameProgress> inProgressGames;

  const InProgressGamesDialog({
    super.key,
    required this.inProgressGames,
  });

  @override
  ConsumerState<InProgressGamesDialog> createState() => _InProgressGamesDialogState();
}

class _InProgressGamesDialogState extends ConsumerState<InProgressGamesDialog> {
  late List<GameProgress> games;

  @override
  void initState() {
    super.initState();
    games = List.from(widget.inProgressGames);
  }

  String _getLocalizedDifficulty(String difficulty, AppLocalizations loc) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return loc.difficultyEasy;
      case 'medium':
        return loc.difficultyMedium;
      case 'hard':
        return loc.difficultyHard;
      case 'special':
        return loc.difficultySpecial;
      default:
        return difficulty;
    }
  }

  Future<void> _continueGame(GameProgress game) async {
    final notifier = ref.read(sudokuNotifierProvider.notifier);
    await notifier.loadOrCreateGame(
      difficulty: game.difficulty,
      packageNumber: game.packageNumber,
      gameNumber: game.gameNumber,
    );
    
    if (mounted) {
      Navigator.pop(context); // Fecha o dialog
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SudokuHomePage()),
      );
    }
  }

  Future<void> _deleteGame(GameProgress game) async {
    final persistence = ref.read(persistenceServiceProvider);
    await persistence.deleteGame(game.key);
    
    setState(() {
      games.removeWhere((g) => g.key == game.key);
    });

    if (mounted) {
      ref.invalidate(allGamesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dialogGameDeletedSuccess),
        ),
      );
    }
  }

  Future<void> _deleteAllGames() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsDeleteConfirmTitle),
        content: Text(AppLocalizations.of(context)!.dialogDeleteConfirmAllGames),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final persistence = ref.read(persistenceServiceProvider);
      for (final game in games) {
        await persistence.deleteGame(game.key);
      }

      if (mounted) {
        ref.invalidate(allGamesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dialogAllGamesDeletedSuccess),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (games.isEmpty) {
      return AlertDialog(
        title: Text(loc.dialogInProgressGamesTitle),
        content: Text(loc.dialogNoInProgressGames),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.actionClose),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(loc.dialogInProgressGamesTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...games.map((game) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  child: ListTile(
                    onTap: () => _continueGame(game),
                    title: Text('${loc.dialogPackageLabel} ${game.packageNumber} • ${loc.dialogGameLabel} ${game.gameNumber}'),
                    subtitle: Text(
                      _getLocalizedDifficulty(game.difficulty, loc),
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteGame(game),
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _deleteAllGames,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red,
                ),
                icon: Icon(Icons.delete, color: Colors.red.shade700),
                label: Text(loc.dialogDeleteAllGames),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.actionClose),
        ),
      ],
    );
  }
}
