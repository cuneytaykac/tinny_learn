import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../models/data_models.dart';

class SurpriseEggProvider extends ChangeNotifier {
  final Category category;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  // Game State
  late LearningItem _targetItem;
  int _crackLevel = 0; // 0: Intact, 1: Cracked, 2: More Cracked, 3: Broken
  bool _isRevealed = false;

  // Visuals
  Color _eggColor = Colors.white;
  Color _patternColor = Colors.grey;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  int _patternType = 0;

  // Getters
  LearningItem get targetItem => _targetItem;
  int get crackLevel => _crackLevel;
  bool get isRevealed => _isRevealed;
  ConfettiController get confettiController => _confettiController;

  Color get eggColor => _eggColor;
  Color get patternColor => _patternColor;
  Color get backgroundColor => _backgroundColor;
  Color get textColor => _textColor;
  int get patternType => _patternType;

  SurpriseEggProvider({required this.category}) {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    startNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void startNewRound() {
    _crackLevel = 0;
    _isRevealed = false;
    _targetItem = category.items[_random.nextInt(category.items.length)];

    // 1. Pick a vibrant base color (HSL)
    double hue = _random.nextDouble() * 360;
    final saturation = 0.65 + _random.nextDouble() * 0.35;
    final lightness = 0.45 + _random.nextDouble() * 0.25;

    final hsl = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
    _eggColor = hsl.toColor();

    // 2. Pattern
    _patternType = _random.nextInt(4);
    if (_random.nextBool()) {
      _patternColor = Colors.white.withValues(alpha: 0.35);
    } else {
      _patternColor = hsl
          .withLightness(lightness + 0.2)
          .toColor()
          .withValues(alpha: 0.5);
    }

    // 3. Background
    _backgroundColor = hsl
        .withLightness(0.92)
        .withSaturation(0.3)
        .toColor()
        .withValues(alpha: 0.3);

    // 4. Text
    _textColor = hsl
        .withLightness(0.2)
        .withSaturation(0.8)
        .toColor()
        .withValues(alpha: 0.8);

    notifyListeners();
  }

  void handleTap() {
    if (_isRevealed) return;

    _crackLevel++;
    notifyListeners();

    if (_crackLevel < 3) {
      // Tap Sound
      // try { _audioPlayer.play(AssetSource('ui/tap.mp3')); } catch (_) {}
    } else {
      _revealSurprise();
    }
  }

  void _revealSurprise() {
    _isRevealed = true;
    _confettiController.play();
    notifyListeners();

    try {
      _audioPlayer.play(AssetSource('ui/applause.mp3'));
    } catch (_) {}

    Future.delayed(const Duration(seconds: 4), startNewRound);
  }
}
