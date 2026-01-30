import 'dart:math';

import 'package:flutter/material.dart';

class EggWidget extends StatelessWidget {
  final Color eggColor;
  final Color patternColor;
  final int patternType;

  const EggWidget({
    super.key,
    required this.eggColor,
    required this.patternColor,
    required this.patternType,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.elliptical(125, 160));

    return SizedBox(
      width: 250,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Base Egg with 3D Shader/Gradient
          Container(
            decoration: BoxDecoration(
              color: eggColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 15),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: eggColor.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  eggColor.withValues(alpha: 0.9),
                  HSLColor.fromColor(eggColor).withLightness(0.35).toColor(),
                ],
                center: const Alignment(-0.3, -0.4),
                radius: 1.3,
              ),
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Stack(
                children: [
                  // 2. Patterns Layer
                  CustomPaint(
                    size: const Size(250, 320),
                    painter: EggDecorationPainter(
                      color: patternColor,
                      type: patternType,
                    ),
                  ),

                  // 3. Specular Gloss
                  Positioned(
                    top: 30,
                    left: 45,
                    child: Container(
                      width: 70,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(35, 50),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.7),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Rim Light
                  Positioned(
                    bottom: 25,
                    right: 50,
                    child: Container(
                      width: 50,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(25, 12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EggDecorationPainter extends CustomPainter {
  final Color color;
  final int type;

  EggDecorationPainter({required this.color, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final rng = Random(123 + type);

    switch (type) {
      case 0:
        _drawDots(canvas, paint, w, h, rng);
        break;
      case 1:
        _drawStars(canvas, paint, w, h, rng);
        break;
      case 2:
        _drawWaves(canvas, paint, w, h);
        break;
      case 3:
        _drawZigZag(canvas, paint, w, h);
        break;
    }
  }

  void _drawDots(Canvas canvas, Paint paint, double w, double h, Random rng) {
    for (int i = 0; i < 18; i++) {
      double x = rng.nextDouble() * w;
      double y = rng.nextDouble() * h;
      double r = 10 + rng.nextDouble() * 25;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _drawStars(Canvas canvas, Paint paint, double w, double h, Random rng) {
    for (int i = 0; i < 12; i++) {
      double x = rng.nextDouble() * w;
      double y = rng.nextDouble() * h;
      double size = 15 + rng.nextDouble() * 20;
      final starPaint =
          Paint()
            ..color = color
            ..strokeWidth = size / 3
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(x - size / 2, y),
        Offset(x + size / 2, y),
        starPaint,
      );
      canvas.drawLine(
        Offset(x, y - size / 2),
        Offset(x, y + size / 2),
        starPaint,
      );
    }
  }

  void _drawWaves(Canvas canvas, Paint paint, double w, double h) {
    final strokePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    _drawSineWave(canvas, strokePaint, w, h * 0.3);
    _drawSineWave(canvas, strokePaint, w, h * 0.5);
    _drawSineWave(canvas, strokePaint, w, h * 0.7);
  }

  void _drawSineWave(Canvas canvas, Paint paint, double w, double y) {
    Path path = Path()..moveTo(0, y);
    // ignore: curly_braces_in_flow_control_structures
    for (double i = 0; i <= w; i += 5) path.lineTo(i, y + 10 * sin(i * 0.1));
    canvas.drawPath(path, paint);
  }

  void _drawZigZag(Canvas canvas, Paint paint, double w, double h) {
    final strokePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;
    double y1 = h * 0.4, y2 = h * 0.6;
    Path path1 = Path()..moveTo(0, y1);
    Path path2 = Path()..moveTo(0, y2);
    const double step = 30;
    for (double x = 0; x <= w; x += step) {
      double nextY = (x / step) % 2 == 0 ? -20 : 20;
      path1.relativeLineTo(step, nextY);
      path2.relativeLineTo(step, nextY);
    }
    canvas.drawPath(path1, strokePaint);
    canvas.drawPath(path2, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CrackPainter extends CustomPainter {
  final int level;
  CrackPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    final path = Path();

    if (level >= 1) {
      path.moveTo(w * 0.5, 0);
      path.lineTo(w * 0.45, h * 0.2);
      path.lineTo(w * 0.55, h * 0.35);
    }
    if (level >= 2) {
      path.moveTo(w * 0.55, h * 0.35);
      path.lineTo(w * 0.4, h * 0.5);
      path.lineTo(w * 0.6, h * 0.65);
    }
    if (level >= 3) {
      path.moveTo(w * 0.6, h * 0.65);
      path.lineTo(w * 0.5, h * 0.85);
      path.lineTo(w * 0.5, h);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CrackPainter oldDelegate) =>
      oldDelegate.level != level;
}
