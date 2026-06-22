import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../experience/models/experience_progress.dart';
import '../../hive_registrar.g.dart';
import '../../moments/models/custom_moment.dart';

/// Nombre del box donde vive el progreso del usuario.
const String progressBoxName = 'experience_progress';

/// Nombre del box de los momentos personalizados creados por el usuario.
const String customMomentsBoxName = 'custom_moments';

/// Inicializa Hive para Flutter, registra los adapters y abre los boxes.
/// Debe llamarse **antes** de `runApp` (ver `main.dart`).
Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapters(); // extensión generada en hive_registrar.g.dart
  await Hive.openBox<ExperienceProgress>(progressBoxName);
  await Hive.openBox<CustomMoment>(customMomentsBoxName);
}

/// Acceso al box de progreso ya abierto.
Box<ExperienceProgress> progressBox() =>
    Hive.box<ExperienceProgress>(progressBoxName);

/// Acceso al box de momentos personalizados ya abierto.
Box<CustomMoment> customMomentsBox() =>
    Hive.box<CustomMoment>(customMomentsBoxName);
