import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/games/matching_game_provider.dart';
import '../../widgets/matching/matching_items.dart';

class MatchingScreen extends StatelessWidget {
  final Category category;

  const MatchingScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchingGameProvider(category: category),
      child: Consumer<MatchingGameProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFE3F2FD),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackButton(
                color: AppTheme.primaryTextColor,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Eşleştirme Oyunu",
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body:
                provider.currentItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                      children: [
                        Column(
                          children: [
                            // Top Section: Targets (Images)
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children:
                                    provider.currentItems.map((item) {
                                      return MatchingTargetItem(
                                        item: item,
                                        isMatched: provider.isItemMatched(
                                          item.id,
                                        ),
                                        onMatch: provider.handleMatch,
                                      );
                                    }).toList(),
                              ),
                            ),

                            // Arrow Indicator
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.grey.shade400,
                                  size: 40,
                                ),
                              ),
                            ),

                            // Bottom Section: Draggables (Solid Colors)
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children:
                                    provider.draggableItems.map((item) {
                                      return MatchingSourceItem(
                                        item: item,
                                        isMatched: provider.isItemMatched(
                                          item.id,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),

                        // Success Overlay
                        if (provider.isGameComplete)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 80,
                                  ).animate().scale(
                                    duration: 500.ms,
                                    curve: Curves.elasticOut,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Harika!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).animate().fadeIn(delay: 200.ms),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
          );
        },
      ),
    );
  }
}
