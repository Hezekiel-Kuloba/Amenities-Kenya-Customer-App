import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String bottomNav = '/bottomNav';
  static const String home = '/home';
  static const String pastOrders = '/pastOrders';
  static const String register = '/register';
  static const String profileSetup = '/profileSetup';
  static const String locationInput = '/locationInput';
  static const String supplierSelection = '/supplierSelection';
  static const String orderCustomization = '/orderCustomization';
  static const String scheduling = '/scheduling';
  static const String orderConfirmation = '/orderConfirmation';
  static const String orderSummary = '/orderSummary';
  static const String payment = '/payment';
  static const String orderTracking = '/orderTracking';
  static const String rateSupplier = '/rateSupplier';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> pushReplacementNamed(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pop() {
    navigatorKey.currentState!.pop();
  }
}