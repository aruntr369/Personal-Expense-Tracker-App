import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      color: Palette.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    primarySwatch: generateMaterialColor(Palette.primary),
    scaffoldBackgroundColor: Palette.scaffoldBackgroundColor,
  );
  static ThemeData get theme {
    return _lightTheme;
  }
}
