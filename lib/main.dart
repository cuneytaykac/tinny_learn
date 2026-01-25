import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiny_learners/utils/cache/cache_manager.dart';
import 'providers/game_provider.dart';
import 'providers/connectivity_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/easy_localization/easy_localization_manager.dart';
import 'widgets/wrapper/connectivity_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await HiveHelper.shared.setupHive();
  await EasyLocalization.ensureInitialized();

  // Initialize connectivity provider
  final connectivityProvider = ConnectivityProvider();
  connectivityProvider.startMonitoring();

  runApp(
    EasyLocalization(
      path: EasyLocalizationManager.path,
      supportedLocales: EasyLocalizationManager.supportedLocales,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameProvider()),
          ChangeNotifierProvider.value(value: connectivityProvider),
        ],
        child: const TinyLearnersApp(),
      ),
    ),
  );
}

class TinyLearnersApp extends StatelessWidget {
  const TinyLearnersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = Provider.of<ConnectivityProvider>(
      context,
      listen: false,
    );
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    final appRouter = AppRouter(
      connectivityProvider: connectivityProvider,
      gameProvider: gameProvider,
    );

    return MaterialApp.router(
      title: 'Tiny Learners',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: appRouter.router,
      builder: (context, child) {
        return ConnectivityWrapper(child: child!);
      },
    );
  }
}
