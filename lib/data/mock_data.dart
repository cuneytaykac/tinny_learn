import 'package:flutter/material.dart';
import '../models/data_models.dart';

class AppData {
  static const List<Category> categories = [
    Category(
      id: 'animals',
      nameTr: 'Hayvanlar',
      nameEn: 'Animals',
      iconPath: 'assets/images/animals/cat.png', // Placeholder
      color: Color(0xFFFFE082), // Amber
      isPremium: false,
      items: [
        LearningItem(
          id: 'cat',
          nameTr: 'Kedi',
          nameEn: 'Cat',
          imagePath: 'assets/images/animals/cat.png',
          audioPath: 'audio/animals/cat.mp3',
          color: Color(0xFFFFECB3),
        ),
        LearningItem(
          id: 'dog',
          nameTr: 'Köpek',
          nameEn: 'Dog',
          imagePath: 'assets/images/animals/dog.png',
          audioPath: 'audio/animals/dog.mp3',
          color: Color(0xFFD7CCC8),
        ),
        LearningItem(
          id: 'lion',
          nameTr: 'Aslan',
          nameEn: 'Lion',
          imagePath: 'assets/images/animals/lion.png',
          audioPath: 'audio/animals/lion.mp3',
          color: Color(0xFFFFCC80),
        ),
        LearningItem(
          id: 'elephant',
          nameTr: 'Fil',
          nameEn: 'Elephant',
          imagePath: 'assets/images/animals/elephant.png',
          audioPath: 'audio/animals/elephant.mp3',
          color: Color(0xFFCFD8DC),
        ),
        LearningItem(
          id: 'giraffe',
          nameTr: 'Zürafa',
          nameEn: 'Giraffe',
          imagePath: 'assets/images/animals/giraffe.png',
          audioPath: 'audio/animals/giraffe.mp3',
          color: Color(0xFFFFF59D),
        ),
        LearningItem(
          id: 'monkey',
          nameTr: 'Maymun',
          nameEn: 'Monkey',
          imagePath: 'assets/images/animals/monkey.png',
          audioPath: 'audio/animals/monkey.mp3',
          color: Color(0xFFFFCCBC),
        ),
        LearningItem(
          id: 'cow',
          nameTr: 'İnek',
          nameEn: 'Cow',
          imagePath: 'assets/images/animals/cow.png',
          audioPath: 'audio/animals/cow.mp3',
          color: Color(0xFFE1F5FE),
        ),
        LearningItem(
          id: 'sheep',
          nameTr: 'Koyun',
          nameEn: 'Sheep',
          imagePath: 'assets/images/animals/sheep.png',
          audioPath: 'audio/animals/sheep.mp3',
          color: Color(0xFFFAFAFA),
        ),
        LearningItem(
          id: 'chicken',
          nameTr: 'Tavuk',
          nameEn: 'Chicken',
          imagePath: 'assets/images/animals/chicken.png',
          audioPath: 'audio/animals/chicken.mp3',
          color: Color(0xFFFFE0B2),
        ),
        LearningItem(
          id: 'horse',
          nameTr: 'At',
          nameEn: 'Horse',
          imagePath: 'assets/images/animals/horse.png',
          audioPath: 'audio/animals/horse.mp3',
          color: Color(0xFFA1887F),
        ),
        LearningItem(
          id: 'tiger',
          nameTr: 'Kaplan',
          nameEn: 'Tiger',
          imagePath: 'assets/images/animals/tiger.png',
          audioPath: 'audio/animals/tiger.mp3',
          color: Color(0xFFFFCC80),
        ),
        LearningItem(
          id: 'rabbit',
          nameTr: 'Tavşan',
          nameEn: 'Rabbit',
          imagePath: 'assets/images/animals/rabbit.png',
          audioPath: 'audio/animals/rabbit.mp3',
          color: Color(0xFFE0E0E0),
        ),
        LearningItem(
          id: 'bear',
          nameTr: 'Ayı',
          nameEn: 'Bear',
          imagePath: 'assets/images/animals/bear.png',
          audioPath: 'audio/animals/bear.mp3',
          color: Color(0xFFD7CCC8),
        ),
        LearningItem(
          id: 'frog',
          nameTr: 'Kurbağa',
          nameEn: 'Frog',
          imagePath: 'assets/images/animals/frog.png',
          audioPath: 'audio/animals/frog.mp3',
          color: Color(0xFFC8E6C9),
        ),
        LearningItem(
          id: 'bee',
          nameTr: 'Arı',
          nameEn: 'Bee',
          imagePath: 'assets/images/animals/bee.png',
          audioPath: 'audio/animals/bee.mp3',
          color: Color(0xFFFFF9C4),
        ),
        LearningItem(
          id: 'butterfly',
          nameTr: 'Kelebek',
          nameEn: 'Butterfly',
          imagePath: 'assets/images/animals/butterfly.png',
          audioPath: 'audio/animals/butterfly.mp3',
          color: Color(0xFFE1BEE7),
        ),
      ],
    ),
    Category(
      id: 'vehicles',
      nameTr: 'Taşıtlar',
      nameEn: 'Vehicles',
      iconPath: 'assets/images/vehicles/car.png',
      color: Color(0xFF90CAF9), // Blue
      isPremium: true,
      items: [], // To be added later
    ),
  ];
}
