// Smoke test del arranque de la app con el tema aplicado (Fase 1).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:album_app/app/app.dart';

void main() {
  testWidgets('La app arranca mostrando la pantalla de bienvenida',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OurJourneyApp()),
    );
    await tester.pumpAndSettle();

    // El título de la app aparece y se renderizan los 5 corazones.
    expect(find.text('Our Journey'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(5));
  });
}
