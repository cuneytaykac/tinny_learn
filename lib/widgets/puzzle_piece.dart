import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../utils/jigsaw_clipper.dart';

class PuzzlePiece extends StatelessWidget {
  final LearningItem item;
  final int quadrantIndex; // 0: TL, 1: TR, 2: BL, 3: BR
  final bool isDropped;

  const PuzzlePiece({
    super.key,
    required this.item,
    required this.quadrantIndex,
    this.isDropped = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDropped) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Opacity(opacity: 0.3, child: _buildJigsawPiece(context)),
      );
    }

    return Draggable<int>(
      data: quadrantIndex,
      feedback: Transform.scale(
        scale: 1.1,
        child: _buildJigsawPiece(context, withShadow: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildJigsawPiece(context),
      ),
      child: _buildJigsawPiece(context, withShadow: true),
    );
  }

  Widget _buildJigsawPiece(BuildContext context, {bool withShadow = false}) {
    // Logic size of the "grid cell" is 100x100.
    // The visual piece is 130x130 (100 + 2*15 padding).

    // Clipper Config
    final clipper = _getClipper();

    // Calculate image offset based on quadrant
    // We want the relevant 100x100 part of the 200x200 image to sit at (15, 15) in this widget.
    // TL (0,0): Image(0,0) -> Widget(15,15). Offset = 15.
    // TR (1,0): Image(100,0) -> Widget(15,15). Offset X = 15 - 100 = -85.
    // BL (0,1): Image(0,100) -> Widget(15,15). Offset Y = 15 - 100 = -85.
    double offsetX = -15.0; // Wait.
    // If widget top-left is (0,0). The padding starts at 15.
    // If I want Image(0,0) to be at Widget(15,15).
    // Then I place Image at left: 15, top: 15.

    // If I want Image(100,0) to be at Widget(15,15).
    // Image is 200 wide.
    // I want the pixel at 100 inside the image to be at 15 in the widget.
    // So entire image left = 15 - 100 = -85. Correct.

    double left = 15;
    double top = 15;

    if (quadrantIndex == 1 || quadrantIndex == 3) {
      left = 15.0 - 100.0;
    }
    if (quadrantIndex == 2 || quadrantIndex == 3) {
      top = 15.0 - 100.0;
    }

    return SizedBox(
      width: 130,
      height: 130,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shadow / Outline
            if (withShadow)
              CustomPaint(
                painter: JigsawBorderPainter(
                  clipper: clipper,
                  color: Colors.white,
                ),
                size: const Size(130, 130),
              ),

            // Clipped Image
            ClipPath(
              clipper: clipper,
              child: Container(
                width: 130, // Match Clipper Size
                height: 130,
                color: Colors.transparent, // Background for the clip
                child: Stack(
                  children: [
                    Positioned(
                      left: left,
                      top: top,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset(item.imagePath, fit: BoxFit.fill),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  JigsawClipper _getClipper() {
    // 0 TL, 1 TR
    // 2 BL, 3 BR
    switch (quadrantIndex) {
      // TL: Right Tab, Bottom Tab
      case 0:
        return JigsawClipper(right: JigsawEdge.tab, bottom: JigsawEdge.tab);
      // TR: Left Hole, Bottom Tab
      case 1:
        return JigsawClipper(left: JigsawEdge.hole, bottom: JigsawEdge.tab);
      // BL: Top Hole, Right Tab
      case 2:
        return JigsawClipper(top: JigsawEdge.hole, right: JigsawEdge.tab);
      // BR: Top Hole, Left Hole
      case 3:
        return JigsawClipper(top: JigsawEdge.hole, left: JigsawEdge.hole);
      default:
        return JigsawClipper();
    }
  }
}

class JigsawBorderPainter extends CustomPainter {
  final JigsawClipper clipper;
  final Color color;

  JigsawBorderPainter({required this.clipper, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    // Optional: Add shadow
    canvas.drawShadow(path, Colors.black, 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
