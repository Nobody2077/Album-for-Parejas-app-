// Test de navegación entre las rutas placeholder (Fase 6).

import 'package:album_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navega Home -> Departamentos -> Detalle depto -> Experiencia',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OurJourneyApp()));
    await tester.pumpAndSettle();

    // Home
    expect(find.text('Ver departamentos'), findsOneWidget);

    // -> Departamentos
    await tester.tap(find.text('Ver departamentos'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir La Paz'), findsOneWidget);

    // -> Detalle de departamento (con el path param)
    await tester.tap(find.text('Abrir La Paz'));
    await tester.pumpAndSettle();
    expect(find.text('Departamento: la_paz'), findsWidgets);

    // -> Detalle de experiencia (con el path param)
    await tester.tap(find.text('Abrir una experiencia'));
    await tester.pumpAndSettle();
    expect(find.text('Experiencia: lp_telef'), findsWidgets);
  });
}
