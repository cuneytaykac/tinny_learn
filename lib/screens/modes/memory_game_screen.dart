import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/games/memory_game_provider.dart';
import '../../widgets/memory/memory_card.dart';

class MemoryGameScreen extends StatelessWidget {
  final Category category;

  const MemoryGameScreen({super.key, required this.category});

  void _showWinDialog(BuildContext context, MemoryGameProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Column(
              children: [
                const Text("🎉 Tebrikler! 🎉", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(
                  "Süre: ${provider.formattedTime}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Tüm bayrakları eşleştirdin!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: const Text(
                  "Çıkış",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.restartGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Tekrar Oyna",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemoryGameProvider(category: category),
      child: Builder(
        builder: (context) {
          // Use context.read/watch carefully.
          // For static access (AppBar actions), read is sufficient.
          return Scaffold(
            backgroundColor: category.color.withOpacity(0.1),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackButton(
                color: AppTheme.primaryTextColor,
                onPressed: () {
                  context.read<MemoryGameProvider>().stopTimer();
                  Navigator.pop(context);
                },
              ),
              title: Text(
                "Hafıza Oyunu",
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),
                    // Timer Container - Rebuilds ONLY when time changes
                    Selector<MemoryGameProvider, String>(
                      selector: (_, provider) => provider.formattedTime,
                      builder: (context, formattedTime, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_rounded,
                                color: Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Game Grid - Rebuilds ONLY when stateVersion changes (user interacts)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Selector<MemoryGameProvider, int>(
                          selector: (_, provider) => provider.stateVersion,
                          builder: (context, stateVersion, _) {
                            final provider = context.read<MemoryGameProvider>();
                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.2,
                                  ),
                              itemCount: provider.cards.length,
                              itemBuilder: (context, index) {
                                final card = provider.cards[index];
                                return MemoryCardWidget(
                                  card: card,
                                  onTap: () async {
                                    final result = await provider.onCardTap(
                                      index,
                                    );
                                    if (result == MoveResult.win &&
                                        context.mounted) {
                                      _showWinDialog(context, provider);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                // Confetti Widget - Static access to controller
                Align(
                  alignment: Alignment.topCenter,
                  child: Selector<MemoryGameProvider, ConfettiController>(
                    selector: (_, provider) => provider.confettiController,
                    builder: (context, controller, _) {
                      return ConfettiWidget(
                        confettiController: controller,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink,
                          Colors.orange,
                        ],
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
}
