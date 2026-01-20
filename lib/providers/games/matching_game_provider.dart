import 'package:flutter/material.dart';
import '../../models/data_models.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class MatchingGameProvider extends ChangeNotifier {
  final Category category;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  List<LearningItem> _currentItems = [];
  List<LearningItem> _draggableItems =
      []; // Separate list for shuffled draggable items
  final Map<String, bool> _matchedItems = {};
  bool _isGameComplete = false;

  // Getters
  List<LearningItem> get currentItems => _currentItems;
  List<LearningItem> get draggableItems => _draggableItems;
  Map<String, bool> get matchedItems => _matchedItems;
  bool get isGameComplete => _isGameComplete;

  MatchingGameProvider({required this.category}) {
    startNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void startNewRound() {
    _matchedItems.clear();
    _isGameComplete = false;

    // Pick 3 random items
    final allItems = List<LearningItem>.from(category.items);
    allItems.shuffle(_random);
    _currentItems = allItems.take(3).toList();

    // Prepare draggable items (shuffled version of current items)
    _draggableItems = List.from(_currentItems)..shuffle(_random);

    notifyListeners();
  }

  Future<void> handleMatch(LearningItem item) async {
    _matchedItems[item.id] = true;
    notifyListeners();

    try {
      if (item.audioPath.isNotEmpty) {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(item.audioPath));
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('audio/effects/correct.mp3'));
      }
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }

    if (_matchedItems.length == _currentItems.length) {
      _isGameComplete = true;
      notifyListeners();

      Future.delayed(const Duration(seconds: 2), () {
        startNewRound();
      });
    }
  }

  bool isItemMatched(String id) {
    return _matchedItems.containsKey(id);
  }
}
