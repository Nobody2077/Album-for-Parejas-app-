import 'package:album_app/shared/widgets/heart_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('muestra los corazones llenos según el rating', (tester) async {
    await tester.pumpWidget(_wrap(const HeartRating(rating: 3)));

    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));
  });

  testWidgets('interactivo: tocar un corazón reporta ese valor', (tester) async {
    int? selected;
    await tester.pumpWidget(_wrap(
      HeartRating(rating: 2, onChanged: (v) => selected = v),
    ));

    // Toca el 4º corazón.
    await tester.tap(find.byIcon(Icons.favorite_border).at(1));
    expect(selected, 4);
  });

  testWidgets('interactivo: tocar el corazón actual lo limpia a 0', (tester) async {
    int? selected;
    await tester.pumpWidget(_wrap(
      HeartRating(rating: 3, onChanged: (v) => selected = v),
    ));

    // El 3er corazón es el último lleno.
    await tester.tap(find.byIcon(Icons.favorite).at(2));
    expect(selected, 0);
  });
}
