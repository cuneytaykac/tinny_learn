import 'package:flutter/material.dart';
import '../models/data_models.dart';

class ShadowTargetItem extends StatelessWidget {
  final LearningItem item;
  final bool isMatched;
  final Function(LearningItem) onAccept;

  const ShadowTargetItem({
    super.key,
    required this.item,
    required this.isMatched,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<LearningItem>(
      onWillAccept: (data) => !isMatched, // Only accept if not already matched
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color:
                isHovering
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child:
                isMatched
                    ? _buildOriginalImage() // Show real image if matched
                    : _buildShadowImage(isHovering), // Show shadow otherwise
          ),
        );
      },
    );
  }

  Widget _buildOriginalImage() {
    return item.imagePath != null
        ? Image.asset(
          item.imagePath!,
          fit: BoxFit.contain,
          width: 100,
          height: 100,
        )
        : Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        );
  }

  Widget _buildShadowImage(bool isHovering) {
    if (item.imagePath != null) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.black, // Turn image into solid black silhouette
          BlendMode.srcIn,
        ),
        child: Opacity(
          opacity: isHovering ? 0.6 : 0.3, // Dim when hovering
          child: Image.asset(
            item.imagePath!,
            fit: BoxFit.contain,
            width: 100,
            height: 100,
          ),
        ),
      );
    } else {
      // For color item, 'shadow' is just a grey/black circle
      return Opacity(
        opacity: isHovering ? 0.6 : 0.3,
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.black, // Shadow is black
            shape: BoxShape.circle,
          ),
        ),
      );
    }
  }
}
