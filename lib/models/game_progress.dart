// lib/models/game_progress.dart
import 'sudoku_puzzle.dart';

class GameProgress {
  final String difficulty;
  final int packageNumber;
  final int gameNumber;
  final SudokuPuzzle puzzle;
  final bool isCompleted;
  final DateTime? lastPlayed;

  GameProgress({
    required this.difficulty,
    required this.packageNumber,
    required this.gameNumber,
    required this.puzzle,
    required this.isCompleted,
    DateTime? lastPlayed,
  }) : lastPlayed = lastPlayed ?? DateTime.now();

  GameProgress copyWith({
    String? difficulty,
    int? packageNumber,
    int? gameNumber,
    SudokuPuzzle? puzzle,
    bool? isCompleted,
    DateTime? lastPlayed,
  }) {
    return GameProgress(
      difficulty: difficulty ?? this.difficulty,
      packageNumber: packageNumber ?? this.packageNumber,
      gameNumber: gameNumber ?? this.gameNumber,
      puzzle: puzzle ?? this.puzzle,
      isCompleted: isCompleted ?? this.isCompleted,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  String get key => '${difficulty}_p${packageNumber}_g$gameNumber';

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty,
        'packageNumber': packageNumber,
        'gameNumber': gameNumber,
        'puzzle': puzzle.toJson(),
        'completed': isCompleted,
        'lastPlayed': lastPlayed?.toIso8601String(),
      };

  factory GameProgress.fromJson(Map<String, dynamic> json) => GameProgress(
        difficulty: json['difficulty'],
        packageNumber: json['packageNumber'],
        gameNumber: json['gameNumber'],
        puzzle: SudokuPuzzle.fromJson(Map<String, dynamic>.from(json['puzzle'])),
        isCompleted: json['completed'] ?? false,
        lastPlayed: json['lastPlayed'] != null
          ? DateTime.tryParse(json['lastPlayed'])
          : null,
      );
}
