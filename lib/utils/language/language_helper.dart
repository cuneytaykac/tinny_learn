import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/foundation.dart';

class LanguageHelper {
  /// Detects the device locale and returns 'tr' if Turkish, otherwise 'en'.
  static Future<String> getAppLanguage() async {
    try {
      String? locale = await Devicelocale.currentLocale;
      String languageCode = 'en'; // Default

      if (locale != null) {
        // Handle formats like 'en_US', 'en-TR', 'tr-TR', 'tr'
        // Split by either '-' or '_' and take the first part
        List<String> parts = locale.split(RegExp(r'[-_]'));
        String languagePart = parts.isNotEmpty ? parts[0].toLowerCase() : 'en';

        if (languagePart == 'tr') {
          languageCode = 'tr';
        }
      }
      debugPrint(
        'LanguageHelper: Detected Locale: $locale -> using Language: $languageCode',
      );
      return languageCode;
    } catch (e) {
      debugPrint('LanguageHelper Error: $e');
      return 'en'; // Fallback to English on error
    }
  }
}
