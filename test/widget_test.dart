import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_mobile/providers/game_provider.dart';
import 'package:sudoku_mobile/providers/user_provider.dart';
import 'package:sudoku_mobile/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays title and buttons', (WidgetTester tester) async {
    // Créer une instance de UserProvider
    final userProvider = UserProvider();

    // Fournir les providers nécessaires
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          ChangeNotifierProvider<GameProvider>(
            create: (_) => GameProvider(userProvider: userProvider),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Vérifie que le titre "Sudoku" est affiché
    expect(find.text('Sudoku'), findsOneWidget);

    // Vérifie que les boutons de difficulté sont présents
    expect(find.text('Nouvelle partie'), findsOneWidget);

    // Vérifie que le texte "Reprendre" n'apparaît que si un jeu sauvegardé existe
    expect(find.text('Reprendre'), findsNothing);
  });
}
