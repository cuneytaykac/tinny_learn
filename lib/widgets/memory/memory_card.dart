import 'package:country_flags_pro/country_flags_pro.dart';
import 'package:flutter/material.dart';

import '../../providers/games/memory_game_provider.dart';

class MemoryCardWidget extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const MemoryCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color:
              card.isFlipped || card.isMatched
                  ? Colors.white
                  : Colors.orangeAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child:
            card.isFlipped || card.isMatched
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.6,
                        child: CountryFlagsPro.getFlag(
                          card.item.id.toLowerCase(),
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                )
                : Center(
                  child: Icon(
                    Icons.question_mark_rounded,
                    size: 50,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
      ),
    );
  }
}
