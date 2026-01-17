import 'package:flutter/material.dart';
import '../models/data_models.dart';

class DraggableLearningItem extends StatelessWidget {
  final LearningItem item;
  final bool isDropped;

  const DraggableLearningItem({
    super.key,
    required this.item,
    this.isDropped = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDropped) {
      // If dropped, show an empty placeholder or nothing
      return Opacity(opacity: 0.0, child: _buildImage(context));
    }

    return Draggable<LearningItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: _buildImage(context, scale: 1.2),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildImage(context)),
      child: _buildImage(context),
    );
  }

  Widget _buildImage(BuildContext context, {double scale = 1.0}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          item.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (c, o, s) => const Icon(Icons.error, size: 50),
        ),
      ),
    );
  }
}
