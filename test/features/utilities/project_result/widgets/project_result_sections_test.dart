import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/features/utilities/project_result/widgets/project_result_sections.dart';

void main() {
  group('formatProjectCloWeightPercentage', () {
    test('nhân trọng số API với 100 để hiển thị phần trăm', () {
      expect(formatProjectCloWeightPercentage(0.1), '10');
      expect(formatProjectCloWeightPercentage(0.25), '25');
      expect(formatProjectCloWeightPercentage(1), '100');
    });

    test('giữ nguyên phần thập phân và không làm tròn', () {
      expect(formatProjectCloWeightPercentage(0.1234), '12.34');
      expect(formatProjectCloWeightPercentage(0.12345), '12.345');
      expect(formatProjectCloWeightPercentage(0.1001), '10.01');
    });

    test('loại bỏ số 0 thừa mà không làm mất độ chính xác', () {
      expect(formatProjectCloWeightPercentage(0), '0');
      expect(formatProjectCloWeightPercentage(0.001), '0.1');
      expect(formatProjectCloWeightPercentage(0.1200), '12');
    });
  });
}
