import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // TODO(Fase 4): inicializar Hive aquí (WidgetsFlutterBinding + hive_init)
  // antes de runApp.
  runApp(
    const ProviderScope(
      child: OurJourneyApp(),
    ),
  );
}
