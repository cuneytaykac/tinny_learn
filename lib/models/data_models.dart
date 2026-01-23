import 'package:flutter/material.dart';

class LearningItem {
  final String id;
  final String name;
  final String? imagePath;
  final String audioPath;
  final Color color;

  const LearningItem({
    required this.id,
    required this.name,
    this.imagePath,
    required this.audioPath,
    this.color = Colors.white,
  });
}

enum CategoryType { image, solidColor, flag }

class Category {
  final String id;
  final String name;
  final String iconPath;
  final Color color;
  final bool isPremium;
  final List<LearningItem> items;
  final CategoryType type;

  const Category({
    required this.id,
    required this.name,

    required this.iconPath,
    required this.color,
    this.isPremium = false,
    required this.items,
    this.type = CategoryType.image,
  });
}
