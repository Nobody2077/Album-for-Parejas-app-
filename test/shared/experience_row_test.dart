import 'package:album_app/app/theme/app_theme.dart';
import 'package:album_app/shared/widgets/experience_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('no completada: sin check, corazones ni fotos', (tester) async {
    await tester.pumpWidget(_wrap(const ExperienceRow(
      title: 'Subir al Teleférico',
      completed: false,
    )));

    expect(find.text('Subir al Teleférico'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });

  testWidgets('completada: muestra check, corazones y conteo de fotos',
      (tester) async {
    await tester.pumpWidget(_wrap(const ExperienceRow(
      title: 'Valle de la Luna',
      completed: true,
      rating: 4,
      photoCount: 2,
    )));

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNWidgets(4));
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('tocar la fila dispara onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(ExperienceRow(
      title: 'Carnaval',
      completed: false,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.byType(ExperienceRow));
    expect(tapped, isTrue);
  });
}
