import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../screens/no_internet/no_internet_screen.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            child, // The actual app screen
            if (!provider.hasInternet)
              const Positioned.fill(
                child: Material(
                  // Ensure opaque background to cover underlying screen
                  color: Colors.white,
                  child: NoInternetScreen(),
                ),
              ),
          ],
        );
      },
    );
  }
}
