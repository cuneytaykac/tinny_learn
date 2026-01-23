import '../../utils/language/language_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/remote/remote.dart';
import '../../data/local/local.dart';
import '../home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Services
  final _animalService = AnimalService();
  final _vehicleService = VehicleService();
  final _animalLocalService = AnimalLocalService();
  final _vehicleLocalService = VehicleLocalService();

  double _progress = 0.0;
  String _statusText = 'Başlıyor...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Minimum Splash Duration (Safety net, though explicit delays will exceed this)
    final minDuration = Future.delayed(const Duration(seconds: 2));

    // Start Loading Data
    try {
      // 0. Detect Device Language
      setState(() {
        _statusText = 'Dil ayarlanıyor... / Setting language...';
        _progress = 0.1;
      });

      // Use helper to get language
      final String languageCode = await LanguageHelper.getAppLanguage();

      // Wait 1 second to let user read "Setting language..."
      await Future.delayed(const Duration(seconds: 1));

      // 1. Fetch Animals
      setState(() {
        _statusText =
            languageCode == 'tr'
                ? 'Hayvanlar yükleniyor...'
                : 'Loading animals...';
        _progress = 0.3;
      });

      final animals = await _animalService.getAnimals(language: languageCode);
      await _animalLocalService.saveAnimals(animals);

      // Wait 1 second to let user read "Loading animals..."
      await Future.delayed(const Duration(seconds: 1));

      // 2. Fetch Vehicles
      setState(() {
        _statusText =
            languageCode == 'tr'
                ? 'Araçlar yükleniyor...'
                : 'Loading vehicles...';
        _progress = 0.6;
      });

      final vehicles = await _vehicleService.getVehicles(
        language: languageCode,
      );
      await _vehicleLocalService.saveVehicles(vehicles);

      // Wait 1 second to let user read "Loading vehicles..."
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _statusText = languageCode == 'tr' ? 'Hazır!' : 'Ready!';
        _progress = 1.0;
      });

      // Wait for minimum duration (will be instant if >2s passed)
      await minDuration;

      // Navigate to Home
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      debugPrint('Splash Error: $e');
      // TODO: Handle offline mode or retry
      setState(() {
        _statusText = 'Hata oluştu! / Error occurred!';
      });
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
              Icon(
                    Icons.extension_rounded, // Placeholder for logo
                    size: 100,
                    color: Colors.orange,
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(
                    duration: 1500.ms,
                    color: Colors.white.withOpacity(0.5),
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
                    backgroundColor: Colors.white.withOpacity(0.3),
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
