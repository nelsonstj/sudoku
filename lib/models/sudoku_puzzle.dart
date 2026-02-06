// lib/models/sudoku_puzzle.dart
import 'dart:convert';

class SudokuPuzzle {
  final List<List<int>> grid;
  final List<List<bool>> fixed;
  final List<List<int>> solution;
  final String difficulty;
  final Duration elapsedTime;
  DateTime? _startTime;
  bool isCompleted;

  SudokuPuzzle({
    required this.grid,
    required this.fixed,
    required this.solution,
    required this.difficulty,
    this.elapsedTime = Duration.zero,
    this.isCompleted = false,
  });

  /// factory vazio
  factory SudokuPuzzle.empty([int size = 9]) {
    return SudokuPuzzle(
      grid: List.generate(size, (_) => List.filled(size, 0)),
      fixed: List.generate(size, (_) => List.filled(size, false)),
      solution: List.generate(size, (_) => List.filled(size, 0)),
      difficulty: 'Easy',
      elapsedTime: Duration(),
    );
  }
  
  int getCell(int r, int c) => grid[r][c];
  bool isFixed(int r, int c) => fixed[r][c];

  SudokuPuzzle copyWith({
    List<List<int>>? grid,
    List<List<bool>>? fixed,
    List<List<int>>? solution,
    String? difficulty,
    Duration? elapsedTime,
    bool? isCompleted,
  }) {
    return SudokuPuzzle(
      grid: grid != null ? _deepCloneGrid(grid) : _deepCloneGrid(this.grid),
      fixed: fixed != null ? _deepCloneBoolGrid(fixed) : _deepCloneBoolGrid(this.fixed),
      solution: solution != null ? _deepCloneGrid(solution) : _deepCloneGrid(this.solution),
      difficulty: difficulty ?? this.difficulty,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  SudokuPuzzle copyWithCell(int r, int c, int value) {
    final newGrid = _deepCloneGrid(grid);
    newGrid[r][c] = value.clamp(0, 9);
    final newFixed = _deepCloneBoolGrid(fixed);
    return SudokuPuzzle(
      grid: newGrid,
      fixed: newFixed,
      solution: _deepCloneGrid(solution),
      difficulty: difficulty,
      elapsedTime: elapsedTime,
    );
  }

  bool isSolvedCorrectly() {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (grid[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'grid': grid,
        'fixed': fixed,
        'solution': solution,
        'difficulty': difficulty,
        'elapsedSeconds': elapsedTime.inSeconds,
        'isCompleted': isCompleted,
      };

  String toJsonString() => jsonEncode(toJson());

  factory SudokuPuzzle.fromJson(Map<String, dynamic> json) {
    List<List<int>> parse2DInt(dynamic d) =>
        (d as List).map((r) => (r as List).map((e) => (e as num).toInt()).toList()).toList();

    List<List<bool>> parse2DBool(dynamic d) =>
        (d as List).map((r) => (r as List).map((e) => e as bool).toList()).toList();

    return SudokuPuzzle(
      grid: parse2DInt(json['grid']),
      fixed: parse2DBool(json['fixed']),
      solution: parse2DInt(json['solution']),
      difficulty: json['difficulty'] as String,
      elapsedTime: Duration(seconds: (json['elapsedSeconds'] ?? 0) as int),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  factory SudokuPuzzle.fromJsonString(String s) => SudokuPuzzle.fromJson(jsonDecode(s) as Map<String, dynamic>);

  // helpers
  static List<List<int>> _deepCloneGrid(List<List<int>> g) => g.map((r) => List<int>.from(r)).toList();
  static List<List<bool>> _deepCloneBoolGrid(List<List<bool>> g) => g.map((r) => List<bool>.from(r)).toList();

  int countOccurrences(int number) {
    int count = 0;
    for (var row in grid) {
      for (var value in row) {
        if (value == number) count++;
      }
    }
    return count;
  }

  bool isNumberComplete(int number) {
    return countOccurrences(number) >= 9; // 9 vezes o mesmo número
  }

  void startTimer() {
    _startTime ??= DateTime.now();
  }

  void pauseTimer() {
    if (_startTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(_startTime!);
      _startTime = null;
      // acumulando o tempo
      copyWith(elapsedTime: elapsedTime + elapsed);
    }
  }

  SudokuPuzzle stopTimer() {
    if (_startTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(_startTime!);
      _startTime = null;
      return copyWith(elapsedTime: elapsedTime + elapsed, isCompleted: true);
    }
    return this;
  }

  String get formattedElapsedTime {
    final totalSeconds = elapsedTime.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

}
