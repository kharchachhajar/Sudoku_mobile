// ============================================
// screens/home_screen.dart
// ============================================

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/sudoku_generator.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final hasSaved = await StorageService.hasSavedGame();
    if (!mounted) return;
    setState(() => _hasSavedGame = hasSaved);
  }

  // ======================
  // Nouvelle partie
  // ======================
  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choisir la difficulté',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _difficultyButton('Facile', Difficulty.facile, Colors.green),
              const SizedBox(height: 12),
              _difficultyButton('Moyen', Difficulty.moyen, Colors.orange),
              const SizedBox(height: 12),
              _difficultyButton('Difficile', Difficulty.difficile, Colors.red),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _difficultyButton(String label, Difficulty difficulty, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.pop(context);
          _startNewGame(difficulty);
        },
        child: Text(label),
      ),
    );
  }

  void _startNewGame(Difficulty difficulty) {
    final gameState = SudokuGenerator.generatePuzzle(difficulty);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(gameState: gameState)),
    ).then((_) => _checkSavedGame());
  }

  Future<void> _resumeGame() async {
    final gameState = await StorageService.loadGame();
    if (gameState != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(gameState: gameState)),
      ).then((_) => _checkSavedGame());
    }
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // LOGO (بلا cadre)
              Image.asset(
                'assets/images/logo.jpg',
                width: 130,
                height: 130,
              ),

              const SizedBox(height: 24),

              const Text(
                'Sudoku',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Entraînez votre esprit',
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 40),

              // Nouvelle partie
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showDifficultyDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Nouvelle partie',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              if (_hasSavedGame) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resumeGame,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Reprendre',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/profile-stats');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }
}
