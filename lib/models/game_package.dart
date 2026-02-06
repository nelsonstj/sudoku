// lib/models/game_package.dart
import 'game_progress.dart';

class GamePackage {
  final String difficulty;
  final int packageNumber;
  final List<GameProgress> games;

  GamePackage({
    required this.difficulty,
    required this.packageNumber,
    required this.games,
  });

  bool get allCompleted => games.every((g) => g.isCompleted);

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty,
        'packageNumber': packageNumber,
        'games': games.map((g) => g.toJson()).toList(),
      };

  factory GamePackage.fromJson(Map<String, dynamic> json) => GamePackage(
        difficulty: json['difficulty'],
        packageNumber: json['packageNumber'],
        games: (json['games'] as List)
            .map((g) => GameProgress.fromJson(Map<String, dynamic>.from(g)))
            .toList(),
      );
}
