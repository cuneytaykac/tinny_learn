import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late LearningItem _targetItem;
  late List<LearningItem> _options;
  final Random _random = Random();
  bool _isAnswered = false;

  // Visual feedback state
  String? _selectedItemId;
  bool _isCorrect = false;
  late ConfettiController _confettiController;

  // Audio & TTS
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _initTts();
    _startNewRound();
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

  void _startNewRound() {
    setState(() {
      _isAnswered = false;
      _selectedItemId = null;
      _isCorrect = false;

      // Select a random target
      _targetItem =
          widget.category.items[_random.nextInt(widget.category.items.length)];

      // Select 2 distractors (different from target)
      final distractors =
          List<LearningItem>.from(widget.category.items)
            ..removeWhere((item) => item.id == _targetItem.id)
            ..shuffle();

      _options = [_targetItem, ...distractors.take(2)]..shuffle();
    });

    // Play the question sound after a short delay (1.5s)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _playQuestionSound();
    });
  }

  Future<void> _playQuestionSound() async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(AssetSource(_targetItem.audioPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _handleOptionTap(LearningItem item) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedItemId = item.id;
      _isCorrect = item.id == _targetItem.id;
    });

    if (_isCorrect) {
      // Correct Answer Logic
      _confettiController.play();
      // Play success sound
      try {
        _audioPlayer.play(AssetSource('ui/applause.mp3'));
      } catch (e) {
        debugPrint("Error playing success sound: $e");
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _startNewRound();
      });
    } else {
      // Wrong Answer Logic
      // Play error sound
      try {
        _audioPlayer.play(AssetSource('ui/wrong.mp3'));
      } catch (e) {
        debugPrint("Error playing wrong sound: $e");
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isAnswered = false;
            _selectedItemId = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.category.color,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.primaryTextColor),
        title: Text(
          '${widget.category.nameTr} Bulmaca',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: _playQuestionSound,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.volume_up_rounded,
                          size: 40,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            'Hangisi "${_targetItem.nameTr}"?',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children:
                            _options.map((item) {
                              final isSelected = _selectedItemId == item.id;
                              final isWrong = isSelected && !_isCorrect;
                              final isRight = isSelected && _isCorrect;

                              return GestureDetector(
                                onTap: () => _handleOptionTap(item),
                                child: Animate(
                                  target: isWrong ? 1 : 0,
                                  effects: [ShakeEffect()],
                                  child: Container(
                                    width: constraints.maxWidth * 0.4,
                                    height: constraints.maxWidth * 0.4,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border:
                                          isRight
                                              ? Border.all(
                                                color: Colors.green,
                                                width: 4,
                                              )
                                              : isWrong
                                              ? Border.all(
                                                color: Colors.red,
                                                width: 4,
                                              )
                                              : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child:
                                              item.imagePath != null
                                                  ? Image.asset(
                                                    item.imagePath!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (c, o, s) => Icon(
                                                          Icons.help_outline,
                                                          size: 50,
                                                          color: item.color,
                                                        ),
                                                  )
                                                  : Container(
                                                    decoration: BoxDecoration(
                                                      color: item.color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
              ),
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
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
