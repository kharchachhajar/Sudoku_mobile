// ============================================
// services/sudoku_generator.dart
// ============================================
import 'dart:math';
import '../models/cell_model.dart';
import '../models/game_state.dart';

class SudokuGenerator {
  static final Random _random = Random();

  // Génère une nouvelle grille Sudoku
  static GameState generatePuzzle(Difficulty difficulty) {
    // Créer une grille solution complète
    List<List<int>> solution = _generateCompleteSolution();

    // Créer une copie pour le puzzle
    List<List<int>> puzzle = List.generate(
      9,
          (i) => List.generate(9, (j) => solution[i][j]),
    );

    // Retirer des cellules selon la difficulté
    int cellsToRemove = _getCellsToRemove(difficulty);
    _removeCells(puzzle, cellsToRemove);

    // Créer la grille de CellModel
    List<List<CellModel>> grid = List.generate(
      9,
          (row) => List.generate(
        9,
            (col) => CellModel(
          row: row,
          col: col,
          value: puzzle[row][col],
          solution: solution[row][col],
          isFixed: puzzle[row][col] != 0,
        ),
      ),
    );

    return GameState(grid: grid, difficulty: difficulty);
  }

  // Génère une solution complète valide
  static List<List<int>> _generateCompleteSolution() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  // Remplit la grille récursivement
  static bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

          for (int num in numbers) {
            if (_isValidPlacement(grid, row, col, num)) {
              grid[row][col] = num;

              if (_fillGrid(grid)) {
                return true;
              }

              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  // Vérifie si un placement est valide
  static bool _isValidPlacement(List<List<int>> grid, int row, int col, int num) {
    // Vérifier la ligne
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num) return false;
    }

    // Vérifier la colonne
    for (int x = 0; x < 9; x++) {
      if (grid[x][col] == num) return false;
    }

    // Vérifier le bloc 3x3
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }

    return true;
  }

  // Détermine combien de cellules retirer selon la difficulté
  static int _getCellsToRemove(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.facile:
        return 35 + _random.nextInt(5); // 35-40 cellules retirées
      case Difficulty.moyen:
        return 45 + _random.nextInt(5); // 45-50 cellules retirées
      case Difficulty.difficile:
        return 52 + _random.nextInt(5); // 52-57 cellules retirées
    }
  }

  // Retire des cellules de la grille
  static void _removeCells(List<List<int>> grid, int count) {
    int removed = 0;
    while (removed < count) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);

      if (grid[row][col] != 0) {
        grid[row][col] = 0;
        removed++;
      }
    }
  }

  // Calcule le score basé sur difficulté et temps
  static int calculateScore(Difficulty difficulty, int seconds) {
    int baseScore = 0;
    switch (difficulty) {
      case Difficulty.facile:
        baseScore = 1000;
        break;
      case Difficulty.moyen:
        baseScore = 2500;
        break;
      case Difficulty.difficile:
        baseScore = 5000;
        break;
    }

    // Bonus de temps (plus rapide = plus de points)
    int timeBonus = (3600 - seconds).clamp(0, 3000);
    return baseScore + timeBonus;
  }
}
