import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sudoku_provider.dart';
import '../../services/statistics_service.dart';
import '../../l10n/app_localizations.dart';

class SudokuStatisticsPage extends ConsumerWidget {
  const SudokuStatisticsPage({super.key});

  String _getDifficultyLabel(BuildContext context, String difficulty) {
    final loc = AppLocalizations.of(context)!;
    switch (difficulty) {
      case 'Easy':
        return loc.difficultyEasy;
      case 'Medium':
        return loc.difficultyMedium;
      case 'Hard':
        return loc.difficultyHard;
      case 'Special':
        return loc.difficultySpecial;
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statisticsTitle),
        backgroundColor: Colors.indigo,
        actions: [],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(sudokuNotifierProvider.notifier).getStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.statisticsNoGames));
          }

          final data = snapshot.data!;
          final perDifficulty = data['perDifficulty'] as Map<String, dynamic>;
          final totalOverall = data['totalOverall'] as int;

          // Ordem das dificuldades
          final difficulties = ['Easy', 'Medium', 'Hard', 'Special'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.statisticsProgressByPackage,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: difficulties.map((difficulty) {
                      final stats = perDifficulty[difficulty] as Map<String, dynamic>;
                      final completedPackages = stats['completedPackages'] as int;
                      final totalPackages = stats['totalPackages'] as int;
                      final completedGames = stats['completedGames'] as int;
                      final totalGames = stats['totalGames'] as int;
                      final lastPlayed = stats['lastPlayed'] as DateTime?;
                      final packageProgress = totalPackages == 0 ? 0.0 : (completedPackages / totalPackages) * 100;
                      final gameProgress = totalGames == 0 ? 0.0 : (completedGames / totalGames) * 100;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        child: ExpansionTile(
                          title: Text(
                            _getDifficultyLabel(context, difficulty),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '$completedGames/$totalGames jogos',
                            style: const TextStyle(fontSize: 14),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pacotes
                                  Text(
                                    'Pacotes: $completedPackages/$totalPackages completos',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: packageProgress / 100,
                                    color: Colors.indigo,
                                    backgroundColor: Colors.indigo.shade50,
                                    minHeight: 6,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Jogos
                                  Text(
                                    AppLocalizations.of(context)!.statisticsGamesCompleted(completedGames, totalGames),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: gameProgress / 100,
                                    color: Colors.green,
                                    backgroundColor: Colors.green.shade50,
                                    minHeight: 6,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Última jogada
                                  if (lastPlayed != null)
                                    Text(
                                      AppLocalizations.of(context)!.statisticsLastPlayed(_formatDate(lastPlayed)),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    )
                                  else
                                    const Text(
                                      'Nenhum jogo iniciado',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 24),
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.statisticsTotalTime,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      StatisticsService.formatTime(totalOverall),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} às '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
