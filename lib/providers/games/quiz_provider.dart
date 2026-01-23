import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/data_models.dart';

class QuizProvider extends ChangeNotifier {
  final Category category;

  // State
  late LearningItem _targetItem;
  List<LearningItem> _options = [];
  bool _isAnswered = false;
  String? _selectedItemId;
  bool _isCorrect = false;

  // Controllers
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  // Getters
  LearningItem get targetItem => _targetItem;
  List<LearningItem> get options => _options;
  bool get isAnswered => _isAnswered;
  String? get selectedItemId => _selectedItemId;
  bool get isCorrect => _isCorrect;
  ConfettiController get confettiController => _confettiController;

  QuizProvider({required this.category}) {
    _initTts();
    startNewRound();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void startNewRound() {
    _isAnswered = false;
    _selectedItemId = null;
    _isCorrect = false;

    // Select a random target
    _targetItem = category.items[_random.nextInt(category.items.length)];

    // Select distractors
    final distractors =
        List<LearningItem>.from(category.items)
          ..removeWhere((item) => item.id == _targetItem.id)
          ..shuffle();

    // 1 distractor for flags, 2 for others
    final int distractorCount = category.type == CategoryType.flag ? 1 : 2;

    _options = [_targetItem, ...distractors.take(distractorCount)]..shuffle();
    notifyListeners();

    // Play question sound after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      playQuestionSound();
    });
  }

  Future<void> playQuestionSound() async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
    try {
      if (_targetItem.audioPath.startsWith('http')) {
        await _audioPlayer.play(UrlSource(_targetItem.audioPath));
      } else {
        await _audioPlayer.play(AssetSource(_targetItem.audioPath));
      }
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void handleOptionTap(LearningItem item) {
    if (_isAnswered) return;

    _isAnswered = true;
    _selectedItemId = item.id;
    _isCorrect = item.id == _targetItem.id;
    notifyListeners();

    if (_isCorrect) {
      _confettiController.play();
      _playSound('ui/applause.mp3');

      Future.delayed(const Duration(seconds: 3), () {
        startNewRound();
      });
    } else {
      _playSound('ui/wrong.mp3');

      Future.delayed(const Duration(seconds: 1), () {
        _isAnswered = false;
        _selectedItemId = null;
        notifyListeners();
      });
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }
}
