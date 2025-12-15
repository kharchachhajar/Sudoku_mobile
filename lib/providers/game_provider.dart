// ============================================
// providers/game_provider.dart - VERSION CORRIGÉE
// ============================================

import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/cell_model.dart';
import '../models/statistics.dart';
import '../models/user_history.dart';
import '../services/sudoku_generator.dart';
import '../services/storage_service.dart';
import '../services/sudoku_solver.dart';
import 'user_provider.dart';

class GameProvider extends ChangeNotifier {
  GameState? _gameState;
  Statistics _statistics = Statistics();
  final List<GameState> _undoStack = [];
  List<GameHistory> _gameHistory = [];

  int? highlightNumber;

  final UserProvider userProvider;

  GameState? get gameState => _gameState;
  Statistics get statistics => _statistics;
  List<GameHistory> get gameHistory => _gameHistory;
  bool get canUndo => _undoStack.isNotEmpty;

  GameProvider({required this.userProvider}) {
    _loadStatistics();
    _loadGameHistory();
  }

  Future<void> _loadStatistics() async {
    final stats = await StorageService.loadStatistics();
    if (stats != null) {
      _statistics = stats;
      notifyListeners();
    }
  }

  Future<void> _loadGameHistory() async {
    _gameHistory = await StorageService.loadGameHistory();
    notifyListeners();
  }

  Future<void> _saveStatistics() async {
    await StorageService.saveStatistics(_statistics);
    notifyListeners(); // ⭐ Notifier après sauvegarde
  }

  // =============================
  //  DÉMARRER UNE NOUVELLE PARTIE
  // =============================
  void startNewGame(Difficulty difficulty) {
    _gameState = SudokuGenerator.generatePuzzle(difficulty);
    _undoStack.clear();
    highlightNumber = null;
    notifyListeners();

    StorageService.clearSavedGame();
    _saveGame();
  }

  Future<void> loadSavedGame() async {
    final savedGame = await StorageService.loadGame();
    if (savedGame != null) {
      _gameState = savedGame;
      _undoStack.clear();
      highlightNumber = null;
      notifyListeners();
    }
  }

  Future<void> _saveGame() async {
    if (_gameState != null) {
      await StorageService.saveGame(_gameState!);
    }
  }

  // =============================
  //  FIN DE PARTIE - ⭐ MÉTHODE PUBLIQUE
  // =============================
  Future<void> completeGame({
    required Difficulty difficulty,
    required int timeSeconds,
    required bool won,
  }) async {
    // ⭐ 1. Créer l'historique
    final history = GameHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      difficulty: difficulty,
      timeSeconds: timeSeconds,
      score: won ? SudokuGenerator.calculateScore(difficulty, timeSeconds) : 0,
      won: won,
      completedAt: DateTime.now(),
    );

    // ⭐ 2. Sauvegarder l'historique
    await StorageService.saveGameHistory(history);
    _gameHistory.insert(0, history);

    // ⭐ 3. Mettre à jour les statistiques GLOBALES et PAR DIFFICULTÉ
    if (won) {
      Statistics newStats = _statistics.copyWith(
        gamesPlayed: _statistics.gamesPlayed + 1,
        gamesWon: _statistics.gamesWon + 1,
        totalTime: _statistics.totalTime + timeSeconds,
        currentStreak: _statistics.currentStreak + 1,
        bestStreak: (_statistics.currentStreak + 1 > _statistics.bestStreak)
            ? _statistics.currentStreak + 1
            : _statistics.bestStreak,
      );

      // ⭐ Mettre à jour selon la difficulté
      switch (difficulty) {
        case Difficulty.facile:
          int currentBestTime = _statistics.bestTimeFacile;
          int currentBestScore = _statistics.bestScoreFacile;
          bool isNewBestTime = currentBestTime == 0 || timeSeconds < currentBestTime;
          bool isNewBestScore = history.score > currentBestScore;

          newStats = newStats.copyWith(
            gamesPlayedFacile: _statistics.gamesPlayedFacile + 1,
            gamesWonFacile: _statistics.gamesWonFacile + 1,
            bestTimeFacile: isNewBestTime ? timeSeconds : currentBestTime,
            bestScoreFacile: isNewBestScore ? history.score : currentBestScore,
          );
          break;

        case Difficulty.moyen:
          int currentBestTime = _statistics.bestTimeMoyen;
          int currentBestScore = _statistics.bestScoreMoyen;
          bool isNewBestTime = currentBestTime == 0 || timeSeconds < currentBestTime;
          bool isNewBestScore = history.score > currentBestScore;

          newStats = newStats.copyWith(
            gamesPlayedMoyen: _statistics.gamesPlayedMoyen + 1,
            gamesWonMoyen: _statistics.gamesWonMoyen + 1,
            bestTimeMoyen: isNewBestTime ? timeSeconds : currentBestTime,
            bestScoreMoyen: isNewBestScore ? history.score : currentBestScore,
          );
          break;

        case Difficulty.difficile:
          int currentBestTime = _statistics.bestTimeDifficile;
          int currentBestScore = _statistics.bestScoreDifficile;
          bool isNewBestTime = currentBestTime == 0 || timeSeconds < currentBestTime;
          bool isNewBestScore = history.score > currentBestScore;

          newStats = newStats.copyWith(
            gamesPlayedDifficile: _statistics.gamesPlayedDifficile + 1,
            gamesWonDifficile: _statistics.gamesWonDifficile + 1,
            bestTimeDifficile: isNewBestTime ? timeSeconds : currentBestTime,
            bestScoreDifficile: isNewBestScore ? history.score : currentBestScore,
          );
          break;
      }

      _statistics = newStats;

      // ⭐ 4. Sauvegarder le meilleur score
      await StorageService.saveBestScore(difficulty, history.score, timeSeconds);

      // ⭐ 5. Augmenter le niveau
      await userProvider.increaseLevel();

    } else {
      // ⭐ Partie perdue - Incrémenter selon la difficulté aussi
      Statistics newStats = _statistics.copyWith(
        gamesPlayed: _statistics.gamesPlayed + 1,
        gamesLost: _statistics.gamesLost + 1,
        currentStreak: 0,
      );

      switch (difficulty) {
        case Difficulty.facile:
          newStats = newStats.copyWith(
            gamesPlayedFacile: _statistics.gamesPlayedFacile + 1,
          );
          break;
        case Difficulty.moyen:
          newStats = newStats.copyWith(
            gamesPlayedMoyen: _statistics.gamesPlayedMoyen + 1,
          );
          break;
        case Difficulty.difficile:
          newStats = newStats.copyWith(
            gamesPlayedDifficile: _statistics.gamesPlayedDifficile + 1,
          );
          break;
      }

      _statistics = newStats;
    }

    // ⭐ 6. Sauvegarder et notifier
    await _saveStatistics();
    notifyListeners();
  }

  // =============================
  //  FIN DE PARTIE - ⭐ MÉTHODE INTERNE (OPTIONNELLE)
  // =============================
  Future<void> _endGame(bool won) async {
    if (_gameState == null) return;

    await completeGame(
      difficulty: _gameState!.difficulty,
      timeSeconds: _gameState!.elapsedSeconds,
      won: won,
    );
  }

  Future<void> resetStatistics() async {
    _statistics = Statistics();
    await _saveStatistics();
  }

  GameState _cloneGameState(GameState state) {
    return state.copyWith(
      grid: state.grid.map((r) => r.map((c) => c.copyWith()).toList()).toList(),
    );
  }

  // =============================
  //  SÉLECTIONNER UNE CELLULE
  // =============================
  void selectCell(int row, int col) {
    if (_gameState == null) return;

    final cell = _gameState!.grid[row][col];

    if (cell.isFixed && cell.value != 0) {
      highlightNumber = cell.value;
    } else {
      highlightNumber = null;
    }

    _gameState = _gameState!.copyWith(
      selectedRow: row,
      selectedCol: col,
    );

    notifyListeners();
  }

  // =============================
  //  ENTRER UN NUMÉRO
  // =============================
  void enterNumber(int number) {
    if (_gameState == null ||
        _gameState!.selectedRow == null ||
        _gameState!.selectedCol == null) {
      return;
    }

    final row = _gameState!.selectedRow!;
    final col = _gameState!.selectedCol!;
    final cell = _gameState!.grid[row][col];

    if (cell.isFixed) return;

    // Sauvegarder l'état pour undo
    _undoStack.add(_cloneGameState(_gameState!));

    List<List<CellModel>> newGrid = _gameState!.grid
        .map((r) => r.map((c) => c).toList())
        .toList();

    if (_gameState!.isNotesMode) {
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
      if (newValue != 0 && newValue != cell.solution) {
        int newErrors = _gameState!.errors + 1;
        newGrid[row][col] = newGrid[row][col].copyWith(isError: true);
        _gameState = _gameState!.copyWith(errors: newErrors);

        if (newErrors >= 5) {
          _endGame(false);
          return;
        }
      } else {
        newGrid[row][col] = newGrid[row][col].copyWith(isError: false);
      }
    }

    _gameState = _gameState!.copyWith(grid: newGrid);

    // Vérifier si le jeu est terminé
    if (_gameState!.isComplete) {
      _endGame(true);
    } else {
      _saveGame();
    }

    notifyListeners();
  }

  // =============================
  //  EFFACER UNE CELLULE
  // =============================
  void eraseCell() {
    if (_gameState == null ||
        _gameState!.selectedRow == null ||
        _gameState!.selectedCol == null) {
      return;
    }

    final row = _gameState!.selectedRow!;
    final col = _gameState!.selectedCol!;
    final cell = _gameState!.grid[row][col];

    if (cell.isFixed) return;

    _undoStack.add(_cloneGameState(_gameState!));

    List<List<CellModel>> newGrid = _gameState!.grid
        .map((r) => r.map((c) => c).toList())
        .toList();

    newGrid[row][col] = cell.copyWith(value: 0, notes: [], isError: false);
    _gameState = _gameState!.copyWith(grid: newGrid);

    _saveGame();
    notifyListeners();
  }

  // =============================
  //  ANNULER
  // =============================
  void undo() {
    if (_undoStack.isEmpty) return;

    _gameState = _undoStack.removeLast();
    _saveGame();
    notifyListeners();
  }

  // =============================
  //  BASCULER MODE NOTES
  // =============================
  void toggleNotesMode() {
    if (_gameState == null) return;

    _gameState = _gameState!.copyWith(isNotesMode: !_gameState!.isNotesMode);
    notifyListeners();
  }

  // =============================
  //  VÉRIFIER LA GRILLE
  // =============================
  void checkGrid() {
    if (_gameState == null) return;

    List<List<CellModel>> checkedGrid = SudokuSolver.checkGrid(_gameState!.grid);
    _gameState = _gameState!.copyWith(grid: checkedGrid);
    notifyListeners();
  }

  // =============================
  //  METTRE À JOUR LE TEMPS
  // =============================
  void updateTime() {
    if (_gameState == null || _gameState!.isGameOver) return;

    _gameState = _gameState!.copyWith(
      elapsedSeconds: _gameState!.elapsedSeconds + 1,
    );

    _saveGame();
    notifyListeners();
  }
}