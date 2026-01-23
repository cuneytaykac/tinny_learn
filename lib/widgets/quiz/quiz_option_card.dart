import 'package:flutter/material.dart';
import 'package:country_flags_pro/country_flags_pro.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/data_models.dart';

class QuizOptionCard extends StatelessWidget {
  final LearningItem item;
  final bool isSelected;
  final bool isCorrect;
  final bool isFlag;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const QuizOptionCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isCorrect,
    required this.isFlag,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isWrong = isSelected && !isCorrect;
    final isRight = isSelected && isCorrect;

    return GestureDetector(
      onTap: onTap,
      child: Animate(
        target: isWrong ? 1 : 0,
        effects: [ShakeEffect()],
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border:
                isRight
                    ? Border.all(color: Colors.green, width: 4)
                    : isWrong
                    ? Border.all(color: Colors.red, width: 4)
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
                if (isFlag) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: CountryFlagsPro.getFlag(
                        item.id.toLowerCase(),
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (item.imagePath == null && item.color != null) {
                  // Solid Color (CategoryType.solidColor logic inference)
                  // Ideally we should pass CategoryType, but checking color/image is a decent proxy if simple.
                  // Actually, checking if it's NOT an image path usually implies color if we don't handle flags.
                  // But let's assume 'color' property is valid for color category.
                  return Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Default Image
                if (item.imagePath != null) {
                  return CachedNetworkImage(
                    imageUrl: item.imagePath!,
                    fit: BoxFit.contain,
                    placeholder:
                        (context, url) => const Icon(
                          Icons.pets,
                          size: 60,
                          color: Colors.orangeAccent,
                        ),
                    errorWidget:
                        (context, url, error) => Image.asset(
                          item.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.pets,
                              size: 60,
                              color: Colors.orangeAccent,
                            );
                          },
                        ),
                  );
                } else {
                  return const Icon(
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
    );
  }
}
