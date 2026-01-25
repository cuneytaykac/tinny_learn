import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/connectivity_provider.dart';
import '../providers/game_provider.dart';
import '../models/data_models.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_page.dart';
import '../screens/no_internet/no_internet_screen.dart';
import '../screens/modes/flashcard_screen.dart';
import '../screens/modes/quiz_screen.dart';
import '../screens/modes/puzzle_screen.dart';
import '../screens/modes/memory_game_screen.dart';
import '../screens/modes/matching_screen.dart';
import '../screens/modes/surprise_egg_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/language_screen.dart';
import '../screens/settings/about_screen.dart';

class AppRouter {
  final ConnectivityProvider connectivityProvider;
  final GameProvider gameProvider;

  AppRouter({required this.connectivityProvider, required this.gameProvider});

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: connectivityProvider,
    // Redirect logic removed in favor of global ConnectivityWrapper
    redirect: (BuildContext context, GoRouterState state) => null,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/no-internet',
        builder: (context, state) => const NoInternetScreen(),
      ),
      GoRoute(
        path: '/flashcard/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = _getCategory(categoryId);
          return FlashcardScreen(category: category);
        },
      ),
      GoRoute(
        path: '/quiz/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = _getCategory(categoryId);
          return QuizScreen(category: category);
        },
      ),
      GoRoute(
        path: '/puzzle/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = _getCategory(categoryId);
          return PuzzleScreen(category: category);
        },
      ),
      GoRoute(
        path: '/memory/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = _getCategory(categoryId);
          return MemoryGameScreen(category: category);
        },
      ),
      GoRoute(
        path: '/matching/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = _getCategory(categoryId);
          return MatchingScreen(category: category);
        },
      ),
      GoRoute(
        path: '/surprise-egg/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = _getCategory(categoryId);
          return SurpriseEggScreen(category: category);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageScreen(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
  );

  Category _getCategory(String categoryId) {
    return gameProvider.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => gameProvider.categories.first,
    );
  }
}
