import '../models/game_progress.dart';

class StatisticsService {
  /// Tempo total jogado (em segundos)
  static int getTotalTime(List<GameProgress> games) {
    return games.fold(0, (sum, g) => sum + g.puzzle.elapsedTime.inSeconds);
  }

  /// Tempo total, concluídos e progresso por pacote
  /// Nota: conta todos os 10 jogos por pacote (iniciados ou não)
  static Map<int, Map<String, dynamic>> getStatsPerPackage(List<GameProgress> allGames) {
    final Map<int, Map<String, dynamic>> stats = {};

    // Inicializar todas os 20 pacotes com 10 jogos cada
    for (var p = 1; p <= 20; p++) {
      stats[p] = {
        'totalSeconds': 0,
        'completed': 0,
        'totalGames': 10, // sempre 10 jogos por pacote
        'lastPlayed': null,
      };
    }

    // Atualizar com dados dos jogos salvos
    for (final g in allGames) {
      final pkg = stats[g.packageNumber]!;
      pkg['totalSeconds'] += g.puzzle.elapsedTime.inSeconds;
      if (g.isCompleted) pkg['completed'] += 1;

      // atualiza última jogada
      if (g.lastPlayed != null) {
        final last = pkg['lastPlayed'] as DateTime?;
        if (last == null || g.lastPlayed!.isAfter(last)) {
          pkg['lastPlayed'] = g.lastPlayed;
        }
      }
    }

    // calcular percentual
    for (final entry in stats.entries) {
      final data = entry.value;
      final total = data['totalGames'] as int;
      final completed = data['completed'] as int;
      data['progress'] = total == 0 ? 0.0 : (completed / total) * 100;
    }

    return stats;
  }

  /// Estatísticas agregadas por dificuldade
  /// Retorna: Map com dificuldade mapeada para completedPackages, totalPackages, completedGames, totalGames, lastPlayed, totalSeconds
  static Map<String, Map<String, dynamic>> getStatsPerDifficulty(List<GameProgress> allGames) {
    final Map<String, Map<String, dynamic>> stats = {};
    
    // Inicializar as 4 dificuldades
    final difficulties = ['Easy', 'Medium', 'Hard', 'Special'];
    for (final diff in difficulties) {
      stats[diff] = {
        'completedPackages': 0,
        'totalPackages': 20,
        'completedGames': 0,
        'totalGames': 200, // 20 pacotes * 10 jogos
        'lastPlayed': null,
        'totalSeconds': 0,
      };
    }

    // Agrupar por dificuldade e pacote para contar pacotes completos
    final packagesPerDifficulty = <String, Map<int, List<GameProgress>>>{};
    for (final diff in difficulties) {
      packagesPerDifficulty[diff] = {};
      for (var p = 1; p <= 20; p++) {
        packagesPerDifficulty[diff]![p] = [];
      }
    }

    // Distribuir jogos
    for (final g in allGames) {
      packagesPerDifficulty[g.difficulty]![g.packageNumber]!.add(g);
      stats[g.difficulty]!['totalSeconds'] += g.puzzle.elapsedTime.inSeconds;
      if (g.isCompleted) stats[g.difficulty]!['completedGames'] += 1;
      
      // atualizar última jogada
      if (g.lastPlayed != null) {
        final last = stats[g.difficulty]!['lastPlayed'] as DateTime?;
        if (last == null || g.lastPlayed!.isAfter(last)) {
          stats[g.difficulty]!['lastPlayed'] = g.lastPlayed;
        }
      }
    }

    // Contar pacotes completos
    for (final diff in difficulties) {
      int completed = 0;
      final packages = packagesPerDifficulty[diff]!;
      for (final gamesList in packages.values) {
        // Um pacote é completo se todos os 10 jogos estão completos
        if (gamesList.length == 10 && gamesList.every((g) => g.isCompleted)) {
          completed++;
        }
      }
      stats[diff]!['completedPackages'] = completed;
    }

    return stats;
  }

  /// Tempo total geral
  static int getTotalOverall(List<GameProgress> games) {
    return getTotalTime(games);
  }

  /// Formata segundos como HH:MM:SS
  static String formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
