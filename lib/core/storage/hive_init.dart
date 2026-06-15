import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../experience/models/experience_progress.dart';
import '../../hive_registrar.g.dart';

/// Nombre del box donde vive el progreso del usuario.
const String progressBoxName = 'experience_progress';

/// Inicializa Hive para Flutter, registra los adapters y abre el box de
/// progreso. Debe llamarse **antes** de `runApp` (ver `main.dart`).
Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapters(); // extensión generada en hive_registrar.g.dart
  await Hive.openBox<ExperienceProgress>(progressBoxName);
}

/// Acceso al box de progreso ya abierto.
Box<ExperienceProgress> progressBox() =>
    Hive.box<ExperienceProgress>(progressBoxName);
