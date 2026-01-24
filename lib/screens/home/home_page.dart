import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/game_provider.dart';
import '../../models/data_models.dart';
import '../modes/flashcard_screen.dart';
import '../modes/quiz_screen.dart';
import '../modes/puzzle_screen.dart';
import '../modes/surprise_egg_screen.dart';
import '../modes/matching_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../gen/locale_keys.g.dart';
import '../modes/memory_game_screen.dart';
import '../settings/settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Locale? _previousLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale;

    // If locale changed, reload categories to update translations
    if (_previousLocale != null && _previousLocale != currentLocale) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.loadCategories();
    }

    _previousLocale = currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.home_title.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  LocaleKeys.home_lets_learn.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: gameProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = gameProvider.categories[index];
                      return CategoryCard(
                        category: category,
                        isUnlocked: gameProvider.isCategoryUnlocked(
                          category.id,
                        ),
                        onTap: () {
                          if (gameProvider.isCategoryUnlocked(category.id)) {
                            // Show Mode Selection Dialog
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    title: Text(
                                      LocaleKeys.home_what_to_do.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildModeOption(
                                          context,
                                          title: LocaleKeys.modes_learn.tr(),
                                          icon: Icons.school_rounded,
                                          color: Colors.orangeAccent,
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        FlashcardScreen(
                                                          category: category,
                                                        ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        if (category.id == 'colors') ...[
                                          _buildModeOption(
                                            context,
                                            title: LocaleKeys.modes_quiz.tr(),
                                            icon: Icons.extension_rounded,
                                            color: Colors.lightBlueAccent,
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => QuizScreen(
                                                        category: category,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          _buildModeOption(
                                            context,
                                            title:
                                                LocaleKeys.modes_matching.tr(),
                                            icon: Icons.compare_arrows_rounded,
                                            color: Colors.lightGreen,
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          MatchingScreen(
                                                            category: category,
                                                          ),
                                                ),
                                              );
                                            },
                                          ),
                                        ] else if (category.id == 'flags') ...[
                                          _buildModeOption(
                                            context,
                                            title: LocaleKeys.modes_quiz.tr(),
                                            icon: Icons.extension_rounded,
                                            color: Colors.lightBlueAccent,
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => QuizScreen(
                                                        category: category,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          _buildModeOption(
                                            context,
                                            title: LocaleKeys.modes_memory.tr(),
                                            icon: Icons.grid_view_rounded,
                                            color: Colors.purpleAccent,
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          MemoryGameScreen(
                                                            category: category,
                                                          ),
                                                ),
                                              );
                                            },
                                          ),
                                        ] else ...[
                                          _buildModeOption(
                                            context,
                                            title: LocaleKeys.modes_quiz.tr(),
                                            icon: Icons.extension_rounded,
                                            color: Colors.lightBlueAccent,
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => QuizScreen(
                                                        category: category,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          _buildModeOption(
                                            context,
                                            title: LocaleKeys.modes_puzzle.tr(),
                                            icon: Icons.grid_view_rounded,
                                            color: Colors.purpleAccent,
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => PuzzleScreen(
                                                        category: category,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          _buildModeOption(
                                            context,
                                            title:
                                                LocaleKeys.modes_surprise_egg
                                                    .tr(),
                                            icon: Icons.egg_rounded,
                                            color: Colors.pinkAccent,
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          SurpriseEggScreen(
                                                            category: category,
                                                          ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                            );
                          } else {
                            // Show lock dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  LocaleKeys.home_category_locked.tr(),
                                ),
                              ),
                            );
                          }
                        },
                      ).animate().scale(
                        delay: (100 * index).ms,
                        duration: 400.ms,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isUnlocked;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icon
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Category-specific icons
                  _buildCategoryIcon(category.id),
                  const SizedBox(height: 16),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Lock Overlay
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(Icons.lock, size: 48, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'colors':
        return Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      case 'animals':
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.pets_rounded, size: 50, color: Colors.orange),
        );
      case 'vehicles':
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            size: 50,
            color: Colors.blue,
          ),
        );
      case 'flags':
        return Image.asset(
          category.iconPath,
          width: 80,
          height: 80,
          errorBuilder:
              (c, o, s) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 50,
                  color: Colors.amber,
                ),
              ),
        );
      default:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.star_rounded, size: 50, color: Colors.amber),
        );
    }
  }
}
