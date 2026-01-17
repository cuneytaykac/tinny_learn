import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';
import '../data/mock_data.dart';

class GameProvider with ChangeNotifier {
  List<Category> _categories = AppData.categories;
  List<String> _unlockedCategoryIds = ['animals']; // Default unlocked
  bool _isSoundOn = true;

  List<Category> get categories => _categories;
  bool get isSoundOn => _isSoundOn;

  GameProvider() {
    _loadPreferences();
  }

  bool isCategoryUnlocked(String id) {
    // If it's not premium, it's always unlocked
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
