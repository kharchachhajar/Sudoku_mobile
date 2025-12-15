// ============================================
// main.dart - VERSION FINALE AVEC STATISTICS_SCREEN CORRIGÉE
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart'; // ← import ajouté

// Utils
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1️⃣ UserProvider doit être créé en premier
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        // 2️⃣ GameProvider reçoit la référence à UserProvider
        ChangeNotifierProvider<GameProvider>(
          create: (context) => GameProvider(
            userProvider: context.read<UserProvider>(),
          ),
        ),
        // 3️⃣ SettingsProvider
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Thème clair
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              primaryColor: AppConstants.primaryColor,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.primaryColor,
                primary: AppConstants.primaryColor,
                error: AppConstants.errorColor,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: AppConstants.primaryColor),
                titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              dialogTheme: DialogThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Thème sombre
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primaryColor: AppConstants.primaryColor,
              scaffoldBackgroundColor: Colors.grey[900],
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.primaryColor,
                primary: AppConstants.primaryColor,
                error: AppConstants.errorColor,
                brightness: Brightness.dark,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[850],
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(color: AppConstants.primaryColor),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: Colors.grey[850],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Routes
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/profile-stats': (context) => const ProfileStatsScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/statistics': (context) => const StatisticsScreen(),
            },

            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
