import '../../models/animal/animals.dart';
import '../../utils/cache/cache_manager.dart';

/// Local storage service for Animal data using Hive
class AnimalLocalService {
  /// Saves list of animals to local storage
  Future<void> saveAnimals(List<Animal> animals) async {
    await HiveHelper.shared.clear<Animal>(boxName: HiveHelper.animalBoxKey);
    await HiveHelper.shared.addAll<Animal>(
      boxName: HiveHelper.animalBoxKey,
      list: animals,
    );
  }

  /// Retrieves cached animals (for offline mode)
  Future<List<Animal>> getAnimals() async {
    return HiveHelper.shared.getValues<Animal>(
      boxName: HiveHelper.animalBoxKey,
    );
  }
}
