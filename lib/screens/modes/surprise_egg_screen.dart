import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/data_models.dart';
import '../../providers/games/surprise_egg_provider.dart';
import '../../widgets/egg/egg_widget.dart';

class SurpriseEggScreen extends StatefulWidget {
  final Category category;

  const SurpriseEggScreen({super.key, required this.category});

  @override
  State<SurpriseEggScreen> createState() => _SurpriseEggScreenState();
}

class _SurpriseEggScreenState extends State<SurpriseEggScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap(SurpriseEggProvider provider) {
    if (provider.isRevealed) return;
    _shakeController.forward(from: 0);
    provider.handleTap();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SurpriseEggProvider(category: widget.category),
      child: Consumer<SurpriseEggProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: provider.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackButton(color: provider.textColor),
              title: Text(
                'Sürpriz Yumurta',
                style: TextStyle(
                  color: provider.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!provider.isRevealed)
                        GestureDetector(
                          onTap: () => _handleTap(provider),
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                EggWidget(
                                  eggColor: provider.eggColor,
                                  patternColor: provider.patternColor,
                                  patternType: provider.patternType,
                                ),
                                if (provider.crackLevel > 0)
                                  CustomPaint(
                                    size: const Size(250, 320),
                                    painter: CrackPainter(
                                      level: provider.crackLevel,
                                    ),
                                  ),
                                if (provider.crackLevel == 0)
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
                                            .animate(
                                              onPlay:
                                                  (c) =>
                                                      c.repeat(reverse: true),
                                            )
                                            .scale(
                                              begin: const Offset(1, 1),
                                              end: const Offset(1.2, 1.2),
                                              duration: 600.ms,
                                            )
                                            .moveY(
                                              begin: 0,
                                              end: -10,
                                              duration: 600.ms,
                                            ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "DOKUN",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
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
                          ),
                        )
                      else
                        _buildRevealedContent(provider),
                    ],
                  ),
                ),

                // Confetti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: provider.confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevealedContent(SurpriseEggProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scaling Reveal Animation
        Container(
          child:
              provider.targetItem.imagePath != null
                  ? Image.asset(
                    provider.targetItem.imagePath!,
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  )
                  : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: provider.targetItem.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 30),

        Text(
          provider.targetItem.nameTr.toUpperCase(),
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: provider.textColor,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
      ],
    );
  }
}
