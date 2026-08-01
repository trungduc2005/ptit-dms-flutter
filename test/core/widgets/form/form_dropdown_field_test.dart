import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';

void main() {
  const options = [
    DropdownMenuItem<String>(value: 'one', child: Text('Lựa chọn một')),
    DropdownMenuItem<String>(value: 'two', child: Text('Lựa chọn hai')),
  ];

  Widget buildSubject({
    required double topSpacing,
    ValueChanged<String?>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            SizedBox(height: topSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FormDropdownField<String>(
                key: const ValueKey('dropdown'),
                label: 'Lựa chọn',
                hintText: 'Chọn một mục',
                items: options,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('opens below when the viewport has enough space', (tester) async {
    await tester.pumpWidget(buildSubject(topSpacing: 20));

    final field = find.byKey(const ValueKey('dropdown'));
    await tester.tap(field);
    await tester.pumpAndSettle();

    final fieldBottom = tester.getBottomLeft(field).dy;
    final firstOptionTop = tester.getTopLeft(find.text('Lựa chọn một')).dy;

    expect(firstOptionTop, greaterThan(fieldBottom));
  });

  testWidgets('opens upward near the bottom and selects an item', (
    tester,
  ) async {
    String? selectedValue;
    await tester.pumpWidget(
      buildSubject(
        topSpacing: 450,
        onChanged: (value) => selectedValue = value,
      ),
    );

    final field = find.byKey(const ValueKey('dropdown'));
    await tester.tap(field);
    await tester.pumpAndSettle();

    final secondOption = find.text('Lựa chọn hai');
    final inputTop = tester.getBottomLeft(field).dy - 52;
    final optionBottom = tester.getBottomLeft(secondOption).dy;

    expect(optionBottom, lessThan(inputTop));
    expect(tester.getRect(secondOption).bottom, lessThanOrEqualTo(600));
    expect(
      tester.hitTestOnBinding(tester.getCenter(secondOption)).path,
      isNotEmpty,
    );

    await tester.tap(secondOption);
    await tester.pumpAndSettle();

    expect(selectedValue, 'two');
    expect(find.text('Lựa chọn hai'), findsNothing);
    expect(find.text('Lựa chọn một'), findsNothing);
  });
}
