// Home (Fase 7): render del progreso y navegación a departamentos.
//
// Router de prueba aislado y catálogo síncrono. La persistencia se sustituye
// por un repo en memoria (Hive no es compatible con testWidgets/FakeAsync).

import 'package:album_app/app/theme/app_theme.dart';
import 'package:album_app/catalog/catalog_providers.dart';
import 'package:album_app/catalog/models/catalog.dart';
import 'package:album_app/catalog/models/department.dart';
import 'package:album_app/catalog/models/experience.dart';
import 'package:album_app/experience/experience_providers.dart';
import 'package:album_app/home/presentation/home_screen.dart';
import 'package:album_app/moments/moments_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/in_memory_moments_repository.dart';
import 'support/in_memory_progress_repository.dart';

void main() {
  const testCatalog = Catalog(
    departments: [Department(id: 'la_paz', name: 'La Paz')],
    experiences: [
      Experience(id: 'lp_telef', departmentId: 'la_paz', title: 'Teleférico'),
      Experience(id: 'lp_luna', departmentId: 'la_paz', title: 'Valle de la Luna'),
    ],
  );

  testWidgets('muestra el progreso global y navega a departamentos',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/departments',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('PANTALLA DEPTOS'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogProvider.overrideWith((ref) => testCatalog),
          progressRepositoryProvider
              .overrideWithValue(InMemoryProgressRepository()),
          momentsRepositoryProvider
              .overrideWithValue(InMemoryMomentsRepository()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();

    // Anillo de progreso: 0 de 2 recuerdos.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('de 2'), findsOneWidget);
    expect(find.text('Explorar departamentos'), findsOneWidget);

    // Navega a departamentos.
    await tester.tap(find.text('Explorar departamentos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('PANTALLA DEPTOS'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
