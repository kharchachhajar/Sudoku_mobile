// ============================================
// utils/constants.dart - COMPLET + CORRIGÉ
// ============================================

import 'package:flutter/material.dart';

class AppConstants {
  // ⭐ Correction
  static const int maxErrors = 5;

  // Couleurs principales
  static const Color primaryColor = Color(0xFF2979FF);
  static const Color errorColor = Color(0xFFE53935);
  static const Color timerColor = Color(0xFF1565C0);
  static const Color borderColor = Colors.grey;
  static const Color thickBorderColor = Colors.black;

  // --- COULEURS MANQUANTES POUR SudokuGrid ---
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color fixedCellColor = Colors.black;
  static const Color editableCellColor = Colors.blue;
  static const Color errorCellColor = Color(0xFFFFC8C8);
  static const Color selectedCellColor = Color(0xFFBEE3F8);
  static const Color highlightCellColor = Color(0xFFE2E8F0);
  static const Color noteColor = Colors.grey;

  // Couleurs difficulté
  static const Color facileDifficultyColor = Color(0xFF4CAF50);
  static const Color moyenDifficultyColor = Color(0xFFFF9800);
  static const Color difficileDifficultyColor = Color(0xFFE53935);

  // Dimensions
  static const double gridBorderWidth = 2.0;
  static const double cellBorderWidth = 0.5;
  static const double blockBorderWidth = 2.0;
  static const double cellPadding = 4.0;

  // Tailles de police
  static const double cellValueFontSize = 24.0;
  static const double noteFontSize = 8.0;
  static const double headerFontSize = 20.0;
  static const double titleFontSize = 48.0;

  // Limites du jeu
  static const int gridSize = 9;
  static const int blockSize = 3;

  // Cellules à retirer
  static const int facileMinCells = 35;
  static const int facileMaxCells = 40;
  static const int moyenMinCells = 45;
  static const int moyenMaxCells = 50;
  static const int difficileMinCells = 52;
  static const int difficileMaxCells = 57;

  // Scores
  static const int facileBaseScore = 1000;
  static const int moyenBaseScore = 2500;
  static const int difficileBaseScore = 5000;
  static const int maxTimeBonus = 3000;

  // Stockage
  static const String savedGameKey = 'saved_game';
  static const String statisticsKey = 'statistics';
  static const String settingsKey = 'settings';
  static const String bestScoresKey = 'best_scores';

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration timerDuration = Duration(seconds: 1);

  // Messages
  static const String noErrorsMessage = 'Aucune erreur ! Continuez !';
  static const String errorsFoundMessage = 'erreur(s) trouvée(s)';
  static const String gameWonTitle = 'Félicitations !';
  static const String gameWonMessage = 'Vous avez réussi !';
  static const String gameLostTitle = 'Partie terminée';
  static const String gameLostMessage = 'Vous avez fait 5 erreurs';

  // Paramètres par défaut
  static const bool defaultAutoCheckErrors = true;
  static const bool defaultHighlightSimilar = true;
  static const bool defaultShowTimer = true;
  static const bool defaultSoundEnabled = false;
  static const bool defaultVibrateEnabled = true;
}

class AppStrings {
  static const String appTitle = 'Sudoku';
  static const String newGame = 'Nouvelle partie';
  static const String resumeGame = 'Reprendre la partie';
  static const String difficulty = 'Difficulté';
  static const String facile = 'Facile';
  static const String moyen = 'Moyen';
  static const String difficile = 'Difficile';
  static const String errors = 'Erreurs';
  static const String time = 'Temps';
  static const String cancel = 'Annuler';
  static const String undo = 'Annuler';
  static const String erase = 'Effacer';
  static const String notes = 'Notes';
  static const String hint = 'Indice';
  static const String check = 'Vérifier';
  static const String settings = 'Paramètres';
  static const String statistics = 'Statistiques';
  static const String home = 'Accueil';
  static const String profile = 'Moi';
  static const String play = 'Jouer';
  static const String chooseDifficulty = 'Choisir la difficulté';
  static const String start = 'Commencer';
  static const String congratulations = 'Félicitations !';
  static const String youWon = 'Vous avez réussi !';
  static const String gameOver = 'Partie terminée';
  static const String fiveErrors = 'Vous avez fait 5 erreurs';
  static const String score = 'Score';
  static const String newBestScore = 'Nouveau meilleur score depuis le début';
  static const String newRecord = 'Vous avez établi un nouveau record de temps';
}
