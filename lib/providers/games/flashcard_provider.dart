import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/data_models.dart';

class FlashcardProvider extends ChangeNotifier {
  final Category category;

  // Controllers & Services
  final PageController pageController = PageController();
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // State
  int _currentIndex = 0;

  // Getters
  int get currentIndex => _currentIndex;

  FlashcardProvider({required this.category}) {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    pageController.dispose();
    _flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void onPageChanged(int index) async {
    // Stop any playing sound immediately when page changes
    await _audioPlayer.stop();
    await _flutterTts.stop();
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> speak(String text, String language) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  Future<void> playSound(String audioPath) async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }
}
