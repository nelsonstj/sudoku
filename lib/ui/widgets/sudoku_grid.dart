// lib/ui/widgets/sudoku_grid.dart
import 'package:flutter/material.dart';
import '../../models/sudoku_puzzle.dart';

typedef OnCellTap = void Function(int r, int c);

class SudokuGrid extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final int? selectedRow;
  final int? selectedCol;
  final int? selectedValue;
  final OnCellTap onCellTap;
  final List<List<bool>>? highlightedConflicts;
  final bool largerNumbers;
  final bool highlightRowCol;

  const SudokuGrid({
    super.key,
    required this.puzzle,
    required this.selectedRow,
    required this.selectedCol,
    required this.selectedValue,
    required this.onCellTap,
    this.highlightedConflicts,
    this.largerNumbers = false,
    this.highlightRowCol = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use Column of 9 rows, each row 9 expanded cells to keep layout square-ish
    // Precompute conflicts so they are available when building cells
    final selR = selectedRow;
    final selC = selectedCol;
    final selV = selectedValue;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final conflicts = List.generate(9, (_) => List.filled(9, false));
    if (selR != null && selC != null && selV != null && selV != 0) {
      for (var rr = 0; rr < 9; rr++) {
        for (var cc = 0; cc < 9; cc++) {
          if (rr == selR && cc == selC) continue;
          if (puzzle.getCell(rr, cc) == selV) {
            if (rr == selR || cc == selC) {
              conflicts[rr][cc] = true;
              conflicts[selR][selC] = true;
            }
          }
        }
      }
    }

    // Cores para alternar a cada box (3x3)
    final boxColor1 = isDarkMode ? const Color(0xFF525252) : const Color(0xFFF0F0F0);
    final boxColor2 = isDarkMode ? const Color(0xFF424242) : Colors.white;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
        child: Column(
          children: List.generate(9, (r) {
            return Expanded(
              child: Row(
                children: List.generate(9, (c) {
                  final isSelected = selectedRow == r && selectedCol == c;
                  final isSameRow = highlightRowCol && selectedRow != null && selectedRow == r;
                  final isSameCol = highlightRowCol && selectedCol != null && selectedCol == c;
                  final value = puzzle.getCell(r, c);
                  final fixed = puzzle.isFixed(r, c);
                  final isHighlighted = selectedValue != null && value == selectedValue && value != 0;
                  final isConflict = (highlightedConflicts != null)
                    ? (highlightedConflicts![r][c])
                    : conflicts[r][c];

                  final border = Border(
                    top: BorderSide(width: r % 3 == 0 ? 2 : 0.6, color: Colors.black),
                    left: BorderSide(width: c % 3 == 0 ? 2 : 0.6, color: Colors.black),
                    right: BorderSide(width: c == 8 ? 2 : 0.0, color: Colors.black),
                    bottom: BorderSide(width: r == 8 ? 2 : 0.0, color: Colors.black),
                  );

                  // Determinar qual cor de box (alterna a cada 3x3)
                  final boxRow = r ~/ 3;
                  final boxCol = c ~/ 3;
                  final boxIndex = boxRow * 3 + boxCol; // 0-8
                  final isAlternateBox = boxIndex % 2 == 1;
                  final baseBoxColor = isAlternateBox ? boxColor2 : boxColor1;

                  Color bg;
                  // Priority: selected cell conflict > other conflict > selected cell > row/column highlight > same-value highlight > box color
                  if (isSelected && isConflict) {
                    bg = Colors.red.shade200;
                  } else if (isConflict) {
                    bg = isDarkMode ? Color(0xFF73524b) : Color(0xFFffccc4);
                  } else if (isSelected) {
                    bg = isDarkMode ? Color(0xFF478079) : Color(0xFF7ac7c1);
                  } else if (isSameRow || isSameCol) {
                    bg = isDarkMode ? Color(0xFF516a67) : Color(0xFFb8dbd7);
                  } else if (isHighlighted) {
                    bg = isDarkMode ? Color(0xFF645d6f) : Color(0xFFd2d6ef);
                    //bg = Colors.yellow.shade100;
                  } else {
                    bg = baseBoxColor;
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onCellTap(r, c),
                      child: Container(
                        decoration: BoxDecoration(
                          border: border,
                          color: bg,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          value == 0 ? '' : value.toString(),
                          style: TextStyle(
                            fontSize: largerNumbers ? 24 : 18,
                            fontWeight: FontWeight.normal,
                            color: fixed 
                              ? (isDarkMode ? Colors.white : Colors.black)
                              : (isDarkMode ? Color(0xFF7aabd5) : Colors.indigo.shade700),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}