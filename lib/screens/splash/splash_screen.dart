import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tiny_learners/gen/locale_keys.g.dart';

import '../../data/local/local.dart';
import '../../data/remote/remote.dart';
import '../../models/responseColor/response_color.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/game_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Services
  final _animalService = AnimalService();
  final _vehicleService = VehicleService();
  final _colorService = ColorService();
  final _animalLocalService = AnimalLocalService();
  final _vehicleLocalService = VehicleLocalService();
  final _colorLocalService = ColorLocalService();

  double _progress = 0.0;
  String _statusText = '';
  // State variables
  bool _isInitStarted = false;
  bool _isInitCompleted = false;
  ConnectivityProvider? _connectivityProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to ConnectivityProvider for safe access in dispose
    if (_connectivityProvider == null) {
      _connectivityProvider = Provider.of<ConnectivityProvider>(
        context,
        listen: false,
      );
      _checkConnectivityAndInit();
    }
  }

  void _checkConnectivityAndInit() {
    if (_connectivityProvider == null) return;

    // Initial check
    if (_connectivityProvider!.hasInternet) {
      _startInitialization();
    } else {
      // If no internet initially, set status (The wrapper will cover this screen anyway)
      setState(() {
        _statusText = LocaleKeys.no_internet_checking.tr();
      });
    }

    // Listen for changes
    _connectivityProvider!.addListener(_connectivityListener);
  }

  void _connectivityListener() {
    if (!mounted || _connectivityProvider == null) return;

    if (_connectivityProvider!.hasInternet &&
        !_isInitStarted &&
        !_isInitCompleted) {
      _startInitialization();
    }
  }

  @override
  void dispose() {
    // Use saved reference instead of context
    _connectivityProvider?.removeListener(_connectivityListener);
    super.dispose();
  }

  Future<void> _startInitialization() async {
    if (_isInitStarted) return;

    setState(() {
      _isInitStarted = true;
      _statusText = LocaleKeys.splash_starting.tr();
    });

    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Minimum Splash Duration (Safety net)
    final minDuration = Future.delayed(const Duration(seconds: 2));

    try {
      // 0. Detect Device Language
      if (!mounted) return;

      setState(() {
        _statusText = LocaleKeys.splash_setting_language.tr();
        _progress = 0.1;
      });

      final String languageCode = context.locale.languageCode;
      await Future.delayed(const Duration(seconds: 1));

      // 1. Fetch Animals
      if (!mounted) return;
      setState(() {
        _statusText = LocaleKeys.splash_loading_animals.tr();
        _progress = 0.3;
      });

      final animals = await _animalService.getAnimals(language: languageCode);
      await _animalLocalService.saveAnimals(animals);
      await Future.delayed(const Duration(seconds: 1));

      // 2. Fetch Vehicles
      if (!mounted) return;
      setState(() {
        _statusText = LocaleKeys.splash_loading_vehicles.tr();
        _progress = 0.6;
      });

      final vehicles = await _vehicleService.getVehicles(
        language: languageCode,
      );
      await _vehicleLocalService.saveVehicles(vehicles);
      await Future.delayed(const Duration(seconds: 1));

      // 3. Fetch Colors
      if (!mounted) return;
      setState(() {
        _statusText = LocaleKeys.splash_loading_colors.tr();
        _progress = 0.9;
      });

      await _loadColors();

      if (mounted) {
        await Provider.of<GameProvider>(
          context,
          listen: false,
        ).loadCategories();
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _statusText = LocaleKeys.splash_ready.tr();
          _progress = 1.0;
        });
      }

      // Wait for minimum duration
      await minDuration;

      _isInitCompleted = true;

      // Navigate to Home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Splash Error: $e');
      if (mounted) {
        setState(() {
          _statusText = LocaleKeys.splash_error.tr();
          _isInitStarted = false; // Allow retrying if error occurs
        });
      }
    }
  }

  /// Load colors with fallback to local JSON
  Future<void> _loadColors() async {
    try {
      // Try to fetch from API
      final colors = await _colorService.fetchColors();
      await _colorLocalService.saveColors(colors);
      debugPrint('✅ Colors loaded from API');
    } catch (e) {
      debugPrint('⚠️ API failed for colors, loading from local assets: $e');
      // Fallback to local JSON
      try {
        const assetPath = 'assets/data/color/color_image.json';

        final jsonString = await rootBundle.loadString(assetPath);
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final colors =
            jsonList.map((json) => ResponseColor.fromJson(json)).toList();
        await _colorLocalService.saveColors(colors);
        debugPrint('✅ Colors loaded from local assets');
      } catch (fallbackError) {
        debugPrint('❌ Failed to load colors from local assets: $fallbackError');
        // Don't rethrow - just log the error and continue
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFF90CAF9),
            ], // Light Blue Gradient
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/logo/app_logo.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(
                    duration: 1500.ms,
                    color: Colors.white.withValues(alpha: 0.5),
                  )
                  .then(delay: 500.ms)
                  .shake(duration: 500.ms),

              const SizedBox(height: 20),

              // Title Animation
              Text(
                    'Tiny Learners',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 50),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.orange,
                    ),
                    minHeight: 15,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Status Text
              Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
