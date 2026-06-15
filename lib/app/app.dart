import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación: configura `MaterialApp.router` con el tema cálido.
class OurJourneyApp extends StatelessWidget {
  const OurJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Our Journey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

// TODO(Fase 6): reemplazar por el GoRouter real definido en `app/router.dart`.
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _WelcomeScreen(),
    ),
  ],
);

/// Pantalla temporal de bienvenida (placeholder de la Fase 1).
///
/// Su único propósito es verificar que el tema arranca correctamente. Se
/// reemplaza por la `HomeScreen` real en la Fase 7.
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Our Journey',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Colecciona experiencias juntos por toda Bolivia.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSoft,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(Icons.favorite, color: AppColors.heart, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
