// ============================================
// models/game_state.dart
// ============================================

import 'cell_model.dart';

enum Difficulty { facile, moyen, difficile }

class GameState {
  final List<List<CellModel>> grid;
  final Difficulty difficulty;
  final int errors;
  final int elapsedSeconds;
  final bool isNotesMode;
  final int? selectedRow;
  final int? selectedCol;
  final DateTime startTime;
  final int score;

  GameState({
    required this.grid,
    required this.difficulty,
    this.errors = 0,
    this.elapsedSeconds = 0,
    this.isNotesMode = false,
    this.selectedRow,
    this.selectedCol,
    DateTime? startTime,
    this.score = 0,
  }) : startTime = startTime ?? DateTime.now();

  // Vérifie si le jeu est terminé (5 erreurs ou grille complète)
  bool get isGameOver => errors >= 5 || isComplete;

  // Vérifie si la grille est complètement remplie et correcte
  bool get isComplete {
    for (var row in grid) {
      for (var cell in row) {
        if (cell.value == 0 || cell.value != cell.solution) {
          return false;
        }
      }
    }
    return true;
  }

  // Compte le nombre de cellules remplies
  int get filledCellsCount {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.value != 0) count++;
      }
    }
    return count;
  }

  // Compte le nombre de cellules vides
  int get emptyCellsCount => 81 - filledCellsCount;

  // Compte combien de fois un numéro est utilisé
  int countNumber(int number) {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.value == number) count++;
      }
    }
    return count;
  }

  // Vérifie si un numéro est complet (utilisé 9 fois)
  bool isNumberComplete(int number) {
    return countNumber(number) == 9;
  }

  // Crée une copie de l'état avec des modifications
  GameState copyWith({
    List<List<CellModel>>? grid,
    Difficulty? difficulty,
    int? errors,
    int? elapsedSeconds,
    bool? isNotesMode,
    int? selectedRow,
    int? selectedCol,
    DateTime? startTime,
    int? score,
    bool clearSelection = false,
  }) {
    return GameState(
      grid: grid ?? this.grid.map((row) => row.map((cell) => cell).toList()).toList(),
      difficulty: difficulty ?? this.difficulty,
      errors: errors ?? this.errors,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isNotesMode: isNotesMode ?? this.isNotesMode,
      selectedRow: clearSelection ? null : (selectedRow ?? this.selectedRow),
      selectedCol: clearSelection ? null : (selectedCol ?? this.selectedCol),
      startTime: startTime ?? this.startTime,
      score: score ?? this.score,
    );
  }

  // Convertit l'état en JSON pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'grid': grid.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
      'difficulty': difficulty.index,
      'errors': errors,
      'elapsedSeconds': elapsedSeconds,
      'isNotesMode': isNotesMode,
      'selectedRow': selectedRow,
      'selectedCol': selectedCol,
      'startTime': startTime.toIso8601String(),
      'score': score,
    };
  }

  // Crée un état depuis JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      grid: (json['grid'] as List)
          .map((row) => (row as List)
          .map((cell) => CellModel.fromJson(cell))
          .toList())
          .toList(),
      difficulty: Difficulty.values[json['difficulty']],
      errors: json['errors'] ?? 0,
      elapsedSeconds: json['elapsedSeconds'] ?? 0,
      isNotesMode: json['isNotesMode'] ?? false,
      selectedRow: json['selectedRow'],
      selectedCol: json['selectedCol'],
      startTime: DateTime.parse(json['startTime']),
      score: json['score'] ?? 0,
    );
  }

  // Obtient le nom de la difficulté
  String get difficultyName {
    switch (difficulty) {
      case Difficulty.facile:
        return 'Facile';
      case Difficulty.moyen:
        return 'Moyen';
      case Difficulty.difficile:
        return 'Difficile';
    }
  }

  // Réinitialise la grille (efface toutes les valeurs non fixes)
  GameState resetGrid() {
    List<List<CellModel>> newGrid = grid.map((row) {
      return row.map((cell) {
        if (cell.isFixed) {
          return cell;
        } else {
          return cell.copyWith(value: 0, notes: [], isError: false);
        }
      }).toList();
    }).toList();

    return copyWith(
      grid: newGrid,
      errors: 0,
      elapsedSeconds: 0,
      startTime: DateTime.now(),
      clearSelection: true,
    );
  }

  // Obtient toutes les cellules vides
  List<CellModel> get emptyCells {
    List<CellModel> cells = [];
    for (var row in grid) {
      for (var cell in row) {
        if (cell.value == 0 && !cell.isFixed) {
          cells.add(cell);
        }
      }
    }
    return cells;
  }

  // Obtient toutes les cellules avec erreurs
  List<CellModel> get errorCells {
    List<CellModel> cells = [];
    for (var row in grid) {
      for (var cell in row) {
        if (cell.isError) {
          cells.add(cell);
        }
      }
    }
    return cells;
  }

  @override
  String toString() {
    return 'GameState(difficulty: $difficultyName, errors: $errors, time: $elapsedSeconds, filled: $filledCellsCount/81)';
  }
}

// Extensions utiles pour Difficulty
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.facile:
        return 'Facile';
      case Difficulty.moyen:
        return 'Moyen';
      case Difficulty.difficile:
        return 'Difficile';
    }
  }

  int get minCellsToRemove {
    switch (this) {
      case Difficulty.facile:
        return 35;
      case Difficulty.moyen:
        return 45;
      case Difficulty.difficile:
        return 52;
    }
  }

  int get maxCellsToRemove {
    switch (this) {
      case Difficulty.facile:
        return 40;
      case Difficulty.moyen:
        return 50;
      case Difficulty.difficile:
        return 57;
    }
  }

  int get baseScore {
    switch (this) {
      case Difficulty.facile:
        return 1000;
      case Difficulty.moyen:
        return 2500;
      case Difficulty.difficile:
        return 5000;
    }
  }
}