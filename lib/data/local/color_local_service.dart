import '../../models/responseColor/response_color.dart';
import '../../utils/cache/cache_manager.dart';

class ColorLocalService {
  Future<void> saveColors(List<ResponseColor> colors) async {
    await HiveHelper.shared.clear<ResponseColor>(
      boxName: HiveHelper.colorBoxKey,
    );
    await HiveHelper.shared.addAll<ResponseColor>(
      boxName: HiveHelper.colorBoxKey,
      list: colors,
    );
  }

  Future<List<ResponseColor>> getColors() async {
    return HiveHelper.shared.getValues<ResponseColor>(
      boxName: HiveHelper.colorBoxKey,
    );
  }
}
