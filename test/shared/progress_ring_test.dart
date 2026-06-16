import 'package:album_app/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProgressRing renderiza sin colgarse', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProgressRing(fraction: 0.0, child: Text('0')),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 15)));
}
