// ============================================
// services/storage_service.dart - VERSION DEBUG
// ============================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/statistics.dart';
import '../models/user_history.dart';

class StorageService {
  static const String _savedGameKey = 'saved_game';
  static const String _bestScoresKey = 'best_scores';
  static const String _statisticsKey = 'statistics';
  static const String _settingsKey = 'settings';
  static const String _gameHistoryKey = 'game_history';

  // =========================================================
  // HISTORIQUE DES PARTIES
  // =========================================================
  static Future<void> saveGameHistory(GameHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_gameHistoryKey);

      List<dynamic> historyList = [];
      if (historyJson != null) {
        try {
          historyList = jsonDecode(historyJson);
        } catch (e) {
          debugPrint('❌ Erreur decode history: $e');
        }
      }

      historyList.insert(0, history.toJson());

      if (historyList.length > 50) {
        historyList = historyList.sublist(0, 50);
      }

      await prefs.setString(_gameHistoryKey, jsonEncode(historyList));
      debugPrint('✅ Historique sauvegardé: ${history.difficulty} - ${history.won ? "Gagné" : "Perdu"}');
    } catch (e) {
      debugPrint('❌ ERREUR saveGameHistory: $e');
    }
  }

  static Future<List<GameHistory>> loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_gameHistoryKey);

    if (historyJson == null) {
      debugPrint('⚠️ Aucun historique trouvé');
      return [];
    }

    try {
      final List<dynamic> historyList = jsonDecode(historyJson);
      debugPrint('✅ Historique chargé: ${historyList.length} parties');
      return historyList.map((json) => GameHistory.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Erreur loadGameHistory: $e');
      return [];
    }
  }

  static Future<void> clearGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameHistoryKey);
    debugPrint('✅ Historique effacé');
  }

  // =========================================================
  // 1) PARTIE
  // =========================================================
  static Future<void> saveGame(GameState gameState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(gameState.toJson());
      await prefs.setString(_savedGameKey, jsonString);
      debugPrint('✅ Partie sauvegardée');
    } catch (e) {
      debugPrint('❌ Erreur saveGame: $e');
    }
  }

  static Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedGameKey);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString);
      debugPrint('✅ Partie chargée');
      return GameState.fromJson(json);
    } catch (e) {
      debugPrint('❌ Erreur loadGame: $e');
      return null;
    }
  }

  static Future<void> clearSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedGameKey);
    debugPrint('✅ Partie effacée');
  }

  static Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_savedGameKey);
  }

  // =========================================================
  // 2) STATISTIQUES - ⭐ VERSION CORRIGÉE
  // =========================================================
  static Future<void> saveStatistics(Statistics stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(stats.toJson());
      await prefs.setString(_statisticsKey, json);

      debugPrint('✅ STATS SAUVEGARDÉES:');
      debugPrint('   - Parties jouées: ${stats.gamesPlayed}');
      debugPrint('   - Parties gagnées: ${stats.gamesWon}');
      debugPrint('   - Meilleur temps Facile: ${stats.bestTimeFacile}s');
      debugPrint('   - Meilleur temps Moyen: ${stats.bestTimeMoyen}s');
      debugPrint('   - Meilleur temps Difficile: ${stats.bestTimeDifficile}s');
    } catch (e) {
      debugPrint('❌ ERREUR saveStatistics: $e');
    }
  }

  static Future<Statistics?> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_statisticsKey);

      if (jsonString == null) {
        debugPrint('⚠️ Aucune statistique trouvée');
        return null;
      }

      final json = jsonDecode(jsonString);
      final stats = Statistics.fromJson(json);

      debugPrint('✅ STATS CHARGÉES:');
      debugPrint('   - Parties jouées: ${stats.gamesPlayed}');
      debugPrint('   - Parties gagnées: ${stats.gamesWon}');

      return stats;
    } catch (e) {
      debugPrint('❌ Erreur loadStatistics: $e');
      return null;
    }
  }

  // =========================================================
  // 3) PARAMÈTRES (Settings)
  // =========================================================
  static Future<Map<String, dynamic>?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('autoCheckErrors')) return null;

    return {
      'autoCheckErrors': prefs.getBool('autoCheckErrors') ?? true,
      'highlightSimilar': prefs.getBool('highlightSimilar') ?? true,
      'showTimer': prefs.getBool('showTimer') ?? true,
      'soundEnabled': prefs.getBool('soundEnabled') ?? false,
      'vibrateEnabled': prefs.getBool('vibrateEnabled') ?? true,
      'isDarkMode': prefs.getBool('isDarkMode') ?? false,
    };
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('autoCheckErrors', settings['autoCheckErrors']);
    await prefs.setBool('highlightSimilar', settings['highlightSimilar']);
    await prefs.setBool('showTimer', settings['showTimer']);
    await prefs.setBool('soundEnabled', settings['soundEnabled']);
    await prefs.setBool('vibrateEnabled', settings['vibrateEnabled']);
    await prefs.setBool('isDarkMode', settings['isDarkMode'] ?? false);

    debugPrint('✅ Paramètres sauvegardés');
  }

  // =========================================================
  // 4) MEILLEURS SCORES
  // =========================================================
  static Future<void> saveBestScore(
      Difficulty difficulty, int score, int time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresJson = prefs.getString(_bestScoresKey);

      Map<String, dynamic> scores = {};

      if (scoresJson != null) {
        try {
          scores = jsonDecode(scoresJson);
        } catch (_) {
          scores = {};
        }
      }

      final key = difficulty.toString();

      if (!scores.containsKey(key) || scores[key]['score'] < score) {
        scores[key] = {
          'score': score,
          'time': time,
        };
        await prefs.setString(_bestScoresKey, jsonEncode(scores));
        debugPrint('✅ Meilleur score sauvegardé: $difficulty - $score points');
      }
    } catch (e) {
      debugPrint('❌ Erreur saveBestScore: $e');
    }
  }

  static Future<Map<String, int>?> getBestScore(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = prefs.getString(_bestScoresKey);

    if (scoresJson == null) return null;

    try {
      final scores = jsonDecode(scoresJson);
      final key = difficulty.toString();

      if (scores.containsKey(key)) {
        return {
          'score': scores[key]['score'],
          'time': scores[key]['time'],
        };
      }
    } catch (e) {
      debugPrint('❌ Erreur getBestScore: $e');
      return null;
    }

    return null;
  }

  // =========================================================
  // 5) PROFIL UTILISATEUR
  // =========================================================

  static Future<void> saveUserProfile(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('username', data['username'] ?? '');
      await prefs.setString('avatar', data['avatar'] ?? '😀');
      await prefs.setString('country', data['country'] ?? 'Maroc');
      await prefs.setInt('level', data['level'] ?? 0);
      await prefs.setBool('isLoggedIn', data['isLoggedIn'] ?? false);

      if (data['createdAt'] != null) {
        await prefs.setString('createdAt', data['createdAt']);
      }

      debugPrint('✅ Profil sauvegardé: ${data['username']} - Niveau ${data['level']}');
    } catch (e) {
      debugPrint('❌ Erreur saveUserProfile: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey('username')) {
        debugPrint('⚠️ Aucun profil trouvé');
        return null;
      }

      final profile = {
        'username': prefs.getString('username'),
        'avatar': prefs.getString('avatar'),
        'country': prefs.getString('country'),
        'level': prefs.getInt('level'),
        'isLoggedIn': prefs.getBool('isLoggedIn'),
        'createdAt': prefs.getString('createdAt'),
      };

      debugPrint('✅ Profil chargé: ${profile['username']}');
      return profile;
    } catch (e) {
      debugPrint('❌ Erreur loadUserProfile: $e');
      return null;
    }
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('username');
    await prefs.remove('avatar');
    await prefs.remove('country');
    await prefs.remove('level');
    await prefs.remove('isLoggedIn');
    await prefs.remove('createdAt');

    debugPrint('✅ Profil effacé');
  }
}