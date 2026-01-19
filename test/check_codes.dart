import 'package:flutter_test/flutter_test.dart';
import 'package:country_flags_pro/country_flags_pro.dart';

void main() {
  test('Print valid country codes', () {
    print('Valid codes: ${CountryFlagsPro.validCountryCodes}');
    if (CountryFlagsPro.validCountryCodes.contains('US')) {
      print('Contains US');
    } else {
      print('Does NOT contain US');
    }
    if (CountryFlagsPro.validCountryCodes.contains('us')) {
      print('Contains us');
    } else {
      print('Does NOT contain us');
    }
  });
}
