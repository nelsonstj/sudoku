import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
// persistence access is provided via providers; direct import removed
import '../pages/sudoku_game_selector_page.dart';
import '../pages/sudoku_statistics_page.dart';
import '../pages/settings_page.dart';
import '../dialogs/in_progress_games_dialog.dart';
import 'sudoku_home_page.dart';
import '../../providers/sudoku_provider.dart';
import '../../l10n/app_localizations.dart';

class SudokuMainMenuPage extends ConsumerWidget {
  const SudokuMainMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allGamesAsync = ref.watch(allGamesProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) async {
              switch (value) {
                case 'share':
                  await SharePlus.instance.share(
                    ShareParams(text: 'Check out Sudoku App! Download now and challenge yourself!'),
                  );
                  break;
                case 'statistics':
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SudokuStatisticsPage(),
                      ),
                    );
                  }
                  break;
                case 'settings':
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share, size: 20),
                    const SizedBox(width: 12),
                    Text(loc.menuShare),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'statistics',
                child: Row(
                  children: [
                    const Icon(Icons.insights, size: 20),
                    const SizedBox(width: 12),
                    Text(loc.menuStatistics),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 20),
                    const SizedBox(width: 12),
                    Text(loc.menuSettings),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withAlpha(230),
              theme.colorScheme.secondary.withAlpha(153),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Ícone do jogo
              SvgPicture.asset(
                'assets/icons/app_icon.svg',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                loc.appTitle,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    const Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Jogar
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SudokuGameSelectorPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.play_arrow, size: 28),
                label: Text(loc.menuPlay),
              ),

              const SizedBox(height: 12),

              // Continuar (exibe apenas se houver jogo em andamento)
              allGamesAsync.when(
                data: (all) {
                  final incomplete = all.values.where((g) => g.isCompleted == false).toList();
                  if (incomplete.isEmpty) return const SizedBox.shrink();

                  incomplete.sort((a, b) {
                    final da = a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
                    final db = b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
                    return da.compareTo(db);
                  });

                  final oldest = incomplete.first;
                  final label = loc.selectorContinueLabel(oldest.gameNumber, oldest.packageNumber);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => InProgressGamesDialog(
                            inProgressGames: incomplete,
                          ),
                        );
                      },
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final notifier = ref.read(sudokuNotifierProvider.notifier);
                          final navigator = Navigator.of(context);
                          await notifier.loadOrCreateGame(
                            difficulty: oldest.difficulty,
                            packageNumber: oldest.packageNumber,
                            gameNumber: oldest.gameNumber,
                          );
                          navigator.push(MaterialPageRoute(builder: (_) => const SudokuHomePage()));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(label),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text(
                        loc.appFooter,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      );
                    }
                    final info = snapshot.data!;
                    return Text(
                      'v${info.version} • ${loc.appFooter}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
