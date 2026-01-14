import 'package:amenities_kenya/constants.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/services/preferences_service.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = ref.read(preferencesServiceProvider);
    final hasSeenOnboarding = await prefs.getHasSeenOnboarding();
    final user = ref.read(userProvider);

    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, NavigationService.onboarding);
    } else if (user == null) {
      Navigator.pushReplacementNamed(context, NavigationService.login);
    } else {
      Navigator.pushReplacementNamed(context, NavigationService.bottomNav);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set white background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_amenities.png', // Use provided image
              width: 200, // Match original Lottie dimensions
              height: 200,
              fit: BoxFit.contain, // Ensure image scales properly
            ),
          ],
        ),
      ),
    );
  }
}