import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/puzzle_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/game_screen.dart';
import 'screens/victory_screen.dart';

void main() {
  runApp(const SlidePuzzleApp());
}

/// Punto de entrada de la aplicación.
class SlidePuzzleApp extends StatelessWidget {
  const SlidePuzzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PuzzleProvider(),
      child: Consumer<PuzzleProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Slide Puzzle',
            initialRoute: WelcomeScreen.routeName,
            routes: {
              WelcomeScreen.routeName: (_) => const WelcomeScreen(),
              DashboardScreen.routeName: (_) => DashboardScreen(),
              GameScreen.routeName: (_) => const GameScreen(),
              VictoryScreen.routeName: (_) => const VictoryScreen(),
            },
          );
        },
      ),
    );
  }
}
