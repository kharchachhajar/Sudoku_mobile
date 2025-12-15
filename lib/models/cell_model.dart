// ============================================
// models/cell_model.dart
// ============================================

class CellModel {
  final int row;          // Position ligne (0-8)
  final int col;          // Position colonne (0-8)
  int value;              // Valeur actuelle (0-9, 0 = vide)
  final int solution;     // Solution correcte
  final bool isFixed;     // true = cellule pré-remplie, false = éditable
  List<int> notes;        // Notes/annotations (1-9)
  bool isError;          // true si erreur détectée
  bool isHighlighted;     // true si on met en surbrillance (same number)
  bool isSelected;        // true si la cellule est sélectionnée

  CellModel({
    required this.row,
    required this.col,
    required this.value,
    required this.solution,
    required this.isFixed,
    this.notes = const [],
    this.isError = false,
    this.isHighlighted = false,
    this.isSelected = false,
  });

  /// Vérifie si la cellule est vide
  bool get isEmpty => value == 0;

  /// Vérifie si la cellule est correcte
  bool get isCorrect => value == solution;

  /// Vérifie si la cellule peut être éditée
  bool get isEditable => !isFixed;

  /// Vérifie si la cellule a des notes
  bool get hasNotes => notes.isNotEmpty;

  /// Obtient le numéro du bloc 3x3 (0-8)
  int get blockIndex => (row ~/ 3) * 3 + (col ~/ 3);

  /// Obtient la ligne du bloc (0-2)
  int get blockRow => row ~/ 3;

  /// Obtient la colonne du bloc (0-2)
  int get blockCol => col ~/ 3;

  /// Crée une copie avec modifications
  CellModel copyWith({
    int? value,
    List<int>? notes,
    bool? isError,
    bool? isHighlighted,
    bool? isSelected,
  }) {
    return CellModel(
      row: row,
      col: col,
      value: value ?? this.value,
      solution: solution,
      isFixed: isFixed,
      notes: notes ?? List.from(this.notes),
      isError: isError ?? this.isError,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Ajoute une note
  CellModel addNote(int note) {
    if (!notes.contains(note) && note >= 1 && note <= 9) {
      List<int> newNotes = List.from(notes)..add(note);
      newNotes.sort();
      return copyWith(notes: newNotes);
    }
    return this;
  }

  /// Retire une note
  CellModel removeNote(int note) {
    if (notes.contains(note)) {
      List<int> newNotes = List.from(notes)..remove(note);
      return copyWith(notes: newNotes);
    }
    return this;
  }

  /// Bascule une note (ajoute si absente, retire si présente)
  CellModel toggleNote(int note) {
    if (notes.contains(note)) {
      return removeNote(note);
    } else {
      return addNote(note);
    }
  }

  /// Efface toutes les notes
  CellModel clearNotes() {
    return copyWith(notes: []);
  }

  /// Définit la valeur et efface les notes
  CellModel setValue(int newValue) {
    return copyWith(value: newValue, notes: []);
  }

  /// Efface la valeur (remet à 0)
  CellModel clearValue() {
    return copyWith(value: 0);
  }

  /// Marque comme erreur
  CellModel markError() => copyWith(isError: true);

  /// Efface l'erreur
  CellModel clearError() => copyWith(isError: false);

  /// Active/désactive le highlight (par ex. mêmes chiffres)
  CellModel setHighlight(bool highlight) => copyWith(isHighlighted: highlight);

  /// Sélectionne/désélectionne la cellule
  CellModel setSelected(bool selected) => copyWith(isSelected: selected);

  /// Convertit en JSON pour sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'value': value,
      'solution': solution,
      'isFixed': isFixed,
      'notes': notes,
      'isError': isError,
      'isHighlighted': isHighlighted,
      'isSelected': isSelected,
    };
  }

  /// Crée depuis JSON
  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(
      row: json['row'],
      col: json['col'],
      value: json['value'],
      solution: json['solution'],
      isFixed: json['isFixed'],
      notes: List<int>.from(json['notes'] ?? []),
      isError: json['isError'] ?? false,
      isHighlighted: json['isHighlighted'] ?? false,
      isSelected: json['isSelected']  ?? false,
    );
  }

  /// Crée une cellule vide
  factory CellModel.empty(int row, int col, int solution) {
    return CellModel(
      row: row,
      col: col,
      value: 0,
      solution: solution,
      isFixed: false,
    );
  }

  /// Crée une cellule fixe (pré-remplie)
  factory CellModel.fixed(int row, int col, int value) {
    return CellModel(
      row: row,
      col: col,
      value: value,
      solution: value,
      isFixed: true,
    );
  }

  @override
  String toString() {
    return 'Cell($row,$col): value=$value, solution=$solution, fixed=$isFixed, notes=$notes';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CellModel &&
        other.row == row &&
        other.col == col &&
        other.value == value &&
        other.solution == solution &&
        other.isFixed == isFixed;
  }

  @override
  int get hashCode {
    return row.hashCode ^
    col.hashCode ^
    value.hashCode ^
    solution.hashCode ^
    isFixed.hashCode;
  }
}

// Extensions utiles
extension CellModelListExtension on List<List<CellModel>> {
  /// Obtient une cellule à une position donnée
  CellModel getCell(int row, int col) => this[row][col];

  /// Définit une cellule à une position donnée
  void setCell(int row, int col, CellModel cell) {
    this[row][col] = cell;
  }

  /// Obtient toutes les cellules vides
  List<CellModel> get emptyCells {
    List<CellModel> cells = [];
    for (var row in this) {
      for (var cell in row) {
        if (cell.isEmpty && !cell.isFixed) {
          cells.add(cell);
        }
      }
    }
    return cells;
  }

  /// Obtient toutes les cellules fixes
  List<CellModel> get fixedCells {
    List<CellModel> cells = [];
    for (var row in this) {
      for (var cell in row) {
        if (cell.isFixed) {
          cells.add(cell);
        }
      }
    }
    return cells;
  }

  /// Obtient toutes les cellules avec erreurs
  List<CellModel> get errorCells {
    List<CellModel> cells = [];
    for (var row in this) {
      for (var cell in row) {
        if (cell.isError) {
          cells.add(cell);
        }
      }
    }
    return cells;
  }

  /// Compte le nombre de cellules remplies
  int get filledCount {
    int count = 0;
    for (var row in this) {
      for (var cell in row) {
        if (!cell.isEmpty) count++;
      }
    }
    return count;
  }

  /// Vérifie si la grille est complète
  bool get isComplete {
    for (var row in this) {
      for (var cell in row) {
        if (cell.isEmpty || !cell.isCorrect) {
          return false;
        }
      }
    }
    return true;
  }
}