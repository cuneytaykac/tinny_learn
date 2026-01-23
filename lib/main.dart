import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiny_learners/utils/cache/cache_manager.dart';
import 'providers/game_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveHelper.shared.setupHive();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: const TinyLearnersApp(),
    ),
  );
}

class TinyLearnersApp extends StatelessWidget {
  const TinyLearnersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Learners',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
