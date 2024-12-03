import 'package:flutter/material.dart';
import 'package:frontend/theme/all_themes.dart';

class AppTheme {
  static ThemeData getThemeFromColors(AllAppColors theme) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: theme.primaryColor),
      primaryColor: theme.primaryColor,
      cardTheme: CardTheme(color: theme.primaryColor),
      listTileTheme: ListTileThemeData(iconColor: theme.appbarIconColor, textColor: theme.textColor),
      iconTheme: IconThemeData(color: theme.iconColor),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: theme.primaryColor, foregroundColor: theme.iconColor),
      scaffoldBackgroundColor: theme.secondaryAccent,
      appBarTheme: AppBarTheme(
          backgroundColor: theme.secondaryAccent,
          foregroundColor: theme.textColor,
          iconTheme: IconThemeData(color: theme.appbarIconColor)),
      textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: theme.textColor,
            fontSize: 16,
            letterSpacing: 1,
          ),
          bodySmall: TextStyle(
            color: theme.textColor,
            fontSize: 14,
            letterSpacing: 1,
          ),
          headlineSmall: TextStyle(
            color: theme.textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          headlineMedium: TextStyle(
            color: theme.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          titleSmall: TextStyle(
            color: theme.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          titleMedium: TextStyle(
            color: theme.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          titleLarge: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          )),
      inputDecorationTheme: InputDecorationTheme(
        iconColor: theme.iconColor,
        prefixIconColor: Colors.white,
        labelStyle: TextStyle(color: theme.textColor),
        hintStyle: TextStyle(color: theme.textColor),
        floatingLabelStyle: TextStyle(color: theme.textColor),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: theme.secondaryAccent,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: theme.secondaryAccent,
        titleTextStyle: TextStyle(
          color: theme.textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        contentTextStyle: TextStyle(
          color: theme.textColor,
          fontSize: 18,
          letterSpacing: 1,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: theme.secondaryColor,
        iconTheme: WidgetStateProperty.all(IconThemeData(color: theme.appbarIconColor)),
        indicatorColor: theme.primaryColor,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            color: theme.textColor,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
