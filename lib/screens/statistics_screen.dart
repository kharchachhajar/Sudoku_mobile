import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/best_time_card.dart';
import '../widgets/achievement_tile.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  String _formatTime(int seconds) {
    if (seconds == 0) return '--:--';
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(context),
          ),
        ],
      ),
      body: Consumer2<GameProvider, UserProvider>(
        builder: (context, gameProvider, userProvider, child) {
          final stats = gameProvider.statistics;
          final username = userProvider.username;
          final country = userProvider.country;
          final level = userProvider.level;
          final avatar = userProvider.avatar;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // -------------------
                // Profil utilisateur
                // -------------------
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text(avatar, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, $username!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$country • Niveau $level',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // -------------------
                // Meilleurs temps
                // -------------------
                const Text(
                  'Meilleurs temps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                BestTimeCard(
                  difficulty: 'Facile',
                  time: _formatTime(stats.bestTimeFacile),
                  score: stats.bestScoreFacile,
                  color: AppConstants.facileDifficultyColor,
                ),
                const SizedBox(height: 8),
                BestTimeCard(
                  difficulty: 'Moyen',
                  time: _formatTime(stats.bestTimeMoyen),
                  score: stats.bestScoreMoyen,
                  color: AppConstants.moyenDifficultyColor,
                ),
                const SizedBox(height: 8),
                BestTimeCard(
                  difficulty: 'Difficile',
                  time: _formatTime(stats.bestTimeDifficile),
                  score: stats.bestScoreDifficile,
                  color: AppConstants.difficileDifficultyColor,
                ),
                const SizedBox(height: 24),

                // -------------------
                // Achievements
                // -------------------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Succès',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AchievementTile(
                          title: 'Première victoire',
                          achieved: stats.gamesWon >= 1,
                          description: 'Gagner votre première partie',
                        ),
                        AchievementTile(
                          title: 'Série de 5',
                          achieved: stats.bestStreak >= 5,
                          description: 'Gagner 5 parties d\'affilée',
                        ),
                        AchievementTile(
                          title: 'Expert',
                          achieved: stats.gamesWon >= 50,
                          description: 'Gagner 50 parties',
                        ),
                        AchievementTile(
                          title: 'Maître',
                          achieved: stats.gamesWon >= 100,
                          description: 'Gagner 100 parties',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les statistiques'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser toutes vos statistiques ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GameProvider>(context, listen: false).resetStatistics();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statistiques réinitialisées')),
              );
            },
            child: const Text(
              'Réinitialiser',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
