// ============================================
// services/sudoku_solver.dart
// Solver uniquement !
// ============================================

import '../models/cell_model.dart';

class SudokuSolver {
  // Vérifie si un nombre peut être placé dans une cellule
  static bool isValid(List<List<int>> board, int row, int col, int num) {
    // Vérifier la ligne
    for (int x = 0; x < 9; x++) {
      if (board[row][x] == num) {
        return false;
      }
    }

    // Vérifier la colonne
    for (int x = 0; x < 9; x++) {
      if (board[x][col] == num) {
        return false;
      }
    }

    // Vérifier le carré 3×3
    int startRow = row - row % 3;
    int startCol = col - col % 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) {
          return false;
        }
      }
    }

    return true;
  }
  static List<List<CellModel>> checkGrid(List<List<CellModel>> grid) {
    List<List<CellModel>> newGrid = grid.map(
            (row) => row.map((c) => c.copyWith(isError: false)).toList()
    ).toList();

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = newGrid[r][c];
        if (cell.value != 0 && cell.value != cell.solution) {
          newGrid[r][c] = cell.copyWith(isError: true);
        }
      }
    }
    return newGrid;
  }


  // Résolution du Sudoku par backtracking
  static bool solve(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValid(board, row, col, num)) {
              board[row][col] = num;

              if (solve(board)) {
                return true;
              }

              board[row][col] = 0;
            }
          }
          return false; // Aucun chiffre ne convient
        }
      }
    }
    return true; // Sudoku résolu
  }
}

