// lib/ui/widgets/number_pad.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sudoku_provider.dart';

class NumberPad extends ConsumerWidget {
  final void Function(int) onNumberSelected;
  final VoidCallback onClear;
  final bool isGameCompleted;

  const NumberPad({
    super.key,
    required this.onNumberSelected,
    required this.onClear,
    this.isGameCompleted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use selector para evitar rebuilds desnecessários - apenas rebuilda se o grid muda
    final puzzle = ref.watch(
      sudokuNotifierProvider.select((state) => state.currentGame?.puzzle),
    );
    
    final counts = List<int>.filled(10, 0);
    if (puzzle != null) {
      for (var r = 0; r < puzzle.grid.length; r++) {
        for (var c = 0; c < puzzle.grid[r].length; c++) {
          final v = puzzle.grid[r][c];
          if (v >= 1 && v <= 9) counts[v] = counts[v] + 1;
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // We want up to 5 items per row and consistent spacing
        final maxWidth = constraints.maxWidth;
        final desiredButtonsPerRow = 5;
        final spacing = 8.0;
        final totalSpacing = spacing * (desiredButtonsPerRow - 1);
        // compute a sensible button size (cap it)
        final availableForButtons = maxWidth - totalSpacing - 16; // small horizontal padding
        final btnSize = min(72.0, max(40.0, availableForButtons / desiredButtonsPerRow));

        Widget buildButton(int n) {
          final isComplete = counts[n] >= 9;
          return SizedBox(
            width: btnSize,
            height: btnSize,
            child: ElevatedButton(
              onPressed: (puzzle == null || isComplete || isGameCompleted) ? null : () => onNumberSelected(n),
              style: ElevatedButton.styleFrom(
                backgroundColor: (isComplete || isGameCompleted) ? Colors.grey.shade300 : Colors.indigo.shade600,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: (isComplete || isGameCompleted) ? 0 : 2,
                minimumSize: Size(btnSize, btnSize),
              ),
              child: Text(
                '$n',
                style: TextStyle(
                  fontSize: max(14, btnSize * 0.36),
                  color: (isComplete || isGameCompleted) ? Colors.black54 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        Widget delBtn() {
          return SizedBox(
            width: btnSize,
            height: btnSize,
            child: ElevatedButton(
              onPressed: (puzzle == null || isGameCompleted) ? null : onClear,
              style: ElevatedButton.styleFrom(
                backgroundColor: (puzzle == null || isGameCompleted) ? Colors.grey.shade300 : Colors.redAccent.shade400,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(btnSize, btnSize),
                elevation: (puzzle == null || isGameCompleted) ? 0 : 2,
              ),
              child: Icon(
                Icons.backspace,
                color: (puzzle == null || isGameCompleted) ? Colors.black54 : Colors.white,
                size: 20,
              ),
            ),
          );
        }

        // build rows: 1..5 then 6..9 + delete
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: [for (int i = 1; i <= 5; i++) buildButton(i)],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: [for (int i = 6; i <= 9; i++) buildButton(i), delBtn()],
              ),
            ],
          ),
        );
      },
    );
  }
}
