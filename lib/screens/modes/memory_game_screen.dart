import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:country_flags_pro/country_flags_pro.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';

class MemoryGameScreen extends StatefulWidget {
  final Category category;

  const MemoryGameScreen({super.key, required this.category});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryCard {
  final String id;
  final LearningItem item;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.id,
    required this.item,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  final Random _random = Random();

  List<_MemoryCard> _cards = [];
  int _flipCount = 0;
  List<int> _flippedIndices = [];
  bool _isProcessing = false;

  // Timer
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isGameActive = false;

  @override
  void initState() {
    super.initState();
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

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _isGameActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isGameActive = false;
  }

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _startNewGame() {
    setState(() {
      _isProcessing = false;
      _flipCount = 0;
      _flippedIndices.clear();

      // Select 3 random items
      final allItems = List<LearningItem>.from(widget.category.items);
      allItems.shuffle(_random);
      final selectedItems = allItems.take(3).toList();

      // Create pairs
      _cards = [];
      for (var item in selectedItems) {
        _cards.add(_MemoryCard(id: item.id, item: item));
        _cards.add(_MemoryCard(id: item.id, item: item));
      }

      _cards.shuffle(_random);
      _startTimer();
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing ||
        _cards[index].isFlipped ||
        _cards[index].isMatched ||
        !_isGameActive) {
      return;
    }

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndices.add(index);
    });

    _playFlipSound();

    if (_flippedIndices.length == 2) {
      _checkForMatch();
    }
  }

  void _checkForMatch() async {
    _isProcessing = true;
    final index1 = _flippedIndices[0];
    final index2 = _flippedIndices[1];
    final card1 = _cards[index1];
    final card2 = _cards[index2];

    if (card1.id == card2.id) {
      // Match found
      await Future.delayed(const Duration(milliseconds: 300));
      _playMatchSound();
      setState(() {
        card1.isMatched = true;
        card2.isMatched = true;
        _flippedIndices.clear();
        _isProcessing = false;
      });

      _checkWinCondition();
    } else {
      // No match
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          card1.isFlipped = false;
          card2.isFlipped = false;
          _flippedIndices.clear();
          _isProcessing = false;
        });
      }
    }
  }

  void _checkWinCondition() {
    if (_cards.every((card) => card.isMatched)) {
      _stopTimer();
      _confettiController.play();
      _playWinSound();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Column(
              children: [
                const Text("🎉 Tebrikler! 🎉", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(
                  "Süre: $_formattedTime",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Tüm bayrakları eşleştirdin!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: const Text(
                  "Çıkış",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startNewGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Tekrar Oyna",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _playFlipSound() async {
    try {
      // Simulating flip sound with existing pop or tap sound if available
      // Or just silence if no specific flip sound
    } catch (e) {
      debugPrint("Error playing flip sound: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.category.color.withOpacity(0.1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppTheme.primaryTextColor,
          onPressed: () {
            _stopTimer();
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Hafıza Oyunu",
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              // Timer Container moved to body
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_rounded,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color:
                                card.isFlipped || card.isMatched
                                    ? Colors.white
                                    : Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child:
                              card.isFlipped || card.isMatched
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio: 1.6,
                                          child: CountryFlagsPro.getFlag(
                                            card.item.id.toLowerCase(),
                                            fit: BoxFit.cover,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  : Center(
                                    child: Icon(
                                      Icons.question_mark_rounded,
                                      size: 50,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _ononCardTap(int index) => _onCardTap(index);
}
