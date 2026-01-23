import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/vehicle/vehicle.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'animal_service.dart'; // For ApiException

/// Service for fetching vehicle data from remote API
class VehicleService {
  final Dio _dio = ApiClient().dio;

  /// Fetches list of vehicles from remote JSON
  /// [language] - 'en' for English, 'tr' for Turkish (default: 'en')
  Future<List<Vehicle>> getVehicles({String language = 'en'}) async {
    try {
      final endpoint =
          language == 'tr' ? ApiEndpoints.vehiclesTr : ApiEndpoints.vehiclesEn;

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        // GitHub raw returns text/plain, so we need to manually parse JSON
        final dynamic data =
            response.data is String ? jsonDecode(response.data) : response.data;
        final List<dynamic> jsonList = data;
        return jsonList.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to load vehicles',
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
