import 'package:go_router/go_router.dart';

import '../departments/presentation/department_detail_screen.dart';
import '../departments/presentation/departments_screen.dart';
import '../experience/presentation/experience_detail_screen.dart';
import '../home/presentation/home_screen.dart';
import '../moments/presentation/moment_detail_screen.dart';
import '../moments/presentation/moments_screen.dart';

/// Configuración de navegación de la app: las 4 rutas con sus pantallas reales.
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
        return ExperienceDetailScreen(experienceId: expId);
      },
    ),
    GoRoute(
      path: '/moments',
      name: 'moments',
      builder: (context, state) => const MomentsScreen(),
    ),
    GoRoute(
      path: '/moments/:momentId',
      name: 'momentDetail',
      builder: (context, state) {
        final momentId = state.pathParameters['momentId']!;
        return MomentDetailScreen(momentId: momentId);
      },
    ),
  ],
);
