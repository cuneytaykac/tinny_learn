import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';

class SurpriseEggScreen extends StatefulWidget {
  final Category category;

  const SurpriseEggScreen({super.key, required this.category});

  @override
  State<SurpriseEggScreen> createState() => _SurpriseEggScreenState();
}

class _SurpriseEggScreenState extends State<SurpriseEggScreen>
    with SingleTickerProviderStateMixin {
  late LearningItem _targetItem;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  // Game State
  int _crackLevel = 0; // 0: Intact, 1: Cracked, 2: More Cracked, 3: Broken
  bool _isRevealed = false;

  // Visuals
  Color _eggColor = Colors.white;
  Color _patternColor = Colors.grey;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  int _patternType = 0; // 0: Dots, 1: Stars, 2: Waves, 3: ZigZag

  // Animation
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    setState(() {
      _crackLevel = 0;
      _isRevealed = false;
      _targetItem =
          widget.category.items[_random.nextInt(widget.category.items.length)];

      // 1. Pick a vibrant base color (HSL)
      double hue = _random.nextDouble() * 360;
      final saturation = 0.65 + _random.nextDouble() * 0.35; // 0.65 - 1.0
      final lightness = 0.45 + _random.nextDouble() * 0.25; // 0.45 - 0.70

      final hsl = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
      _eggColor = hsl.toColor();

      // 2. Determine Pattern Type & Color
      _patternType = _random.nextInt(4); // 0..3

      // Pattern color usually white/transparent for glossy look,
      // or a slightly shifted hue for style.
      if (_random.nextBool()) {
        _patternColor = Colors.white.withOpacity(0.35);
      } else {
        _patternColor = hsl
            .withLightness(lightness + 0.2)
            .toColor()
            .withOpacity(0.5);
      }

      // 3. Background: Very soft pastel tint
      _backgroundColor = hsl.withLightness(0.92).withSaturation(0.3).toColor();

      // 4. Text: Dark, readable contrast
      _textColor = hsl.withLightness(0.2).withSaturation(0.8).toColor();
    });
  }

  void _handleTap() {
    if (_isRevealed) return;

    _shakeController.forward(from: 0);

    setState(() {
      _crackLevel++;
    });

    if (_crackLevel < 3) {
      // Tap Sound
      try {
        // _audioPlayer.play(AssetSource('ui/tap.mp3'));
      } catch (_) {}
    } else {
      // Break!
      _revealSurprise();
    }
  }

  void _revealSurprise() {
    setState(() {
      _isRevealed = true;
    });

    _confettiController.play();

    try {
      _audioPlayer.play(AssetSource('ui/applause.mp3'));
    } catch (_) {}

    // Auto reset
    Future.delayed(const Duration(seconds: 4), _startNewRound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: _textColor),
        title: Text(
          'Sürpriz Yumurta',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRevealed)
                  GestureDetector(
                    onTap: _handleTap,
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        // Simple Shake Math
                        double offset =
                            sin(_shakeController.value * pi * 4) * 10;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: _buildEgg(),
                    ),
                  )
                else
                  _buildRevealedContent(),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEgg() {
    // A slightly more "egg-ish" shape (wider bottom)
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
              color: _eggColor,
              borderRadius: borderRadius,
              boxShadow: [
                // Ground shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 15),
                  spreadRadius: -5,
                ),
                // Inner Glow
                BoxShadow(
                  color: _eggColor.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  _eggColor.withOpacity(0.9), // Highlight spot
                  HSLColor.fromColor(
                    _eggColor,
                  ).withLightness(0.35).toColor(), // Darker edge
                ],
                center: const Alignment(-0.3, -0.4), // Top-left light source
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
                      color: _patternColor,
                      type: _patternType,
                    ),
                  ),

                  // 3. Specular Gloss (Glassy Look)
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
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Rim Light (Bottom reflection)
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
                            color: Colors.white.withOpacity(0.2),
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

          // Cracks overlay
          if (_crackLevel > 0)
            CustomPaint(
              size: const Size(250, 320),
              painter: CrackPainter(level: _crackLevel),
            ),

          // Tap Hint (Animated Finger)
          if (_crackLevel == 0)
            Positioned(
              bottom: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                        Icons.touch_app_rounded,
                        size: 55,
                        color: Colors.white,
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                        duration: 600.ms,
                      )
                      .moveY(begin: 0, end: -10, duration: 600.ms),
                  const SizedBox(height: 5),
                  Text(
                    "DOKUN",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRevealedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scaling Reveal Animation
        Container(
          child: Image.asset(
            _targetItem.imagePath,
            width: 250, // Slightly larger since no padding/bg
            height: 250,
            fit: BoxFit.contain,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 30),

        Text(
          _targetItem.nameTr.toUpperCase(),
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: _textColor,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
      ],
    );
  }
}

class EggDecorationPainter extends CustomPainter {
  final Color color;
  final int type; // 0: Dots, 1: Stars, 2: Waves, 3: ZigZag

  EggDecorationPainter({required this.color, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final rng = Random(123 + type); // Fixed seed but varies by type

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

    // Simple sine waves
    _drawSineWave(canvas, strokePaint, w, h * 0.3);
    _drawSineWave(canvas, strokePaint, w, h * 0.5);
    _drawSineWave(canvas, strokePaint, w, h * 0.7);
  }

  void _drawSineWave(Canvas canvas, Paint paint, double w, double y) {
    Path path = Path();
    path.moveTo(0, y);
    for (double i = 0; i <= w; i += 5) {
      path.lineTo(i, y + 10 * sin(i * 0.1));
    }
    canvas.drawPath(path, paint);
  }

  void _drawZigZag(Canvas canvas, Paint paint, double w, double h) {
    final strokePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;

    double y1 = h * 0.4;
    double y2 = h * 0.6;

    Path path1 = Path()..moveTo(0, y1);
    Path path2 = Path()..moveTo(0, y2);

    const double step = 30;
    for (double x = 0; x <= w; x += step) {
      double nextY = (x / step) % 2 == 0 ? -20 : 20;
      path1.relativeLineTo(step, nextY);
      path2.relativeLineTo(step, nextY); // Parallel zigzag
    }

    canvas.drawPath(path1, strokePaint);
    canvas.drawPath(path2, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Randomness needs consistency, ideally pass seed
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

    // Simple zig-zag paths for cracks
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

    // Level 3 is breaking point, handled by switch to reveal usually, but if visible:
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
