import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../gen/locale_keys.g.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated WiFi Off Icon
                  Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 80,
                          color: Colors.redAccent,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shake(duration: 2000.ms, delay: 500.ms)
                      .then()
                      .fadeOut(duration: 500.ms)
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: 48),

                  // Title
                  Text(
                        LocaleKeys.no_internet_title.tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.3, end: 0, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                        LocaleKeys.no_internet_message.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.3, end: 0, duration: 400.ms),

                  const SizedBox(height: 48),

                  // Loading indicator
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocaleKeys.no_internet_checking.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
