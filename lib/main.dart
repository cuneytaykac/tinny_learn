import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiny_learners/utils/cache/cache_manager.dart';
import 'providers/game_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'utils/easy_localization/easy_localization_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveHelper.shared.setupHive();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      path: EasyLocalizationManager.path,
      supportedLocales: EasyLocalizationManager.supportedLocales,
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
        child: const TinyLearnersApp(),
      ),
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
    );
  }
}
