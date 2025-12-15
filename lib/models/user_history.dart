// ============================================
// models/user_history.dart -
// ============================================

import 'game_state.dart';

class GameHistory {
  final String id;
  final Difficulty difficulty;
  final int timeSeconds;
  final int score;
  final bool won;
  final DateTime completedAt;

  GameHistory({
    required this.id,
    required this.difficulty,
    required this.timeSeconds,
    required this.score,
    required this.won,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'difficulty': difficulty.index,
      'timeSeconds': timeSeconds,
      'score': score,
      'won': won,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      id: json['id'],
      difficulty: Difficulty.values[json['difficulty']],
      timeSeconds: json['timeSeconds'],
      score: json['score'],
      won: json['won'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}