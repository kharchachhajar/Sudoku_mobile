// ============================================
// providers/settings_provider.dart
// ============================================

import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _autoCheckErrors = true;
  bool _highlightSimilar = true;
  bool _showTimer = true;
  bool _soundEnabled = false;
  bool _vibrateEnabled = true;
  bool _isDarkMode = false;

  // ======== GETTERS ========
  bool get autoCheckErrors => _autoCheckErrors;
  bool get highlightSimilar => _highlightSimilar;
  bool get showTimer => _showTimer;
  bool get soundEnabled => _soundEnabled;
  bool get vibrateEnabled => _vibrateEnabled;
  bool get isDarkMode => _isDarkMode;

  SettingsProvider() {
    _loadSettings();
  }

  // ======== CHARGER LES PARAMÈTRES ========
  Future<void> _loadSettings() async {
    final settings = await StorageService.loadSettings();
    if (settings != null) {
      _autoCheckErrors = settings['autoCheckErrors'] ?? true;
      _highlightSimilar = settings['highlightSimilar'] ?? true;
      _showTimer = settings['showTimer'] ?? true;
      _soundEnabled = settings['soundEnabled'] ?? false;
      _vibrateEnabled = settings['vibrateEnabled'] ?? true;
      _isDarkMode = settings['isDarkMode'] ?? false;
      notifyListeners();
    }
  }

  // ======== SAUVEGARDER LES PARAMÈTRES ========
  Future<void> _saveSettings() async {
    await StorageService.saveSettings({
      'autoCheckErrors': _autoCheckErrors,
      'highlightSimilar': _highlightSimilar,
      'showTimer': _showTimer,
      'soundEnabled': _soundEnabled,
      'vibrateEnabled': _vibrateEnabled,
      'isDarkMode': _isDarkMode,
    });
  }

  // ======== SETTERS ========
  void setAutoCheckErrors(bool value) => _updateSetting(() => _autoCheckErrors = value);
  void setHighlightSimilar(bool value) => _updateSetting(() => _highlightSimilar = value);
  void setShowTimer(bool value) => _updateSetting(() => _showTimer = value);
  void setSoundEnabled(bool value) => _updateSetting(() => _soundEnabled = value);
  void setVibrateEnabled(bool value) => _updateSetting(() => _vibrateEnabled = value);
  void setDarkMode(bool value) => _updateSetting(() => _isDarkMode = value);

  // Méthode interne pour notifier et sauvegarder
  void _updateSetting(VoidCallback update) {
    update();
    notifyListeners();
    _saveSettings();
  }
}
