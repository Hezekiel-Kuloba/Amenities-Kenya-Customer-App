import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bluePrimary = Color(0xFF1E88E5); // Vibrant professional blue
  static const Color blueSecondary = Color(0xFF64B5F6); // Lighter blue for gradients
  static const Color lightBackground = Color(0xFFF5F7FA); // Soft off-white
  static const Color darkBackground = Color(0xFF121212); // Dark gray for dark mode
  static const Color lightSurface = Color(0xFFFFFFFF); // White for cards
  static const Color darkSurface = Color(0xFF1E1E1E); // Darker gray for cards
  static const Color lightError = Color(0xFFE57373); // Soft red for errors
  static const Color darkError = Color(0xFFEF5350); // Brighter red for dark mode
  static const Color grey = Color(0xFF78909C); // Neutral gray
  static const Color lightOnPrimary = Colors.black; // Black text for light theme
  static const Color darkOnPrimary = Color(0xFFE0E0E0); // Light gray for dark theme
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.bluePrimary,
      secondary: AppColors.blueSecondary,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnPrimary,
      onSurface: AppColors.lightOnPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    dividerColor: AppColors.grey.withOpacity(0.3),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground, // Fallback to solid color
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.lightOnPrimary,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
      // iconTheme: const IconThemeData(color: AppColors.lightOnPrimary),
      iconTheme: const IconThemeData(color: AppColors.lightOnPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.lightOnPrimary,
        backgroundColor: AppColors.bluePrimary, // Fallback solid color
        shadowColor: AppColors.bluePrimary.withOpacity(0.3),
        textStyle: GoogleFonts.cabin(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        surfaceTintColor: Colors.transparent,
        minimumSize: const Size(120, 56), // Adjusted for onboarding screen
        disabledBackgroundColor: AppColors.grey.withOpacity(0.5),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(AppColors.blueSecondary.withOpacity(0.1)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.bluePrimary,
        textStyle: GoogleFonts.cabin(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      shadowColor: AppColors.bluePrimary.withOpacity(0.3),
      elevation: 5,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      iconColor: AppColors.bluePrimary,
      textColor: AppColors.lightOnPrimary,
      tileColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.lightBackground,
      selectedItemColor: AppColors.bluePrimary,
      unselectedItemColor: AppColors.grey,
      elevation: 2,
      selectedLabelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w400),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: AppColors.lightOnPrimary,
        fontSize: 26.0,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: GoogleFonts.poppins(
        color: AppColors.lightOnPrimary,
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.lightOnPrimary,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.cabin(
        color: AppColors.lightOnPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.cabin(
        color: AppColors.lightOnPrimary,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.cabin(
        color: AppColors.lightOnPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface.withOpacity(0.9),
      hintStyle: GoogleFonts.cabin(color: AppColors.grey),
      labelStyle: GoogleFonts.cabin(color: AppColors.lightOnPrimary),
      errorStyle: GoogleFonts.cabin(color: AppColors.lightError),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightError, width: 2.0),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.lightOnPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.cabin(
        color: AppColors.lightOnPrimary,
        fontSize: 16,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.bluePrimary,
      secondary: AppColors.blueSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnPrimary,
      onSurface: AppColors.darkOnPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    dividerColor: AppColors.grey.withOpacity(0.3),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground, // Fallback to solid color
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkOnPrimary,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkOnPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.darkOnPrimary,
        backgroundColor: AppColors.bluePrimary, // Fallback solid color
        shadowColor: AppColors.bluePrimary.withOpacity(0.4),
        textStyle: GoogleFonts.cabin(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        surfaceTintColor: Colors.transparent,
        minimumSize: const Size(120, 56), // Adjusted for onboarding screen
        disabledBackgroundColor: AppColors.grey.withOpacity(0.5),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(AppColors.blueSecondary.withOpacity(0.1)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.bluePrimary,
        textStyle: GoogleFonts.cabin(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      shadowColor: AppColors.bluePrimary.withOpacity(0.4),
      elevation: 5,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      iconColor: AppColors.bluePrimary,
      textColor: AppColors.darkOnPrimary,
      tileColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.darkBackground,
      selectedItemColor: AppColors.bluePrimary,
      unselectedItemColor: AppColors.grey,
      elevation: 2,
      selectedLabelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w400),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: AppColors.darkOnPrimary,
        fontSize: 26.0,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: GoogleFonts.poppins(
        color: AppColors.darkOnPrimary,
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.darkOnPrimary,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.cabin(
        color: AppColors.darkOnPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.cabin(
        color: AppColors.darkOnPrimary,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.cabin(
        color: AppColors.darkOnPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface.withOpacity(0.9),
      hintStyle: GoogleFonts.cabin(color: AppColors.grey),
      labelStyle: GoogleFonts.cabin(color: AppColors.darkOnPrimary),
      errorStyle: GoogleFonts.cabin(color: AppColors.darkError),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkError, width: 2.0),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkOnPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.cabin(
        color: AppColors.darkOnPrimary,
        fontSize: 16,
      ),
    ),
  );
}