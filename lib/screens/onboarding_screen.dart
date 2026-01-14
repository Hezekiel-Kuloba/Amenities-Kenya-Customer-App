import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/services/preferences_service.dart';
import 'package:amenities_kenya/utilities/dialogs.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dots_indicator/dots_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'welcome',
      'description': 'welcomeDescription',
      'image': 'assets/images/intro1.jpeg',
    },
    {
      'title': 'selectServices',
      'description': 'selectServicesDescription',
      'image': 'assets/images/intro2.jpeg',
    },
    {
      'title': 'trackOrders',
      'description': 'trackOrdersDescription',
      'image': 'assets/images/intro3.jpeg',
    },
  ];

  String _getTranslation(AppLocalizations translations, String key) {
    switch (key) {
      case 'welcome':
        return translations.welcome;
      case 'welcomeDescription':
        return translations.welcomeDescription;
      case 'selectServices':
        return translations.selectServices;
      case 'selectServicesDescription':
        return translations.selectServicesDescription;
      case 'trackOrders':
        return translations.trackOrders;
      case 'trackOrdersDescription':
        return translations.trackOrdersDescription;
      default:
        return '';
    }
  }

  Future<void> _setHasSeenOnboarding() async {
    try {
      await ref.read(preferencesServiceProvider).setHasSeenOnboarding(true);
      if (mounted) {
        Navigator.pushReplacementNamed(context, NavigationService.login);
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.showErrorDialog(
          context: context,
          title: AppLocalizations.of(context)!.error,
          content: e.toString(),
        );
      }
    }
  }

  void _handleNextButton() {
    if (_currentPage == _pages.length - 1) {
      _setHasSeenOnboarding();
    } else {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _handleSkipButton() {
    _setHasSeenOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _handleSkipButton,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Image at top
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Image.asset(
                          _pages[index]['image']!,
                          width: size.width * 0.6, // Scale to 60% of screen width
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Spacer to push text to bottom
                      const Spacer(),
                      // Text at bottom
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              _getTranslation(translations, _pages[index]['title']!),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                _getTranslation(translations, _pages[index]['description']!),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Bottom navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DotsIndicator(
                    dotsCount: _pages.length,
                    position: _currentPage.toDouble(),
                    decorator: DotsDecorator(
                      activeColor: Colors.blue[800],
                      size: const Size.square(8.0),
                      activeSize: const Size(24.0, 8.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handleNextButton,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 2,
                      minimumSize: const Size(0, 48), // Allow button to expand
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}