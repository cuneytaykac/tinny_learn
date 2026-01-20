import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/games/flashcard_provider.dart';
import '../../widgets/flashcard/flashcard_item.dart';

class FlashcardScreen extends StatelessWidget {
  final Category category;

  const FlashcardScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FlashcardProvider(category: category),
      child: Builder(
        builder: (context) {
          final provider = context.read<FlashcardProvider>();
          
          return Scaffold(
            backgroundColor: category.color,
            appBar: AppBar(
              centerTitle: true,
              leading: BackButton(
                color: AppTheme.primaryTextColor,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                category.nameTr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: provider.pageController,
                    itemCount: category.items.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: provider.onPageChanged,
                    itemBuilder: (context, index) {
                      final item = category.items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                        // Listen for current index to trigger animations
                        child: Selector<FlashcardProvider, int>(
                          selector: (_, p) => p.currentIndex,
                          builder: (context, currentIndex, _) {
                            return FlashcardItem(
                              item: item,
                              onSpeak: provider.speak,
                              onPlaySound: () => provider.playSound(item.audioPath),
                              isVisible: currentIndex == index,
                              type: category.type,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Pagination Dots / Counter
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Selector<FlashcardProvider, int>(
                      selector: (_, p) => p.currentIndex,
                      builder: (context, currentIndex, _) {
                        return Text(
                          "${currentIndex + 1} / ${category.items.length}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        );
                      },
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

