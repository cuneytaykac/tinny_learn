import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../models/animal/animals.dart';
import '../models/vehicle/vehicle.dart';
import '../data/local/local.dart';

class GameProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<String> _unlockedCategoryIds = ['animals']; // Default unlocked
  bool _isSoundOn = true;

  List<Category> get categories => _categories;
  bool get isSoundOn => _isSoundOn;

  final _animalLocalService = AnimalLocalService();
  final _vehicleLocalService = VehicleLocalService();
  final _colorLocalService = ColorLocalService();

  GameProvider() {
    _loadPreferences();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final animals = await _animalLocalService.getAnimals();
      final vehicles = await _vehicleLocalService.getVehicles();
      final colors = await _colorLocalService.getColors();

      // We need to rebuild the categories list
      // 1. Animals
      final animalItems =
          animals.map((a) {
            return LearningItem(
              id: a.name ?? 'unknown',
              name: a.name ?? '',
              imagePath: a.imagePath ?? '',
              audioPath: a.audioPath ?? '',
              color: Color(0xFFFFF176), // Default yellow-ish
            );
          }).toList();

      // 2. Vehicles
      final vehicleItems =
          vehicles.map((v) {
            return LearningItem(
              id: v.name ?? 'unknown',
              name: v.name ?? '',
              imagePath: v.imagePath ?? '',
              audioPath: v.audioPath ?? '',
              color: Color(0xFF64B5F6), // Default blue-ish
            );
          }).toList();

      // 3. Colors
      final colorItems =
          colors.map((c) {
            String id = 'unknown';
            String name = 'Unknown';
            String audioPath = '';
            Color color = Colors.white;

            if (c.imagePath != null) {
              // Extract id from filename: .../black.png -> black
              final uri = Uri.parse(c.imagePath!);
              final filename = uri.pathSegments.last;
              id = filename.split('.').first;

              // Fallback to capitalized id
              name =
                  id.isEmpty ? '' : '${id[0].toUpperCase()}${id.substring(1)}';

              // Map color from ID
              color = _getColorForId(id);
            }

            return LearningItem(
              id: id,
              name: name,
              imagePath: c.imagePath,
              audioPath: audioPath,
              color: color,
            );
          }).toList();

      List<Category> newCategories = [];

      // Animals Category
      if (animalItems.isNotEmpty) {
        newCategories.add(
          Category(
            id: 'animals',
            name: 'Hayvanlar',
            iconPath: 'assets/images/animals/cat.webp',
            color: Color(0xFFFFE082),
            isPremium: false,
            items: animalItems,
          ),
        );
      }

      // Vehicles Category
      if (vehicleItems.isNotEmpty) {
        newCategories.add(
          Category(
            id: 'vehicles',
            name: 'Taşıtlar',
            iconPath: 'assets/images/vehicles/car.webp',
            color: Color(0xFF90CAF9),
            isPremium: false,
            items: vehicleItems,
          ),
        );
      }

      // Colors Category
      if (colorItems.isNotEmpty) {
        newCategories.add(
          Category(
            id: 'colors',
            name: 'Renkler',
            iconPath: 'assets/images/colors/colors_icon.webp',
            color: const Color(0xFFEEEEEE),
            isPremium: false,
            type: CategoryType.image,
            items: colorItems,
          ),
        );
      }

      // Add other static categories (Flags)
      newCategories.add(_getFlagsCategory());

      _categories = newCategories;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dynamic categories: $e');
    }
  }

  Category _getFlagsCategory() {
    return Category(
      id: 'flags',
      name: 'Bayraklar',
      iconPath: 'assets/images/colors/colors_icon.webp', // Placeholder
      color: const Color(0xFFE1F5FE),
      isPremium: false,
      type: CategoryType.flag,
      items: [
        LearningItem(
          id: 'TR',
          name: 'Türkiye',
          imagePath: null,
          audioPath: 'audio/flags/tr.mp3',
          color: Colors.white,
        ),
        LearningItem(
          id: 'AZ',
          name: 'Azerbaycan',
          imagePath: null,
          audioPath: 'audio/flags/az.mp3',
          color: Colors.blue,
        ),
        LearningItem(
          id: 'US',
          name: 'Amerika',
          imagePath: null,
          audioPath: 'audio/flags/us.mp3',
          color: Colors.blue,
        ),
        LearningItem(
          id: 'DE',
          name: 'Almanya',
          imagePath: null,
          audioPath: 'audio/flags/de.mp3',
          color: Colors.yellow,
        ),
        LearningItem(
          id: 'FR',
          name: 'Fransa',
          imagePath: null,
          audioPath: 'audio/flags/fr.mp3',
          color: Colors.blue,
        ),
        LearningItem(
          id: 'GB',
          name: 'İngiltere',
          imagePath: null,
          audioPath: 'audio/flags/gb.mp3',
          color: Colors.red,
        ),
        LearningItem(
          id: 'IT',
          name: 'İtalya',
          imagePath: null,
          audioPath: 'audio/flags/it.mp3',
          color: Colors.green,
        ),
        LearningItem(
          id: 'RU',
          name: 'Rusya',
          imagePath: null,
          audioPath: 'audio/flags/ru.mp3',
          color: Colors.red,
        ),
        LearningItem(
          id: 'CN',
          name: 'Çin',
          imagePath: null,
          audioPath: 'audio/flags/cn.mp3',
          color: Colors.red,
        ),
        LearningItem(
          id: 'JP',
          name: 'Japonya',
          imagePath: null,
          audioPath: 'audio/flags/jp.mp3',
          color: Colors.white,
        ),
      ],
    );
  }

  Color _getColorForId(String id) {
    switch (id.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.white;
    }
  }

  bool isCategoryUnlocked(String id) {
    if (_categories.isEmpty) return false;
    // If it's not premium, it's always unlocked
    // Handle case where category might not exist temporarily during reload
    final category = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => _categories.first,
    );
    if (!category.isPremium) return true;

    return _unlockedCategoryIds.contains(id);
  }

  Future<void> unlockCategory(String id) async {
    if (!_unlockedCategoryIds.contains(id)) {
      _unlockedCategoryIds.add(id);
      notifyListeners();
      await _savePreferences();
    }
  }

  Future<void> unlockAll() async {
    for (var cat in _categories) {
      if (!_unlockedCategoryIds.contains(cat.id)) {
        _unlockedCategoryIds.add(cat.id);
      }
    }
    notifyListeners();
    await _savePreferences();
  }

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    notifyListeners();
    _savePreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _unlockedCategoryIds =
        prefs.getStringList('unlocked_categories') ?? ['animals'];
    _isSoundOn = prefs.getBool('is_sound_on') ?? true;
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlocked_categories', _unlockedCategoryIds);
    await prefs.setBool('is_sound_on', _isSoundOn);
  }
}
