import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/providers/auth_provider.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _categories = [
    'gasSupply',
    'cleanWater',
    'drinkingWater',
    'toiletEmptying',
    'garbageDisposal',
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final translations = AppLocalizations.of(context)!;
    const Color navyBlue = Color(0xFF191970);

    const TextStyle cardTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: navyBlue,
      height: 1.3,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: navyBlue),
            onPressed: () {
              Navigator.pushNamed(context, NavigationService.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: navyBlue),
            onPressed: () async {
              await ref.read(userProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, NavigationService.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16.0),
                  // Gas Supply Card (Centered)
                  
                  SizedBox(
                    width: double.infinity,
                    child: _ServiceCard(
                      label: translations.getTranslation('gasSupply'),
                      imagePath: 'assets/images/gas.jpg',
                      textStyle: cardTextStyle,
                      imageHeight: 150,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          NavigationService.locationInput,
                          arguments: {'category': translations.getTranslation('gasSupply')},
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Clean Water and Drinking Water Row
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ServiceCard(
                            label: translations.getTranslation('cleanWater'),
                            imagePath: 'assets/images/clean_water.png',
                            textStyle: cardTextStyle,
                            imageHeight: 120,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                NavigationService.locationInput,
                                arguments: {'category': translations.getTranslation('cleanWater')},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: _ServiceCard(
                            label: translations.getTranslation('drinkingWater'),
                            imagePath: 'assets/images/drink_water.png',
                            textStyle: cardTextStyle,
                            imageHeight: 120,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                NavigationService.locationInput,
                                arguments: {'category': translations.getTranslation('drinkingWater')},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Toilet Emptying and Garbage Disposal Row
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ServiceCard(
                            label: translations.getTranslation('toiletEmptying'),
                            imagePath: 'assets/images/exhauster.png',
                            textStyle: cardTextStyle,
                            imageHeight: 120,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                NavigationService.locationInput,
                                arguments: {'category': translations.getTranslation('toiletEmptying')},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: _ServiceCard(
                            label: translations.getTranslation('garbageDisposal'),
                            imagePath: 'assets/images/garbage.png',
                            textStyle: cardTextStyle,
                            imageHeight: 120,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                NavigationService.locationInput,
                                arguments: {'category': translations.getTranslation('garbageDisposal')},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.label,
    required this.imagePath,
    required this.textStyle,
    required this.onTap,
    required this.imageHeight,
  });

  final String label;
  final String imagePath;
  final TextStyle textStyle;
  final VoidCallback onTap;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

extension AppLocalizationsExtension on AppLocalizations {
  String getTranslation(String key) {
    switch (key) {
      case 'cleanWater':
        return cleanWater;
      case 'gasSupply':
        return gasSupply;
      case 'drinkingWater':
        return drinkingWater;
      case 'garbageDisposal':
        return garbageDisposal;
      case 'toiletEmptying':
        return toiletEmptying;
      default:
        return '';
    }
  }
}