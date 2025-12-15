// ============================================
// models/statistics.dart - VERSION CORRIGÉE
// ============================================

class Statistics {
  // Statistiques globales
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int totalTime;
  final int currentStreak;
  final int bestStreak;

  // ⭐ Statistiques par difficulté - FACILE
  final int gamesPlayedFacile;
  final int gamesWonFacile;
  final int bestTimeFacile;
  final int bestScoreFacile;

  // ⭐ Statistiques par difficulté - MOYEN
  final int gamesPlayedMoyen;
  final int gamesWonMoyen;
  final int bestTimeMoyen;
  final int bestScoreMoyen;

  // ⭐ Statistiques par difficulté - DIFFICILE
  final int gamesPlayedDifficile;
  final int gamesWonDifficile;
  final int bestTimeDifficile;
  final int bestScoreDifficile;

  Statistics({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.totalTime = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    // Facile
    this.gamesPlayedFacile = 0,
    this.gamesWonFacile = 0,
    this.bestTimeFacile = 0,
    this.bestScoreFacile = 0,
    // Moyen
    this.gamesPlayedMoyen = 0,
    this.gamesWonMoyen = 0,
    this.bestTimeMoyen = 0,
    this.bestScoreMoyen = 0,
    // Difficile
    this.gamesPlayedDifficile = 0,
    this.gamesWonDifficile = 0,
    this.bestTimeDifficile = 0,
    this.bestScoreDifficile = 0,
  });

  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return (gamesWon / gamesPlayed) * 100;
  }

  int get averageTime {
    if (gamesWon == 0) return 0;
    return totalTime ~/ gamesWon;
  }

  // ⭐ Méthodes pour obtenir les stats par difficulté
  double getWinRateForDifficulty(String difficulty) {
    int played = 0;
    int won = 0;

    switch (difficulty) {
      case 'facile':
        played = gamesPlayedFacile;
        won = gamesWonFacile;
        break;
      case 'moyen':
        played = gamesPlayedMoyen;
        won = gamesWonMoyen;
        break;
      case 'difficile':
        played = gamesPlayedDifficile;
        won = gamesWonDifficile;
        break;
    }

    if (played == 0) return 0.0;
    return (won / played) * 100;
  }

  Statistics copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? totalTime,
    int? currentStreak,
    int? bestStreak,
    // Facile
    int? gamesPlayedFacile,
    int? gamesWonFacile,
    int? bestTimeFacile,
    int? bestScoreFacile,
    // Moyen
    int? gamesPlayedMoyen,
    int? gamesWonMoyen,
    int? bestTimeMoyen,
    int? bestScoreMoyen,
    // Difficile
    int? gamesPlayedDifficile,
    int? gamesWonDifficile,
    int? bestTimeDifficile,
    int? bestScoreDifficile,
  }) {
    return Statistics(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      totalTime: totalTime ?? this.totalTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      // Facile
      gamesPlayedFacile: gamesPlayedFacile ?? this.gamesPlayedFacile,
      gamesWonFacile: gamesWonFacile ?? this.gamesWonFacile,
      bestTimeFacile: bestTimeFacile ?? this.bestTimeFacile,
      bestScoreFacile: bestScoreFacile ?? this.bestScoreFacile,
      // Moyen
      gamesPlayedMoyen: gamesPlayedMoyen ?? this.gamesPlayedMoyen,
      gamesWonMoyen: gamesWonMoyen ?? this.gamesWonMoyen,
      bestTimeMoyen: bestTimeMoyen ?? this.bestTimeMoyen,
      bestScoreMoyen: bestScoreMoyen ?? this.bestScoreMoyen,
      // Difficile
      gamesPlayedDifficile: gamesPlayedDifficile ?? this.gamesPlayedDifficile,
      gamesWonDifficile: gamesWonDifficile ?? this.gamesWonDifficile,
      bestTimeDifficile: bestTimeDifficile ?? this.bestTimeDifficile,
      bestScoreDifficile: bestScoreDifficile ?? this.bestScoreDifficile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'totalTime': totalTime,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      // Facile
      'gamesPlayedFacile': gamesPlayedFacile,
      'gamesWonFacile': gamesWonFacile,
      'bestTimeFacile': bestTimeFacile,
      'bestScoreFacile': bestScoreFacile,
      // Moyen
      'gamesPlayedMoyen': gamesPlayedMoyen,
      'gamesWonMoyen': gamesWonMoyen,
      'bestTimeMoyen': bestTimeMoyen,
      'bestScoreMoyen': bestScoreMoyen,
      // Difficile
      'gamesPlayedDifficile': gamesPlayedDifficile,
      'gamesWonDifficile': gamesWonDifficile,
      'bestTimeDifficile': bestTimeDifficile,
      'bestScoreDifficile': bestScoreDifficile,
    };
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      gamesLost: json['gamesLost'] ?? 0,
      totalTime: json['totalTime'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      // Facile
      gamesPlayedFacile: json['gamesPlayedFacile'] ?? 0,
      gamesWonFacile: json['gamesWonFacile'] ?? 0,
      bestTimeFacile: json['bestTimeFacile'] ?? 0,
      bestScoreFacile: json['bestScoreFacile'] ?? 0,
      // Moyen
      gamesPlayedMoyen: json['gamesPlayedMoyen'] ?? 0,
      gamesWonMoyen: json['gamesWonMoyen'] ?? 0,
      bestTimeMoyen: json['bestTimeMoyen'] ?? 0,
      bestScoreMoyen: json['bestScoreMoyen'] ?? 0,
      // Difficile
      gamesPlayedDifficile: json['gamesPlayedDifficile'] ?? 0,
      gamesWonDifficile: json['gamesWonDifficile'] ?? 0,
      bestTimeDifficile: json['bestTimeDifficile'] ?? 0,
      bestScoreDifficile: json['bestScoreDifficile'] ?? 0,
    );
  }
}