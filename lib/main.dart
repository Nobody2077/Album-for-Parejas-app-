import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/services/image_storage_service.dart';
import 'core/storage/hive_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  final appDocsDir = await getApplicationDocumentsDirectory();
  runApp(
    ProviderScope(
      overrides: [
        appDocsDirProvider.overrideWithValue(appDocsDir),
      ],
      child: const OurJourneyApp(),
    ),
  );
}
