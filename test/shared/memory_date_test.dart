import 'package:album_app/shared/format/memory_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatea la fecha en español', () {
    expect(formatMemoryDate(DateTime(2026, 6, 17)), '17 de junio de 2026');
    expect(formatMemoryDate(DateTime(2025, 1, 1)), '1 de enero de 2025');
    expect(formatMemoryDate(DateTime(2024, 12, 31)), '31 de diciembre de 2024');
  });
}
