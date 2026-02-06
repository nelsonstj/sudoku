// lib/models/game_library.dart
import 'game_package.dart';
import 'game_progress.dart';

class GameLibrary {
  final Map<String, List<GamePackage>> library;

  GameLibrary(this.library);

  factory GameLibrary.empty() => GameLibrary({});

  List<GamePackage> getPackages(String difficulty) {
    return library[difficulty] ?? [];
  }

  void addGame(GameProgress progress) {
    final packages = library.putIfAbsent(progress.difficulty, () => []);
    var package = packages.firstWhere(
      (p) => p.packageNumber == progress.packageNumber,
      orElse: () {
        final newPackage = GamePackage(
          difficulty: progress.difficulty,
          packageNumber: progress.packageNumber,
          games: [],
        );
        packages.add(newPackage);
        return newPackage;
      },
    );

    // Atualiza ou adiciona jogo
    final index = package.games
        .indexWhere((g) => g.gameNumber == progress.gameNumber);
    if (index >= 0) {
      package.games[index] = progress;
    } else {
      package.games.add(progress);
    }
  }

  Map<String, dynamic> toJson() => {
        'library': library.map((diff, pkgs) => MapEntry(
              diff,
              pkgs.map((p) => p.toJson()).toList(),
            )),
      };

  factory GameLibrary.fromJson(Map<String, dynamic> json) {
    final lib = <String, List<GamePackage>>{};
    final data = json['library'] as Map<String, dynamic>? ?? {};
    for (var entry in data.entries) {
      lib[entry.key] = (entry.value as List)
          .map((p) => GamePackage.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    }
    return GameLibrary(lib);
  }
}
