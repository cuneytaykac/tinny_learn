import 'package:flutter/material.dart';

enum JigsawEdge { flat, tab, hole }

// JigsawPath class removed as it was unused and incomplete. Use JigsawClipper instead.

// Re-implementing with specific drawing logic per side for 100% control
class JigsawClipper extends CustomClipper<Path> {
  final JigsawEdge top;
  final JigsawEdge right;
  final JigsawEdge bottom;
  final JigsawEdge left;
  final double tabSize;
  final double padding;
  final double cornerRadius;

  JigsawClipper({
    this.top = JigsawEdge.flat,
    this.right = JigsawEdge.flat,
    this.bottom = JigsawEdge.flat,
    this.left = JigsawEdge.flat,
    this.tabSize = 15.0,
    this.padding = 15.0,
    this.cornerRadius = 16.0, // Match board radius
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final t = tabSize;
    final p = padding;
    final r = cornerRadius; // Corner radius

    final leftBound = p;
    final topBound = p;
    final rightBound = w - p;
    final bottomBound = h - p;
    final width = rightBound - leftBound; // Should be 100 typically
    final height = bottomBound - topBound;

    // Check corners
    bool tlCorner = (top == JigsawEdge.flat && left == JigsawEdge.flat);
    bool trCorner = (top == JigsawEdge.flat && right == JigsawEdge.flat);
    bool brCorner = (bottom == JigsawEdge.flat && right == JigsawEdge.flat);
    bool blCorner = (bottom == JigsawEdge.flat && left == JigsawEdge.flat);

    // TOP
    if (tlCorner) {
      path.moveTo(leftBound, topBound + r);
      path.quadraticBezierTo(leftBound, topBound, leftBound + r, topBound);
    } else {
      path.moveTo(leftBound, topBound);
    }

    if (top == JigsawEdge.flat) {
      if (trCorner) {
        path.lineTo(rightBound - r, topBound);
        path.quadraticBezierTo(rightBound, topBound, rightBound, topBound + r);
      } else {
        path.lineTo(rightBound, topBound);
      }
    } else {
      path.lineTo(leftBound + width / 2 - t, topBound);
      double dy = top == JigsawEdge.tab ? -t : t;
      path.cubicTo(
        leftBound + width / 2 - t,
        topBound,
        leftBound + width / 2 - t,
        topBound + dy,
        leftBound + width / 2,
        topBound + dy,
      );
      path.cubicTo(
        leftBound + width / 2 + t,
        topBound + dy,
        leftBound + width / 2 + t,
        topBound,
        leftBound + width / 2 + t,
        topBound,
      );
      path.lineTo(rightBound, topBound);
    }

    // RIGHT
    if (right == JigsawEdge.flat) {
      if (brCorner) {
        path.lineTo(rightBound, bottomBound - r);
        path.quadraticBezierTo(
          rightBound,
          bottomBound,
          rightBound - r,
          bottomBound,
        );
      } else {
        path.lineTo(rightBound, bottomBound);
      }
    } else {
      path.lineTo(rightBound, topBound + height / 2 - t);
      double dx = right == JigsawEdge.tab ? t : -t;
      path.cubicTo(
        rightBound,
        topBound + height / 2 - t,
        rightBound + dx,
        topBound + height / 2 - t,
        rightBound + dx,
        topBound + height / 2,
      );
      path.cubicTo(
        rightBound + dx,
        topBound + height / 2 + t,
        rightBound,
        topBound + height / 2 + t,
        rightBound,
        topBound + height / 2 + t,
      );
      path.lineTo(rightBound, bottomBound);
    }

    // BOTTOM
    if (bottom == JigsawEdge.flat) {
      if (blCorner) {
        path.lineTo(leftBound + r, bottomBound);
        path.quadraticBezierTo(
          leftBound,
          bottomBound,
          leftBound,
          bottomBound - r,
        );
      } else {
        path.lineTo(leftBound, bottomBound);
      }
    } else {
      path.lineTo(leftBound + width / 2 + t, bottomBound);
      double dy = bottom == JigsawEdge.tab ? t : -t;
      path.cubicTo(
        leftBound + width / 2 + t,
        bottomBound,
        leftBound + width / 2 + t,
        bottomBound + dy,
        leftBound + width / 2,
        bottomBound + dy,
      );
      path.cubicTo(
        leftBound + width / 2 - t,
        bottomBound + dy,
        leftBound + width / 2 - t,
        bottomBound,
        leftBound + width / 2 - t,
        bottomBound,
      );
      path.lineTo(leftBound, bottomBound);
    }

    // LEFT
    if (left == JigsawEdge.flat) {
      if (tlCorner) {
        path.lineTo(leftBound, topBound + r);
        // Already moved to start of curve at beginning so just close?
        // No, loop closes automatically? path.close() draws line to moveTo.
        // Actually we started at (leftBound, topBound + r).
        // So lining to it is redundant but safe.
      } else {
        path.lineTo(leftBound, topBound);
      }
    } else {
      path.lineTo(leftBound, topBound + height / 2 + t);
      double dx = left == JigsawEdge.tab ? -t : t;
      path.cubicTo(
        leftBound,
        topBound + height / 2 + t,
        leftBound + dx,
        topBound + height / 2 + t,
        leftBound + dx,
        topBound + height / 2,
      );
      path.cubicTo(
        leftBound + dx,
        topBound + height / 2 - t,
        leftBound,
        topBound + height / 2 - t,
        leftBound,
        topBound + height / 2 - t,
      );
      path.lineTo(leftBound, topBound);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
