import 'package:album_app/app/theme/app_theme.dart';
import 'package:album_app/shared/widgets/department_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// La tarjeta usa Expanded para la ilustración; necesita altura acotada (como
// en el grid). En tests la envolvemos en un SizedBox.
Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 180, height: 220, child: child),
        ),
      ),
    );

void main() {
  testWidgets('muestra nombre, emoji de respaldo y progreso X/Y + %',
      (tester) async {
    // Sin `illustration`: cae al emoji de respaldo.
    await tester.pumpWidget(_wrap(const DepartmentCard(
      name: 'La Paz',
      emoji: '🏔️',
      completed: 2,
      total: 5,
    )));

    expect(find.text('La Paz'), findsOneWidget);
    expect(find.text('🏔️'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    // Sin completar: no aparece la insignia de "completo".
    expect(find.byIcon(Icons.verified), findsNothing);
  });

  testWidgets('completo al 100% muestra la insignia', (tester) async {
    await tester.pumpWidget(_wrap(const DepartmentCard(
      name: 'Oruro',
      completed: 3,
      total: 3,
    )));

    expect(find.byIcon(Icons.verified), findsOneWidget);
  });

  testWidgets('tocar la tarjeta dispara onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(DepartmentCard(
      name: 'Tarija',
      completed: 0,
      total: 4,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.byType(DepartmentCard));
    expect(tapped, isTrue);
  });
}
