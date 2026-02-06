// lib/core/sudoku_generator.dart
import 'dart:math';

class SudokuGenerator {
  final Random _rng = Random();

  List<List<int>> generateFullSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          var nums = List<int>.generate(9, (i) => i + 1);
          nums.shuffle(_rng);
          for (var n in nums) {
            if (_isSafe(grid, r, c, n)) {
              grid[r][c] = n;
              if (_fillGrid(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isSafe(List<List<int>> grid, int r, int c, int n) {
    for (var i = 0; i < 9; i++) {
      if (grid[r][i] == n) return false;
      if (grid[i][c] == n) return false;
    }
    final br = (r ~/ 3) * 3;
    final bc = (c ~/ 3) * 3;
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (grid[br + i][bc + j] == n) return false;
      }
    }
    return true;
  }

  List<List<int>> createPuzzleFromSolution(List<List<int>> solution, String difficulty) {
    final grid = List.generate(9, (r) => List<int>.from(solution[r]));
    int removeCount;
    switch (difficulty) {
      case 'Medium':
        removeCount = 46;
        break;
      case 'Hard':
        removeCount = 52;
        break;
      case 'Special':
        removeCount = 64;
        break;
      case 'Easy':
      default:
        removeCount = 36;
        break;
    }
    _removeNumbers(grid, removeCount);
    return grid;
  }

  void _removeNumbers(List<List<int>> grid, int removeCount) {
    final cells = List.generate(81, (i) => i);
    cells.shuffle(_rng);
    int removed = 0;
    for (final idx in cells) {
      if (removed >= removeCount) break;
      final r = idx ~/ 9;
      final c = idx % 9;
      if (grid[r][c] == 0) continue;
      final backup = grid[r][c];
      grid[r][c] = 0;
      // quick solvable check
      final copy = List.generate(9, (i) => List<int>.from(grid[i]));
      if (_hasAnySolution(copy)) {
        removed++;
      } else {
        grid[r][c] = backup;
      }
    }
  }

  bool _hasAnySolution(List<List<int>> grid) {
    return _solve(grid);
  }

  bool _solve(List<List<int>> grid) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          for (var n = 1; n <= 9; n++) {
            if (_isSafe(grid, r, c, n)) {
              grid[r][c] = n;
              if (_solve(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }
}
