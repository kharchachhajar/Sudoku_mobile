// ============================================
// screens/profile_screen.dart - VERSION CORRIGÉE
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../models/statistics.dart';
import '../utils/constants.dart';

class ProfileStatsScreen extends StatefulWidget {
  const ProfileStatsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen> {
  Difficulty _selectedDifficulty = Difficulty.moyen;

  @override
  void initState() {
    super.initState();
    // ⭐ Forcer le rechargement des données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false);
      Provider.of<GameProvider>(context, listen: false);
    });
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return '--:--';
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final stats = gameProvider.statistics;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, userProvider),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistiques',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildDifficultySelector(),
                        const SizedBox(height: 20),

                        _buildStatsForDifficulty(stats),
                        const SizedBox(height: 24),

                        // ⭐ RÉSUMÉ GLOBAL SUPPRIMÉ

                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () => _showResetDialog(context, gameProvider),
                            icon: const Icon(Icons.refresh, color: AppConstants.errorColor),
                            label: const Text(
                              'Réinitialiser les statistiques',
                              style: TextStyle(color: AppConstants.errorColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppConstants.errorColor),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              _buildBottomNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // ⭐ Avatar cliquable pour changer
          GestureDetector(
            onTap: () => _showAvatarPicker(context, userProvider),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userProvider.avatar,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.isLoggedIn ? userProvider.username : 'Invité',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // ⭐ Pays cliquable
                GestureDetector(
                  onTap: () => _showCountryPicker(context, userProvider),
                  child: Row(
                    children: [
                      Text(
                        userProvider.country,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 14, color: Colors.white70),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFB300), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Niveau ${userProvider.level}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => _showEditDialog(context, userProvider),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: [
        _buildDifficultyChip('Facile', Difficulty.facile, const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        _buildDifficultyChip('Moyen', Difficulty.moyen, const Color(0xFFFF9800)),
        const SizedBox(width: 8),
        _buildDifficultyChip('Difficile', Difficulty.difficile, const Color(0xFFE53935)),
      ],
    );
  }

  Widget _buildDifficultyChip(String label, Difficulty difficulty, Color color) {
    final isSelected = _selectedDifficulty == difficulty;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsForDifficulty(Statistics stats) {
    int bestTime = 0;
    int bestScore = 0;
    int gamesPlayed = 0;
    int gamesWon = 0;

    // ⭐ Obtenir les statistiques pour la difficulté sélectionnée
    switch (_selectedDifficulty) {
      case Difficulty.facile:
        bestTime = stats.bestTimeFacile;
        bestScore = stats.bestScoreFacile;
        gamesPlayed = stats.gamesPlayedFacile;
        gamesWon = stats.gamesWonFacile;
        break;
      case Difficulty.moyen:
        bestTime = stats.bestTimeMoyen;
        bestScore = stats.bestScoreMoyen;
        gamesPlayed = stats.gamesPlayedMoyen;
        gamesWon = stats.gamesWonMoyen;
        break;
      case Difficulty.difficile:
        bestTime = stats.bestTimeDifficile;
        bestScore = stats.bestScoreDifficile;
        gamesPlayed = stats.gamesPlayedDifficile;
        gamesWon = stats.gamesWonDifficile;
        break;
    }

    // ⭐ Calculer le ratio de victoire pour cette difficulté
    double winRate = gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

    // ⭐ Calculer le temps moyen pour cette difficulté
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    int totalTime = 0;
    int wonCount = 0;
    for (var game in gameProvider.gameHistory) {
      if (game.difficulty == _selectedDifficulty && game.won) {
        totalTime += game.timeSeconds;
        wonCount++;
      }
    }
    int averageTime = wonCount > 0 ? totalTime ~/ wonCount : 0;

    return Column(
      children: [
        _buildStatRow('Parties commencées :', '$gamesPlayed'),
        const SizedBox(height: 12),
        _buildStatRow('Parties gagnées :', '$gamesWon'),
        const SizedBox(height: 12),
        _buildStatRow('Ratio de victoire :', '${winRate.toStringAsFixed(1)}%'),
        const SizedBox(height: 12),
        _buildStatRow('Meilleur temps :', _formatTime(bestTime)),
        const SizedBox(height: 12),
        _buildStatRow('Temps moyen :', _formatTime(averageTime)),
        const SizedBox(height: 12),
        _buildStatRow('Série actuelle :', '${stats.currentStreak}'),
        const SizedBox(height: 12),
        _buildStatRow('Meilleure série :', '${stats.bestStreak}'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Principal', false, () {
            Navigator.pushReplacementNamed(context, '/');
          }),
          _buildNavItem(Icons.bar_chart, 'Statistiques', true, null),
          _buildNavItem(Icons.settings, 'Paramètres', false, () {
            Navigator.pushNamed(context, '/settings');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppConstants.primaryColor : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppConstants.primaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ DIALOGUE POUR ÉDITER LE NOM - SAUVEGARDE AUTOMATIQUE
  void _showEditDialog(BuildContext context, UserProvider userProvider) {
    // ⭐ Si c'est "Invité", commencer avec un champ vide
    final isGuest = userProvider.username == 'Invité';
    final TextEditingController nameController =
    TextEditingController(text: isGuest ? '' : userProvider.username);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isGuest ? 'Créer votre profil' : 'Modifier le nom'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Nom d'utilisateur",
              border: OutlineInputBorder(),
              hintText: 'Entrez votre nom',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty && name != 'Invité') {
                  // ⭐ Utiliser createProfile si c'est un invité
                  if (isGuest) {
                    await userProvider.createProfile(name);
                  } else {
                    await userProvider.updateProfile(name);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bienvenue, $name ✓')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez entrer un nom valide'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // ⭐ SÉLECTEUR D'AVATAR - SAUVEGARDE AUTOMATIQUE
  void _showAvatarPicker(BuildContext context, UserProvider userProvider) {
    final avatars = ['😀', '😎', '🤓', '😇', '🥳', '🤩', '😺', '🦊', '🐼', '🦁', '🐯', '🦄'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir un avatar'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    userProvider.selectAvatar(avatars[index]);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avatar modifié ✓')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        avatars[index],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ⭐ SÉLECTEUR DE PAYS - SAUVEGARDE AUTOMATIQUE
  void _showCountryPicker(BuildContext context, UserProvider userProvider) {
    final countries = ['Maroc', 'France', 'Algérie', 'Tunisie', 'Espagne', 'Canada', 'USA'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir un pays'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(countries[index]),
                  trailing: userProvider.country == countries[index]
                      ? const Icon(Icons.check, color: AppConstants.primaryColor)
                      : null,
                  onTap: () async {
                    await userProvider.updateCountry(countries[index]);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pays modifié ✓')),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, GameProvider gameProvider) {
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
              gameProvider.resetStatistics();
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