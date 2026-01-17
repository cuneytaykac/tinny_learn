import 'package:flutter/material.dart';
import '../../models/data_models.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'dart:math';

class MatchingScreen extends StatefulWidget {
  final Category category;

  const MatchingScreen({super.key, required this.category});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<LearningItem> _currentItems = [];
  final Map<String, bool> _matchedItems = {};
  bool _isGameComplete = false;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      // Pick 3 random items from the category
      final random = Random();
      final allItems = List<LearningItem>.from(widget.category.items);
      allItems.shuffle(random);
      _currentItems = allItems.take(3).toList();
      _matchedItems.clear();
      _isGameComplete = false;
    });
  }

  Future<void> _handleMatch(LearningItem item) async {
    setState(() {
      _matchedItems[item.id] = true;
    });

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
      setState(() {
        _isGameComplete = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _startNewRound();
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppTheme.primaryTextColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Eşleştirme Oyunu",
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _currentItems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Column(
                    children: [
                      // Top Section: Targets (Images)
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              _currentItems.map((item) {
                                final isMatched = _matchedItems.containsKey(
                                  item.id,
                                );
                                return DragTarget<LearningItem>(
                                  onWillAccept: (data) => data?.id == item.id,
                                  onAccept: (data) => _handleMatch(item),
                                  builder: (
                                    context,
                                    candidateData,
                                    rejectedData,
                                  ) {
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color:
                                              isMatched
                                                  ? Colors.green
                                                  : (candidateData.isNotEmpty
                                                      ? Colors.amber
                                                      : Colors.blue.shade100),
                                          width: isMatched ? 4 : 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child:
                                          isMatched
                                              ? Center(
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.green,
                                                  size: 60,
                                                ),
                                              ).animate().scale(
                                                curve: Curves.elasticOut,
                                              )
                                              : Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child:
                                                    item.imagePath != null
                                                        ? Image.asset(
                                                          item.imagePath!,
                                                        )
                                                        : const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color: Colors.grey,
                                                        ),
                                              ),
                                    );
                                  },
                                );
                              }).toList(),
                        ),
                      ),

                      // Arrow Indicator
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        ),
                      ),

                      // Bottom Section: Draggables (Solid Colors)
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              _currentItems.map((item) {
                                  final isMatched = _matchedItems.containsKey(
                                    item.id,
                                  );
                                  return isMatched
                                      ? const SizedBox(
                                        width: 80,
                                        height: 80,
                                      ) // Invisible placeholder
                                      : Draggable<LearningItem>(
                                        data: item,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              color: item.color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 4,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: item.color.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: item.color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                }).toList()
                                ..shuffle(
                                  Random(),
                                ), // Shuffle draggables position
                        ),
                      ),
                    ],
                  ),

                  // Success Overlay
                  if (_isGameComplete)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 80,
                            ).animate().scale(
                              duration: 500.ms,
                              curve: Curves.elasticOut,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Harika!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
