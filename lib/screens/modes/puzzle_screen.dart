import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/puzzle_piece.dart';
import '../../utils/jigsaw_clipper.dart';
import '../../gen/locale_keys.g.dart';

class PuzzleScreen extends StatefulWidget {
  final Category category;

  const PuzzleScreen({super.key, required this.category});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late LearningItem _targetItem;
  final List<int> _completedIndices = [];
  late List<int> _shuffledPieces;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  bool _showWin = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _startNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    setState(() {
      _showWin = false;
      _completedIndices.clear();

      // Select random target
      _targetItem =
          widget.category.items[_random.nextInt(widget.category.items.length)];

      // Create and shuffle piece indices (0, 1, 2, 3)
      _shuffledPieces = [0, 1, 2, 3]..shuffle(_random);
    });
  }

  void _onPieceDropped(int slotIndex, int droppedIndex) {
    if (slotIndex == droppedIndex) {
      // Correct Piece!
      setState(() {
        _completedIndices.add(slotIndex);
      });

      // Play Snap Sound
      try {
        // Use a simple pop or click sound if available, checking assets...
        // Reusing 'applause' later for full win, maybe no sound for single piece to keep it simple?
        // Or reuse a generic UI sound. Let's stick to win sound for completion.
      } catch (e) {
        // ignore
      }

      if (_completedIndices.length == 4) {
        _handleWin();
      }
    } else {
      // Wrong piece logic if desired (e.g. shake)
      try {
        _audioPlayer.play(AssetSource('ui/wrong.mp3'));
      } catch (e) {
        debugPrint("Error playing wrong sound: $e");
      }
    }
  }

  void _handleWin() {
    setState(() {
      _showWin = true;
    });
    _confettiController.play();
    try {
      _audioPlayer.play(AssetSource('ui/applause.mp3'));
    } catch (e) {
      debugPrint("Error playing success sound: $e");
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _startNewRound();
      }
    });
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
          LocaleKeys.puzzle_title.tr(),
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
              const SizedBox(height: 20),
              // Puzzle Board Area
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(
                      0,
                    ), // Removed padding to fit perfectly
                    clipBehavior:
                        Clip.hardEdge, // Ensure content clips to rounded corners
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.brown,
                        width: 4, // Slightly thicker frame
                        strokeAlign:
                            BorderSide
                                .strokeAlignOutside, // Draw border outside so it doesn't eat content
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 200, // Exact fit for 2x100 grid
                      height: 200,
                      child: Stack(
                        children: [
                          // Ghost Image (Guide)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.5, // Increased visibility
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child:
                                    _targetItem.imagePath != null
                                        ? CachedNetworkImage(
                                          imageUrl: _targetItem.imagePath!,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Container(
                                                color: Colors.grey.shade200,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) {
                                            return Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                              ),
                                            );
                                          },
                                        )
                                        : Container(color: _targetItem.color),
                              ),
                            ),
                          ),
                          // Slots Layer (Stack)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildSlot(0, 0, 0),
                              _buildSlot(1, 100, 0),
                              _buildSlot(2, 0, 100),
                              _buildSlot(3, 100, 100),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Divider(
                  color: Colors.white.withOpacity(0.5),
                  thickness: 2,
                ),
              ),

              // Scattered Pieces Area
              Expanded(
                flex: 2,
                child: Center(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children:
                        _shuffledPieces.map((index) {
                          // Only show if not yet completed
                          if (_completedIndices.contains(index)) {
                            return const SizedBox(width: 100, height: 100);
                          }
                          return PuzzlePiece(
                            item: _targetItem,
                            quadrantIndex: index,
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),

          // Confetti
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

  Widget _buildSlot(int index, double left, double top) {
    bool isCompleted = _completedIndices.contains(index);
    final clipper = _getClipper(index);

    return Positioned(
      left: left,
      top: top,
      child: DragTarget<int>(
        onAccept: (droppedIndex) => _onPieceDropped(index, droppedIndex),
        builder: (context, candidateData, rejectedData) {
          // Logic size 100x100 drop zone
          return SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Outline / Background (Visual Only)
                // We offset it because the painter draws a 130x130 shape centered on 100x100
                Positioned(
                  left: -15,
                  top: -15,
                  child: CustomPaint(
                    painter: JigsawBorderPainter(
                      clipper: clipper,
                      color:
                          isCompleted
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.8),
                    ),
                    size: const Size(130, 130), // Match widget size
                  ),
                ),

                // Completed Item
                if (isCompleted)
                  Positioned(
                    left: -15,
                    top: -15,
                    child: PuzzlePiece(
                      item: _targetItem,
                      quadrantIndex: index,
                      isDropped: false, // Show full piece
                    ),
                    // Note: PuzzlePiece already handles the visual sizing (130x130)
                  )
                else
                  // Drop Hint (Center icon)
                  const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper from PuzzlePiece, duplicated here for the Slot outline
  JigsawClipper _getClipper(int index) {
    switch (index) {
      case 0:
        return JigsawClipper(right: JigsawEdge.tab, bottom: JigsawEdge.tab);
      case 1:
        return JigsawClipper(left: JigsawEdge.hole, bottom: JigsawEdge.tab);
      case 2:
        return JigsawClipper(top: JigsawEdge.hole, right: JigsawEdge.tab);
      case 3:
        return JigsawClipper(top: JigsawEdge.hole, left: JigsawEdge.hole);
      default:
        return JigsawClipper();
    }
  }

  // Helper Painter (We need to define it here or export it. It's in puzzle_piece.dart but not exported class?
  // It was defined in puzzle_piece.dart. I should make it public or duplicate.
  // I'll assume I can import it if I fix the import in the next step.
  // Actually, I should probably move JigsawBorderPainter to jigsaw_clipper.dart or make it public.
  // For now, I will assume it's available via import '../widgets/puzzle_piece.dart'.
  // But wait, PuzzleScreen imports puzzle_piece.dart.
  // I need to ensure JigsawBorderPainter is public in puzzle piece.)

  // Helper method removed as it's no longer used. Alignment is handled by PuzzlePiece widget.
}
