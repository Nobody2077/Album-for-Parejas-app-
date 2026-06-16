import 'dart:io';

import 'package:album_app/core/services/image_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory baseDir;
  late ImageStorageService service;

  setUp(() async {
    baseDir = await Directory.systemTemp.createTemp('photos_test');
    service = ImageStorageService(baseDir);
  });

  tearDown(() async {
    if (baseDir.existsSync()) await baseDir.delete(recursive: true);
  });

  Future<File> makeSource(String name, List<int> bytes) async {
    final file = File('${baseDir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  test('savePhoto copia el archivo, conserva la extensión y devuelve el nombre',
      () async {
    final source = await makeSource('origen.png', [1, 2, 3]);

    final fileName =
        await service.savePhoto(experienceId: 'lp_telef', sourcePath: source.path);

    expect(fileName, endsWith('.png'));
    final resolved = service.resolveFile('lp_telef', fileName);
    expect(await resolved.exists(), isTrue);
    expect(await resolved.readAsBytes(), [1, 2, 3]);
    // Vive bajo {base}/photos/{experienceId}/
    expect(resolved.path, contains('photos'));
    expect(resolved.path, contains('lp_telef'));
  });

  test('usa .jpg por defecto si el origen no tiene extensión', () async {
    final source = await makeSource('sin_extension', [9]);

    final fileName =
        await service.savePhoto(experienceId: 'x', sourcePath: source.path);

    expect(fileName, endsWith('.jpg'));
  });

  test('cada foto guardada tiene un nombre único', () async {
    final source = await makeSource('a.jpg', [0]);

    final first = await service.savePhoto(experienceId: 'x', sourcePath: source.path);
    final second = await service.savePhoto(experienceId: 'x', sourcePath: source.path);

    expect(first, isNot(equals(second)));
  });

  test('deletePhoto borra solo esa foto y no falla si no existe', () async {
    final source = await makeSource('a.jpg', [0]);
    final fileName =
        await service.savePhoto(experienceId: 'x', sourcePath: source.path);

    await service.deletePhoto('x', fileName);
    expect(await service.resolveFile('x', fileName).exists(), isFalse);

    // Idempotente: borrar de nuevo no lanza.
    await service.deletePhoto('x', fileName);
  });

  test('deleteExperiencePhotos borra toda la carpeta de la experiencia',
      () async {
    final source = await makeSource('a.jpg', [0]);
    await service.savePhoto(experienceId: 'x', sourcePath: source.path);
    await service.savePhoto(experienceId: 'x', sourcePath: source.path);

    await service.deleteExperiencePhotos('x');

    expect(Directory('${baseDir.path}/photos/x').existsSync(), isFalse);
  });
}
