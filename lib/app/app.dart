import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación: configura `MaterialApp.router` con el tema cálido
/// y el router de la app.
class OurJourneyApp extends StatelessWidget {
  const OurJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Our Journey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
