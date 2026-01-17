import 'package:flutter/material.dart';

class LearningItem {
  final String id;
  final String nameTr;
  final String nameEn;
  final String? imagePath;
  final String audioPath;
  final Color color;

  const LearningItem({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    this.imagePath,
    required this.audioPath,
    this.color = Colors.white,
  });
}

class Category {
  final String id;
  final String nameTr;
  final String nameEn;
  final String iconPath;
  final Color color;
  final bool isPremium;
  final List<LearningItem> items;

  const Category({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.iconPath,
    required this.color,
    this.isPremium = false,
    required this.items,
  });
}
