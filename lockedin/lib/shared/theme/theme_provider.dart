import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/shared/theme/app_theme.dart';

class ThemeNotifier extends Notifier<ThemeData> {
  @override
  ThemeData build() {
    return AppTheme.lightTheme; // Default theme
  }

  void toggleTheme() {
    state =
        state == AppTheme.darkTheme ? AppTheme.lightTheme : AppTheme.darkTheme;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(
  ThemeNotifier.new,
);
