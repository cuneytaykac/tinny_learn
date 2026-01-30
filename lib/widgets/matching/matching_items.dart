import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/data_models.dart';

class MatchingTargetItem extends StatelessWidget {
  final LearningItem item;
  final bool isMatched;
  final Function(LearningItem) onMatch;

  const MatchingTargetItem({
    super.key,
    required this.item,
    required this.isMatched,
    required this.onMatch,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<LearningItem>(
      onWillAcceptWithDetails: (data) => data.data.id == item.id,
      onAcceptWithDetails: (data) => onMatch(item),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isMatched
                      ? Colors.green
                      : (candidateData.isNotEmpty
                          ? Colors.amber
                          : Colors.blue.shade100),
              width: isMatched ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              isMatched
                  ? Center(
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 60,
                    ).animate().scale(curve: Curves.elasticOut),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(
                      builder: (context) {
                        if (item.imagePath != null) {
                          if (item.imagePath!.startsWith('http')) {
                            return CachedNetworkImage(
                              imageUrl: item.imagePath!,
                              fit: BoxFit.contain,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                            );
                          } else {
                            return Image.asset(item.imagePath!);
                          }
                        } else {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          );
                        }
                      },
                    ),
                  ),
        );
      },
    );
  }
}

class MatchingSourceItem extends StatelessWidget {
  final LearningItem item;
  final bool isMatched;

  const MatchingSourceItem({
    super.key,
    required this.item,
    required this.isMatched,
  });

  @override
  Widget build(BuildContext context) {
    if (isMatched) {
      return const SizedBox(width: 80, height: 80); // Invisible placeholder
    }

    return Draggable<LearningItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      ),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: item.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
