// ============================================
// screens/game_screen.dart
// ============================================
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/cell_model.dart';
import '../services/sudoku_solver.dart';
import '../services/storage_service.dart';
import '../services/sudoku_generator.dart';
import 'result_screen.dart';
import 'package:flutter/services.dart'; // Pour HapticFeedback
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/game_provider.dart';



class GameScreen extends StatefulWidget {
  final GameState gameState;
  final bool isDailyChallenge;

  const GameScreen({Key? key, required this.gameState , this.isDailyChallenge = false,}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  late SettingsProvider _settings;
  Timer? _timer;
  int? highlightedNumber; // pour gérer le highlight des chiffres fixes

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
    _settings = Provider.of<SettingsProvider>(context, listen: false);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_gameState.isGameOver) {
        setState(() {
          _gameState = _gameState.copyWith(
            elapsedSeconds: _gameState.elapsedSeconds + 1,
          );
        });
        StorageService.saveGame(_gameState);
      } else {
        timer.cancel();
      }
    });
  }

  void _onCellTap(int row, int col) {
    final cell = _gameState.grid[row][col];

    setState(() {
      // Si c'est une cellule fixe avec une valeur
      if (cell.isFixed && cell.value != 0) {
        // Highlight tous les numéros identiques (fixes et non-fixes)
        highlightedNumber = cell.value;

        _gameState = _gameState.copyWith(
          selectedRow: row,
          selectedCol: col,
          grid: _gameState.grid.map((rowCells) {
            return rowCells.map((c) {
              // Highlight toutes les cellules avec la même valeur
              if (c.value == cell.value) {
                return c.copyWith(isHighlighted: true);
              } else {
                return c.copyWith(isHighlighted: false);
              }
            }).toList();
          }).toList(),
        );
      } else {
        // Cellule normale (éditable)
        _gameState = _gameState.copyWith(
          selectedRow: row,
          selectedCol: col,
        );
        highlightedNumber = null;
      }
    });
  }

  void highlightNumber(int number) {
    setState(() {
      _gameState = _gameState.copyWith(
        grid: _gameState.grid.map((row) {
          return row.map((cell) {
            if (cell.value == number && cell.isFixed) {
              return cell.copyWith(isHighlighted: true);
            } else {
              return cell.copyWith(isHighlighted: false);
            }
          }).toList();
        }).toList(),
      );
    });
  }

  void _onNumberTap(int number) {
    if (_gameState.selectedRow == null || _gameState.selectedCol == null) return;

    final row = _gameState.selectedRow!;
    final col = _gameState.selectedCol!;
    final cell = _gameState.grid[row][col];

    if (cell.isFixed) {
      // Si l'utilisateur clique sur un numéro fixe, on highlight tous les chiffres fixes identiques
      setState(() {
        highlightedNumber = cell.value;
      });
      return;
    }

    setState(() {
      List<List<CellModel>> newGrid = _gameState.grid
          .map((r) => r.map((c) => c).toList())
          .toList();

      if (_gameState.isNotesMode) {
        // Mode notes
        List<int> newNotes = List.from(cell.notes);
        if (newNotes.contains(number)) {
          newNotes.remove(number);
        } else {
          newNotes.add(number);
          newNotes.sort();
        }
        newGrid[row][col] = cell.copyWith(notes: newNotes, value: 0);
      } else {
        // Mode normal
        int newValue = cell.value == number ? 0 : number;
        newGrid[row][col] = cell.copyWith(value: newValue, notes: []);


        // Vérifier si c'est une erreur
        if (_settings.autoCheckErrors && newValue != 0 && newValue != cell.solution) {
          int newErrors = _gameState.errors + 1;
          newGrid[row][col] = newGrid[row][col].copyWith(isError: true);
          _gameState = _gameState.copyWith(errors: newErrors);

          // ⭐ VIBRATION si activée
          if (_settings.vibrateEnabled) {
            HapticFeedback.mediumImpact();
          }

          if (newErrors >= 5) {
            _gameOver(false);
            return;
          }
        } else {
          newGrid[row][col] = newGrid[row][col].copyWith(isError: false);
        }
      }

      _gameState = _gameState.copyWith(grid: newGrid);

      // Effacer le highlight si l'utilisateur a joué un chiffre non fixe
      highlightedNumber = null;

      // Vérifier si le jeu est terminé
      if (_gameState.isComplete) {
        _gameOver(true);
      } else {
        StorageService.saveGame(_gameState);
      }
    });
  }

  Future<void> _gameOver(bool won)  async {
    _timer?.cancel();

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (won) {
      int score = SudokuGenerator.calculateScore(
        _gameState.difficulty,
        _gameState.elapsedSeconds,
      );
      // ⭐ SAUVEGARDER VIA GameProvider (qui met à jour les stats)
      await gameProvider.completeGame(
        difficulty: _gameState.difficulty,
        timeSeconds: _gameState.elapsedSeconds,
        won: true,
      );

      StorageService.clearSavedGame();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              difficulty: _gameState.difficulty,
              time: _gameState.elapsedSeconds,
              score: score,
              won: true,
            ),
          ),
        );
      }
    } else {
      // ⭐ SAUVEGARDER LA PARTIE PERDUE
      await gameProvider.completeGame(
        difficulty: _gameState.difficulty,
        timeSeconds: _gameState.elapsedSeconds,
        won: false,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              difficulty: _gameState.difficulty,
              time: _gameState.elapsedSeconds,
              score: 0,
              won: false,
            ),
          ),
        );
      }
    }
  }

  void _eraseCell() {
    if (_gameState.selectedRow == null || _gameState.selectedCol == null) return;

    final row = _gameState.selectedRow!;
    final col = _gameState.selectedCol!;
    final cell = _gameState.grid[row][col];

    if (cell.isFixed) return;

    setState(() {
      List<List<CellModel>> newGrid = _gameState.grid.map((r) =>
          r.map((c) => c).toList()
      ).toList();

      newGrid[row][col] = cell.copyWith(value: 0, notes: []);
      _gameState = _gameState.copyWith(grid: newGrid);
      StorageService.saveGame(_gameState);
    });
  }

  void _checkSolution() {
    setState(() {
      List<List<CellModel>> checkedGrid = SudokuSolver.checkGrid(_gameState.grid);
      _gameState = _gameState.copyWith(grid: checkedGrid);
    });

    // Compter les erreurs trouvées
    int errors = 0;
    for (var row in _gameState.grid) {
      for (var cell in row) {
        if (cell.isError) errors++;
      }
    }

    if (errors > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errors erreur${errors > 1 ? 's' : ''} trouvée${errors > 1 ? 's' : ''}'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    } else if (_gameState.isComplete) {
      _gameOver(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune erreur ! Continuez !'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  void _toggleNotesMode() {
    setState(() {
      _gameState = _gameState.copyWith(isNotesMode: !_gameState.isNotesMode);
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getDifficultyText() {
    switch (_gameState.difficulty) {
      case Difficulty.facile:
        return 'Facile';
      case Difficulty.moyen:
        return 'Moyen';
      case Difficulty.difficile:
        return 'Difficile';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            StorageService.saveGame(_gameState);
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${_gameState.grid.expand((row) => row).where((cell) => cell.value != 0).length}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('Difficulté', _getDifficultyText()),
                _buildInfoItem('Erreurs', '${_gameState.errors}/5'),
                _buildInfoItem('Temps', _formatTime(_gameState.elapsedSeconds)),
              ],
            ),
          ),

          // Grille Sudoku
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSudokuGrid(),
                ),
              ),
            ),
          ),

          // Boutons d'action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.undo, 'Annuler', () {}),
                _buildActionButton(Icons.backspace, 'Effacer', _eraseCell),
                _buildActionButton(
                  Icons.edit_note,
                  'Notes',
                  _toggleNotesMode,
                  isActive: _gameState.isNotesMode,
                ),
                _buildActionButton(Icons.lightbulb, 'Indice', () {}),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Clavier numérique
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(9, (index) {
                int number = index + 1;
                return _buildNumberButton(number);
              }),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    // ⭐ Ne pas afficher le temps si désactivé
    if (label == 'Temps' && !_settings.showTimer) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  Widget _buildSudokuGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF424242), width: 2),
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
    );
  }

  Widget _buildCell(int row, int col) {
    final cell = _gameState.grid[row][col];
    final isSelected = _gameState.selectedRow == row && _gameState.selectedCol == col;
    final isSameRow = _gameState.selectedRow == row;
    final isSameCol = _gameState.selectedCol == col;
    final isSameBlock = _gameState.selectedRow != null &&
        _gameState.selectedCol != null &&
        (row ~/ 3 == _gameState.selectedRow! ~/ 3) &&
        (col ~/ 3 == _gameState.selectedCol! ~/ 3);

    Color backgroundColor = Colors.white;
    Color textColor;

    if (cell.isError) {
      backgroundColor = const Color(0xFFFFCDD2);
      textColor = const Color(0xFFE53935);
    } else if (isSelected) {
      backgroundColor = const Color(0xFFBBDEFB);
      textColor = cell.isFixed ? const Color(0xFF424242) : const Color(0xFF2979FF);
    } else if (isSameRow || isSameCol || isSameBlock) {
      backgroundColor = const Color(0xFFE3F2FD);
      textColor = cell.isFixed ? const Color(0xFF424242) : const Color(0xFF2979FF);
    }
    // ⭐ HIGHLIGHT SIMILAIRES si activé
    else if (_settings.highlightSimilar &&
        highlightedNumber != null &&
        cell.value == highlightedNumber &&
        cell.value != 0) {
      backgroundColor = Colors.blue.shade100;
      textColor = Colors.blue.shade900;
    } else {
      textColor = cell.isFixed ? const Color(0xFF424242) : const Color(0xFF2979FF);
    }

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: BorderSide(
              color: col % 3 == 2 ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
              width: col % 3 == 2 ? 2 : 0.5,
            ),
            bottom: BorderSide(
              color: row % 3 == 2 ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
              width: row % 3 == 2 ? 2 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: cell.value != 0
              ? Text(
            '${cell.value}',
            style: TextStyle(
              fontSize: 24,
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
      children: List.generate(9, (index) {
        int num = index + 1;
        return Center(
          child: notes.contains(num)
              ? Text(
            '$num',
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF616161),
            ),
          )
              : const SizedBox(),
        );
      }),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: isActive ? const Color(0xFF2979FF) : const Color(0xFF9E9E9E),
          iconSize: 28,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF2979FF) : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2979FF), width: 1),
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2979FF),
            ),
          ),
        ),
      ),
    );
  }
}

