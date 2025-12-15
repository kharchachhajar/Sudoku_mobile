// ============================================
// providers/user_provider.dart - VERSION CORRIGÉE
// ============================================

import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  String _username = 'Invité';
  String _avatar = '😀';
  String _country = 'Maroc';
  int _level = 0;
  bool _isLoggedIn = false;
  DateTime? _createdAt;

  bool _isInitialized = false;

  // ======== GETTERS ========
  String get username => _username;
  String get avatar => _avatar;
  String get country => _country;
  int get level => _level;
  bool get isLoggedIn => _isLoggedIn;
  DateTime? get createdAt => _createdAt;

  int get daysSinceCreation {
    if (_createdAt == null) return 0;
    return DateTime.now().difference(_createdAt!).inDays;
  }

  String get welcomeMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour, $_username !';
    if (hour < 18) return 'Bon après-midi, $_username !';
    return 'Bonsoir, $_username !';
  }

  UserProvider() {
    _initialize();
  }

  // ======== INITIALISATION ========
  Future<void> _initialize() async {
    if (_isInitialized) return;

    final userData = await StorageService.loadUserProfile();

    if (userData != null) {
      _username = userData['username'] ?? 'Invité';
      _avatar = userData['avatar'] ?? '😀';
      _country = userData['country'] ?? 'Maroc';
      _level = userData['level'] ?? 0;
      _isLoggedIn = userData['isLoggedIn'] ?? false;

      final created = userData['createdAt'];
      if (created is String) {
        _createdAt = DateTime.tryParse(created);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ======== MÉTHODE INTERNE ========
  Future<void> _saveUser() async {
    await StorageService.saveUserProfile({
      'username': _username,
      'avatar': _avatar,
      'country': _country,
      'level': _level,
      'isLoggedIn': _isLoggedIn,
      'createdAt': _createdAt?.toIso8601String(),
    });

    notifyListeners(); // ⭐ Notifier après chaque sauvegarde
  }

  // ======== ACTIONS UTILISATEUR ========
  Future<void> createProfile(String username) async {
    _username = username;
    _isLoggedIn = true;
    _createdAt = DateTime.now();
    _level = 1;

    await _saveUser();
  }

  Future<void> updateProfile(String username) async {
    if (username.trim().isEmpty) return;

    _username = username.trim();
    _isLoggedIn = true;

    // ⭐ Si c'est la première fois, initialiser createdAt
    if (_createdAt == null) {
      _createdAt = DateTime.now();
    }

    await _saveUser();
  }

  void selectAvatar(String emoji) async {
    _avatar = emoji;
    await _saveUser();
  }

  Future<void> updateCountry(String country) async {
    _country = country;
    await _saveUser();
  }

  Future<void> increaseLevel() async {
    _level++;
    await _saveUser();
  }

  Future<void> logout() async {
    _username = 'Invité';
    _avatar = '😀';
    _level = 0;
    _isLoggedIn = false;
    _createdAt = null;

    await StorageService.clearUserProfile();
    notifyListeners();
  }

  // ⭐ Méthode pour forcer le rechargement
  Future<void> reload() async {
    _isInitialized = false;
    await _initialize();
  }
}