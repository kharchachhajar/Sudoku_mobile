// ============================================
// widgets/sudoku_grid.dart
// ============================================

import 'package:flutter/material.dart';
import '../models/cell_model.dart';
import '../utils/constants.dart';

class SudokuGrid extends StatelessWidget {
  final List<List<CellModel>> grid;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int, int) onCellTap;
  final bool highlightSimilar;

  const SudokuGrid({
    Key? key,
    required this.grid,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
    this.highlightSimilar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppConstants.thickBorderColor,
            width: AppConstants.gridBorderWidth,
          ),
        ),
        child: Column(
          children: List.generate(9, (row) {
            return Expanded(
              child: Row(
                children: List.generate(9, (col) {
                  return Expanded(
                    child: _buildCell(row, col),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final cell = grid[row][col];

    final isSelected = selectedRow == row && selectedCol == col;
    final isSameRow = selectedRow == row;
    final isSameCol = selectedCol == col;

    final isSameBlock = selectedRow != null &&
        selectedCol != null &&
        row ~/ 3 == selectedRow! ~/ 3 &&
        col ~/ 3 == selectedCol! ~/ 3;

    final isSameValue = highlightSimilar &&
        cell.value != 0 &&
        selectedRow != null &&
        selectedCol != null &&
        grid[selectedRow!][selectedCol!].value == cell.value;

    Color bg = AppConstants.backgroundColor;
    // Couleur du texte par défaut
    Color textColor = cell.isFixed
        ? AppConstants.fixedCellColor
        : AppConstants.editableCellColor;

    // PRIORITÉ 1 : ERREUR
    if (cell.isError) {
      bg = AppConstants.errorCellColor;
      textColor = AppConstants.errorColor; // ⬅️ AJOUT : Texte rouge pour erreur
    }
    // PRIORITÉ 2 : CASE SÉLECTIONNÉE
    else if (isSelected) {
      bg = AppConstants.selectedCellColor;
    }
    // PRIORITÉ 3 : MÊME CHIFFRE
    else if (isSameValue) {
      bg = const Color(0xFF1B89CD);
      textColor = Colors.white; // ⬅️ Texte blanc pour meilleure visibilité
    }
    // PRIORITÉ 4 : MÊME LIGNE / COLONNE / BLOC
    else if (isSameRow || isSameCol || isSameBlock) {
      bg = AppConstants.highlightCellColor;
    }

    return GestureDetector(
      onTap: () => onCellTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            right: BorderSide(
              color: col % 3 == 2
                  ? AppConstants.thickBorderColor
                  : AppConstants.borderColor,
              width: col % 3 == 2
                  ? AppConstants.blockBorderWidth
                  : AppConstants.cellBorderWidth,
            ),
            bottom: BorderSide(
              color: row % 3 == 2
                  ? AppConstants.thickBorderColor
                  : AppConstants.borderColor,
              width: row % 3 == 2
                  ? AppConstants.blockBorderWidth
                  : AppConstants.cellBorderWidth,
            ),
          ),
        ),
        child: Center(
          child: cell.value != 0
              ? Text(
            "${cell.value}",
            style: TextStyle(
              fontSize: AppConstants.cellValueFontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          )
              : cell.notes.isNotEmpty
              ? _buildNotesGrid(cell.notes)
              : const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildNotesGrid(List<int> notes) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(2),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (i) {
        final num = i + 1;
        return Center(
          child: notes.contains(num)
              ? Text(
            "$num",
            style: TextStyle(
              fontSize: AppConstants.noteFontSize,
              color: AppConstants.noteColor,
            ),
          )
              : const SizedBox(),
        );
      }),
    );
  }
}
