import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';

void main() {
  group('AcademicYearOption.fromJson', () {
    test('uses code returned by the API when it is available', () {
      final option = AcademicYearOption.fromJson({
        '_id': 'year-01',
        'code': '2025-2026',
        'name': 'Năm học 2025 - 2026',
      });

      expect(option.id, 'year-01');
      expect(option.code, '2025-2026');
      expect(option.name, 'Năm học 2025 - 2026');
    });

    test('derives code from name when the intern options API omits code', () {
      final option = AcademicYearOption.fromJson({
        '_id': 'year-02',
        'name': 'Năm học 2024 - 2025',
      });

      expect(option.code, '2024-2025');
    });

    test('keeps code empty when name does not contain two years', () {
      final option = AcademicYearOption.fromJson({
        '_id': 'year-03',
        'name': 'Năm học hiện tại',
      });

      expect(option.code, isEmpty);
    });
  });
}
