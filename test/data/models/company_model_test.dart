import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';

void main() {
  test('includes companyField in equality props', () {
    const first = Company(
      id: 'id',
      companyId: 'company-id',
      companyName: 'Company',
      companyField: 'Software',
      companyAddress: 'Address',
    );
    const second = Company(
      id: 'id',
      companyId: 'company-id',
      companyName: 'Company',
      companyField: 'Telecom',
      companyAddress: 'Address',
    );

    expect(first, isNot(second));
  });
}
