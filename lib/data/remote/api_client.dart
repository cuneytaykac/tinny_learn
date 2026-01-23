import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Base API Client with Dio configuration
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl:
            'https://raw.githubusercontent.com/cuneytaykac/AnimalAssets/main/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json, // Auto-parse JSON response
        headers: {'Accept': 'application/json'},
      ),
    );

    // Add interceptors for logging (only in debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => debugPrint('[API] $log'),
      ),
    );
  }

  Dio get dio => _dio;
}
