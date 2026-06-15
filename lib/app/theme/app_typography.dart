import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografías de la app.
///
/// Serif elegante (**Playfair Display**) para títulos y display; sans legible
/// (**Nunito Sans**) para cuerpo y etiquetas. Se sirven vía `google_fonts`.
abstract final class AppTypography {
  /// Construye el [TextTheme] de la app combinando serif para los títulos
  /// y sans para el cuerpo, partiendo del [base] del tema (M3).
  static TextTheme textTheme(TextTheme base) {
    final serif = GoogleFonts.playfairDisplayTextTheme(base);
    final sans = GoogleFonts.nunitoSansTextTheme(base);

    return base
        .copyWith(
          // Títulos / display -> serif
          displayLarge: serif.displayLarge,
          displayMedium: serif.displayMedium,
          displaySmall: serif.displaySmall,
          headlineLarge: serif.headlineLarge,
          headlineMedium: serif.headlineMedium,
          headlineSmall: serif.headlineSmall,
          titleLarge: serif.titleLarge,
          // Cuerpo / etiquetas -> sans
          titleMedium: sans.titleMedium,
          titleSmall: sans.titleSmall,
          bodyLarge: sans.bodyLarge,
          bodyMedium: sans.bodyMedium,
          bodySmall: sans.bodySmall,
          labelLarge: sans.labelLarge,
          labelMedium: sans.labelMedium,
          labelSmall: sans.labelSmall,
        )
        .apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        );
  }
}
