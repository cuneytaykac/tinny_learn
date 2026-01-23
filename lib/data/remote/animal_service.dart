import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/animal/animals.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

/// Service for fetching animal data from remote API
class AnimalService {
  final Dio _dio = ApiClient().dio;

  /// Fetches list of animals from remote JSON
  /// [language] - 'en' for English, 'tr' for Turkish (default: 'en')
  Future<List<Animal>> getAnimals({String language = 'en'}) async {
    try {
      final endpoint =
          language == 'tr' ? ApiEndpoints.animalsTr : ApiEndpoints.animalsEn;

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        // GitHub raw returns text/plain, so we need to manually parse JSON
        final dynamic data =
            response.data is String ? jsonDecode(response.data) : response.data;
        final List<dynamic> jsonList = data;
        return jsonList.map((json) => Animal.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to load animals',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e', originalError: e);
    }
  }
}

/// Custom API Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
