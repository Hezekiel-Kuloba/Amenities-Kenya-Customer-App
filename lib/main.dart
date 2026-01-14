import 'package:amenities_kenya/app_themes.dart';
import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/providers/locale_provider.dart';
import 'package:amenities_kenya/providers/theme_provider.dart';
import 'package:amenities_kenya/screens/bottom_navigation_screen.dart';
import 'package:amenities_kenya/screens/home_screen.dart';
import 'package:amenities_kenya/screens/location_input_screen.dart';
import 'package:amenities_kenya/screens/login_screen.dart';
import 'package:amenities_kenya/screens/onboarding_screen.dart';
import 'package:amenities_kenya/screens/order_confirmation_screen.dart';
import 'package:amenities_kenya/screens/order_customization_screen.dart';
import 'package:amenities_kenya/screens/order_summary_screen.dart';
import 'package:amenities_kenya/screens/order_tracking_screen.dart';
import 'package:amenities_kenya/screens/past_orders_screen.dart';
import 'package:amenities_kenya/screens/payment_screen.dart';
import 'package:amenities_kenya/screens/profile_screen.dart';
import 'package:amenities_kenya/screens/profile_setup_screen.dart';
import 'package:amenities_kenya/screens/rating_screen.dart';
import 'package:amenities_kenya/screens/registration_screen.dart';
import 'package:amenities_kenya/screens/scheduling_screen.dart';
import 'package:amenities_kenya/screens/settings_screen.dart';
import 'package:amenities_kenya/screens/splash_screen.dart';
import 'package:amenities_kenya/screens/supplier_selection_screen.dart';
import 'package:amenities_kenya/services/preferences_service.dart';
import 'package:amenities_kenya/utilities/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final preferencesService = ref.watch(preferencesServiceProvider);

    return FutureBuilder<double>(
      future: preferencesService.getFontSize(),
      builder: (context, snapshot) {
        final fontSize = snapshot.data ?? 16.0;
        return MaterialApp(
          title: 'Amenity Service Platform',
          theme: AppThemes.lightTheme.copyWith(
            textTheme: AppThemes.lightTheme.textTheme.apply(
              fontSizeFactor: fontSize / 16.0,
            ),
          ),
          darkTheme: AppThemes.darkTheme.copyWith(
            textTheme: AppThemes.darkTheme.textTheme.apply(
              fontSizeFactor: fontSize / 16.0,
            ),
          ),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('sw'),
          ],
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: NavigationService.splash,
          routes: {
            NavigationService.splash: (context) => const SplashScreen(),
            NavigationService.profile: (context) => const ProfileScreen(),
            NavigationService.onboarding: (context) => const OnboardingScreen(),
            NavigationService.login: (context) => const LoginScreen(),
            NavigationService.home: (context) => const HomeScreen(),
            NavigationService.bottomNav: (context) => const BottomNavigationScreen(),
            NavigationService.supplierSelection: (context) =>
                const SupplierSelectionScreen(),
            NavigationService.orderCustomization: (context) =>
                const OrderCustomizationScreen(),
            NavigationService.scheduling: (context) => const SchedulingScreen(),
            NavigationService.orderConfirmation: (context) =>
                const OrderConfirmationScreen(),
            NavigationService.orderSummary: (context) => const OrderSummaryScreen(),
            NavigationService.payment: (context) => const PaymentScreen(),
            NavigationService.orderTracking: (context) => const OrderTrackingScreen(),
            NavigationService.rateSupplier: (context) => const RatingScreen(),
            NavigationService.pastOrders: (context) => const PastOrdersScreen(),
            NavigationService.register: (context) => const RegistrationScreen(),
            NavigationService.profileSetup: (context) => ProfileSetupScreen(
                  phoneNumber:
                      (ModalRoute.of(context)!.settings.arguments as Map)['phoneNumber'],
                ),
            NavigationService.locationInput: (context) => LocationInputScreen(
                  category: (ModalRoute.of(context)!.settings.arguments
                          as Map<String, dynamic>?)?['category'] ??
                      '',
                ),
            NavigationService.settings: (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}