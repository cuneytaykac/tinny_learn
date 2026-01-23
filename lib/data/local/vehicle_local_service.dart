import '../../models/vehicle/vehicle.dart';
import '../../utils/cache/cache_manager.dart';

/// Local storage service for Vehicle data using Hive
class VehicleLocalService {
  /// Saves list of vehicles to local storage
  Future<void> saveVehicles(List<Vehicle> vehicles) async {
    await HiveHelper.shared.clear<Vehicle>(boxName: HiveHelper.vehicleBoxKey);
    await HiveHelper.shared.addAll<Vehicle>(
      boxName: HiveHelper.vehicleBoxKey,
      list: vehicles,
    );
  }

  /// Retrieves cached vehicles (for offline mode)
  Future<List<Vehicle>> getVehicles() async {
    return HiveHelper.shared.getValues<Vehicle>(
      boxName: HiveHelper.vehicleBoxKey,
    );
  }
}
