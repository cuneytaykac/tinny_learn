import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../models/animal/animals.dart';
import '../models/vehicle/vehicle.dart';
import '../data/local/local.dart';
import '../data/mock_data.dart';

class GameProvider with ChangeNotifier {
  List<Category> _categories = AppData.categories;
  List<String> _unlockedCategoryIds = ['animals']; // Default unlocked
  bool _isSoundOn = true;

  List<Category> get categories => _categories;
  bool get isSoundOn => _isSoundOn;

  final _animalLocalService = AnimalLocalService();
  final _vehicleLocalService = VehicleLocalService();

  GameProvider() {
    _loadPreferences();
    _loadDynamicCategories();
  }

  Future<void> _loadDynamicCategories() async {
    try {
      final animals = await _animalLocalService.getAnimals();
      final vehicles = await _vehicleLocalService.getVehicles();

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

      List<Category> newCategories = [];

      // Reconstruct Categories list
      // Use existing static categories if dynamic lists are empty (fallback)
      // Otherwise replace them.

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
      } else {
        // Fallback to static if cache is empty
        final staticAnimals = _categories.firstWhere((c) => c.id == 'animals');
        newCategories.add(staticAnimals);
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
      } else {
        final staticVehicles = _categories.firstWhere(
          (c) => c.id == 'vehicles',
        );
        newCategories.add(staticVehicles);
      }

      // Add other static categories (Colors, Flags)
      // Filter out existing ones to avoid duplicates if we just appended
      // Since AppData.categories has all, we should pick the others.
      final otherCategories =
          AppData.categories
              .where((c) => c.id != 'animals' && c.id != 'vehicles')
              .toList();
      newCategories.addAll(otherCategories);

      _categories = newCategories;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dynamic categories: $e');
    }
  }

  bool isCategoryUnlocked(String id) {
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
