// ============================================
// screens/settings_screen.dart - ⭐ CORRIGÉ (thème)
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: settings.isDarkMode ? Colors.grey[900] : Colors.white,
          appBar: AppBar(
            title: Text(
              'Paramètres',
              style: TextStyle(
                color: settings.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: settings.isDarkMode ? Colors.grey[850] : Colors.white,
            iconTheme: IconThemeData(
              color: settings.isDarkMode ? Colors.white : AppConstants.primaryColor,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // ⭐ NOUVELLE SECTION APPARENCE
              _buildSectionHeader('Apparence', settings.isDarkMode),

              _buildSettingTile(
                context: context,
                icon: Icons.dark_mode,
                title: 'Mode sombre',
                subtitle: 'Activer le thème sombre',
                value: settings.isDarkMode,
                onChanged: (value) {
                  settings.setDarkMode(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Mode sombre activé'
                          : 'Mode clair activé'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                isDarkMode: settings.isDarkMode,
              ),

              // ⭐ SECTION GAMEPLAY - TOUS FONCTIONNELS
              _buildSectionHeader('Gameplay', settings.isDarkMode),

              _buildSettingTile(
                context: context,
                icon: Icons.error_outline,
                title: 'Vérification automatique des erreurs',
                subtitle: 'Marquer automatiquement les erreurs',
                value: settings.autoCheckErrors,
                onChanged: (value) {
                  settings.setAutoCheckErrors(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Vérification automatique activée'
                          : 'Vérification automatique désactivée'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                isDarkMode: settings.isDarkMode,
              ),

              _buildSettingTile(
                context: context,
                icon: Icons.highlight,
                title: 'Surligner les numéros similaires',
                subtitle: 'Mettre en évidence les mêmes chiffres',
                value: settings.highlightSimilar,
                onChanged: (value) {
                  settings.setHighlightSimilar(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Surlignage activé'
                          : 'Surlignage désactivé'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                isDarkMode: settings.isDarkMode,
              ),

              _buildSettingTile(
                context: context,
                icon: Icons.timer,
                title: 'Afficher le chronomètre',
                subtitle: 'Voir le temps écoulé pendant le jeu',
                value: settings.showTimer,
                onChanged: (value) {
                  settings.setShowTimer(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Chronomètre affiché'
                          : 'Chronomètre masqué'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                isDarkMode: settings.isDarkMode,
              ),

              const SizedBox(height: 24),

              // ⭐ SECTION NOTIFICATIONS ET SONS - TOUS FONCTIONNELS
              _buildSectionHeader('Notifications et Sons', settings.isDarkMode),

              _buildSettingTile(
                context: context,
                icon: Icons.volume_up,
                title: 'Sons',
                subtitle: 'Activer les effets sonores',
                value: settings.soundEnabled,
                onChanged: (value) {
                  settings.setSoundEnabled(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Sons activés'
                          : 'Sons désactivés'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                isDarkMode: settings.isDarkMode,
              ),

              _buildSettingTile(
                context: context,
                icon: Icons.vibration,
                title: 'Vibrations',
                subtitle: 'Activer les vibrations',
                value: settings.vibrateEnabled,
                onChanged: (value) {
                  settings.setVibrateEnabled(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Vibrations activées'
                          : 'Vibrations désactivées'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                isDarkMode: settings.isDarkMode,
              ),

              const SizedBox(height: 24),

              // Section À propos
              _buildSectionHeader('À propos', settings.isDarkMode),
              Card(
                color: settings.isDarkMode ? Colors.grey[850] : Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.info_outline, color: AppConstants.primaryColor),
                  title: Text(
                    'Version',
                    style: TextStyle(color: settings.isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    '1.0.0',
                    style: TextStyle(color: settings.isDarkMode ? Colors.white70 : Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppConstants.primaryColor.withOpacity(0.8) : AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDarkMode,
  }) {
    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppConstants.primaryColor),
        title: Text(
          title,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }
}