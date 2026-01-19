import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:country_flags_pro/country_flags_pro.dart';
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

      // Select distractors (1 for flags, 2 for others)
      final int distractorCount =
          widget.category.type == CategoryType.flag ? 1 : 2;

      _options = [_targetItem, ...distractors.take(distractorCount)]..shuffle();
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
                      final isFlag = widget.category.type == CategoryType.flag;
                      final optionsList =
                          _options.map((item) {
                            final isSelected = _selectedItemId == item.id;
                            final isWrong = isSelected && !_isCorrect;
                            final isRight = isSelected && _isCorrect;

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isFlag ? 12 : 0,
                              ),
                              child: GestureDetector(
                                onTap: () => _handleOptionTap(item),
                                child: Animate(
                                  target: isWrong ? 1 : 0,
                                  effects: [ShakeEffect()],
                                  child: Container(
                                    // Full width for flags, ~45% for others (Grid)
                                    width:
                                        isFlag
                                            ? 320
                                            : constraints.maxWidth * 0.45,
                                    height: isFlag ? 200 : 160,
                                    padding: const EdgeInsets.all(12),
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Builder(
                                        builder: (context) {
                                          switch (widget.category.type) {
                                            case CategoryType.flag:
                                              return Center(
                                                child: AspectRatio(
                                                  aspectRatio: 1.6,
                                                  child: CountryFlagsPro.getFlag(
                                                    item.id.toLowerCase(),
                                                    fit: BoxFit.cover,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            case CategoryType.solidColor:
                                              return Center(
                                                child: Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: item.color,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 5,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            case CategoryType.image:
                                            default:
                                              return item.imagePath != null
                                                  ? Image.asset(
                                                    item.imagePath!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons
                                                            .pets, // Cute placeholder for animals
                                                        size: 60,
                                                        color:
                                                            Colors.orangeAccent,
                                                      );
                                                    },
                                                  )
                                                  : const Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList();

                      return SingleChildScrollView(
                        child:
                            isFlag
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: optionsList,
                                )
                                : Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  children: optionsList,
                                ),
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
