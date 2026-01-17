import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';

class FlashcardScreen extends StatefulWidget {
  final Category category;

  const FlashcardScreen({super.key, required this.category});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final PageController _pageController = PageController();
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speak(String text, String language) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  Future<void> _playSound(String audioPath) async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.category.color, // Matched category color exactly
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(
          color: AppTheme.primaryTextColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.nameTr,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.category.items.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) async {
                // Stop any playing sound immediately when page changes
                await _audioPlayer.stop();
                await _flutterTts.stop();
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = widget.category.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  child: FlashcardItem(
                    item: item,
                    onSpeak: _speak,
                    onPlaySound: () => _playSound(item.audioPath),
                    isVisible: _currentIndex == index,
                  ),
                );
              },
            ),
          ),

          // Pagination Dots
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.category.items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color:
                        _currentIndex == index
                            ? AppTheme.primaryTextColor
                            : Colors.black26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardItem extends StatelessWidget {
  final LearningItem item;
  final Function(String, String) onSpeak;
  final VoidCallback onPlaySound;
  final bool isVisible;

  const FlashcardItem({
    super.key,
    required this.item,
    required this.onSpeak,
    required this.onPlaySound,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      target: isVisible ? 1 : 0,
      effects: [
        FadeEffect(duration: 400.ms),
        ScaleEffect(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: GestureDetector(
                      onTap: onPlaySound,
                      child: Hero(
                        tag: item.id,
                        child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (c, o, s) => _buildPlaceholder(context),
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scaleXY(
                      begin: 1.0,
                      end: 1.05,
                      duration: 2000.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Turkish Name Row
                  GestureDetector(
                    onTap: () => onSpeak(item.nameTr, "tr-TR"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.nameTr,
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(
                              color: AppTheme.primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.volume_up_rounded,
                            color: AppTheme.accentColor,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // English Name Row
                  GestureDetector(
                    onTap: () => onSpeak(item.nameEn, "en-US"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.nameEn,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.volume_up_rounded,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(40),
      child: Icon(
        Icons.image_not_supported_rounded,
        size: 80,
        color: item.color,
      ),
    );
  }
}
