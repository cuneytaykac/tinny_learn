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
  bool _isDisposed = false;

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

  QuizProvider({required this.category, required String locale}) {
    _initTts(locale);
    startNewRound();
  }

  Future<void> _initTts(String locale) async {
    final ttsLocale = locale == 'tr' ? 'tr-TR' : 'en-US';
    await _flutterTts.setLanguage(ttsLocale);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _flutterTts.stop();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void startNewRound() {
    if (_isDisposed) return;
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
      if (!_isDisposed) playQuestionSound();
    });
  }

  Future<void> playQuestionSound() async {
    if (_isDisposed || _targetItem.audioPath.isEmpty) return;
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }

      // Assume remote URL if it contains 'http', otherwise asset
      if (_targetItem.audioPath.contains('http')) {
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
        if (!_isDisposed) startNewRound();
      });
    } else {
      _playSound('ui/wrong.mp3');

      Future.delayed(const Duration(seconds: 1), () {
        if (!_isDisposed) {
          _isAnswered = false;
          _selectedItemId = null;
          notifyListeners();
        }
      });
    }
  }

  Future<void> _playSound(String assetPath) async {
    if (_isDisposed) return;
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }
}
