import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/responseColor/response_color.dart';
import 'api_client.dart';

class ColorService {
  final ApiClient _apiClient = ApiClient();
  final String _endpoint =
      'https://raw.githubusercontent.com/cuneytaykac/AnimalAssets/main/data/color/color_image.json';

  Future<List<ResponseColor>> fetchColors() async {
    try {
      // Since it's a full URL, we might need to override the base URL or use dio.get directly if ApiClient forces a base.
      // Checking ApiClient implementation is safer, but usually we can pass full URL.
      // However, ApiClient might append to base. Let's look at ApiClient if needed,
      // but standard Dio allows full URL.
      // Safest is to use a new Dio instance or check if ApiClient supports full URL.
      // Let's assume ApiClient has a get method.

      final response = await _apiClient.dio.get(_endpoint);

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        if (responseData is String) {
          responseData = jsonDecode(responseData);
        }

        final List<dynamic> data = responseData;
        return data.map((json) => ResponseColor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load colors');
      }
    } catch (e) {
      debugPrint('Error fetching colors: $e');
      return [];
    }
  }
}
