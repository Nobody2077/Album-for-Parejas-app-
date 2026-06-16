import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../home/presentation/home_screen.dart';

/// Configuración de navegación de la app.
///
/// Las pantallas reales llegan en la Fase 7; por ahora cada ruta muestra un
/// placeholder que permite verificar la navegación. Para sustituirlas, solo se
/// cambian los `builder` de cada `GoRoute`.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/departments',
      name: 'departments',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Departamentos',
        actionLabel: 'Abrir La Paz',
        destination: '/departments/la_paz',
      ),
    ),
    GoRoute(
      path: '/departments/:deptId',
      name: 'departmentDetail',
      builder: (context, state) {
        final deptId = state.pathParameters['deptId']!;
        return _PlaceholderScreen(
          title: 'Departamento: $deptId',
          actionLabel: 'Abrir una experiencia',
          destination: '/experiences/lp_telef',
        );
      },
    ),
    GoRoute(
      path: '/experiences/:expId',
      name: 'experienceDetail',
      builder: (context, state) {
        final expId = state.pathParameters['expId']!;
        return _PlaceholderScreen(title: 'Experiencia: $expId');
      },
    ),
  ],
);

/// Pantalla temporal de la Fase 6: muestra la ruta y, si se indica, un botón
/// para navegar a la siguiente. Se reemplaza por las pantallas reales en Fase 7.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    this.actionLabel,
    this.destination,
  });

  final String title;
  final String? actionLabel;
  final String? destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            if (actionLabel != null && destination != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.push(destination!),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
