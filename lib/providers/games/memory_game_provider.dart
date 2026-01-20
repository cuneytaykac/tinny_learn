import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import '../../models/data_models.dart';

class MemoryCard {
  final String id;
  final LearningItem item;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.item,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

enum GameStatus { playing, won }

enum MoveResult { none, flip, match, win }

class MemoryGameProvider extends ChangeNotifier {
  final Category category;
  final Random _random = Random();

  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  List<MemoryCard> _cards = [];
  List<int> _flippedIndices = [];
  bool _isProcessing = false;

  // Timer
  Timer? _timer;
  int _elapsedSeconds = 0;
  GameStatus _status = GameStatus.playing;
  int _stateVersion = 0;

  // Getters
  List<MemoryCard> get cards => _cards;
  int get elapsedSeconds => _elapsedSeconds;
  GameStatus get status => _status;
  bool get isProcessing => _isProcessing;
  ConfettiController get confettiController => _confettiController;
  int get stateVersion => _stateVersion;

  MemoryGameProvider({required this.category}) {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String get formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void restartGame() {
    _startNewGame();
  }

  void _startNewGame() {
    _status = GameStatus.playing;
    _isProcessing = false;
    _flippedIndices.clear();
    _stateVersion++;

    // Select 3 random items
    final allItems = List<LearningItem>.from(category.items);
    allItems.shuffle(_random);
    final selectedItems = allItems.take(3).toList();

    // Create pairs
    _cards = [];
    for (var item in selectedItems) {
      _cards.add(MemoryCard(id: item.id, item: item));
      _cards.add(MemoryCard(id: item.id, item: item));
    }

    _cards.shuffle(_random);
    _startTimer();
    notifyListeners();
  }

  Future<MoveResult> onCardTap(int index) async {
    if (_isProcessing ||
        _cards[index].isFlipped ||
        _cards[index].isMatched ||
        _status == GameStatus.won) {
      return MoveResult.none;
    }

    _cards[index].isFlipped = true;
    _flippedIndices.add(index);
    _stateVersion++;
    notifyListeners();

    // Play flip sound (optional, keeps UI snappy if here or UI side)
    // we'll leave simple feedback to UI or play here.
    // Let's rely on UI for immediate feedback triggers if needed, or play here.
    // _audioPlayer.play... (maybe skip flip sound for now or add later)

    if (_flippedIndices.length == 2) {
      return await _checkForMatch();
    }

    return MoveResult.flip;
  }

  Future<MoveResult> _checkForMatch() async {
    _isProcessing = true;
    _stateVersion++;
    notifyListeners();

    final index1 = _flippedIndices[0];
    final index2 = _flippedIndices[1];
    final card1 = _cards[index1];
    final card2 = _cards[index2];

    if (card1.id == card2.id) {
      // Match found
      await Future.delayed(const Duration(milliseconds: 300));
      card1.isMatched = true;
      card2.isMatched = true;
      _flippedIndices.clear();
      _isProcessing = false;
      _stateVersion++;

      _playMatchSound();

      if (_checkWinCondition()) {
        _playWinSound();
        _confettiController.play();
        _status = GameStatus.won;
        _stateVersion++;
        notifyListeners();
        return MoveResult.win;
      }

      notifyListeners();
      return MoveResult.match;
    } else {
      // No match
      await Future.delayed(const Duration(milliseconds: 1000));
      card1.isFlipped = false;
      card2.isFlipped = false;
      _flippedIndices.clear();
      _isProcessing = false;
      _stateVersion++;
      notifyListeners();
      return MoveResult.none;
    }
  }

  bool _checkWinCondition() {
    if (_cards.every((card) => card.isMatched)) {
      stopTimer();
      return true;
    }
    return false;
  }

  Future<void> _playMatchSound() async {
    try {
      await _audioPlayer.play(AssetSource('ui/correct.mp3'));
    } catch (e) {
      debugPrint("Error playing match sound: $e");
    }
  }

  Future<void> _playWinSound() async {
    try {
      await _audioPlayer.play(AssetSource('ui/applause.mp3'));
    } catch (e) {
      debugPrint("Error playing win sound: $e");
    }
  }
}
