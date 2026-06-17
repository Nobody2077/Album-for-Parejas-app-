import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../departments/presentation/department_detail_screen.dart';
import '../departments/presentation/departments_screen.dart';
import '../home/presentation/home_screen.dart';

/// Configuración de navegación de la app.
///
/// La ruta de experiencia aún usa un placeholder (su pantalla llega en el
/// siguiente bloque de la Fase 7); para sustituirlo se cambia su `builder`.
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
      builder: (context, state) => const DepartmentsScreen(),
    ),
    GoRoute(
      path: '/departments/:deptId',
      name: 'departmentDetail',
      builder: (context, state) {
        final deptId = state.pathParameters['deptId']!;
        return DepartmentDetailScreen(departmentId: deptId);
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

/// Pantalla temporal para la ruta de experiencia: su pantalla real llega en el
/// siguiente bloque de la Fase 7.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}
