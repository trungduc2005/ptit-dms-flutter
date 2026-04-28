import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_picker_field.dart';

void main() {
  testWidgets('picker opens options without rendering an arrow icon', (
    tester,
  ) async {
    String? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InternshipRegistrationPickerField<String>(
            label: 'Nguyện vọng 1',
            hintText: 'Chọn công ty',
            options: const [
              InternshipRegistrationPickerOption(
                value: 'company-1',
                label: 'Công ty 1',
              ),
            ],
            onChanged: (value) => selectedValue = value,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    expect(find.text('Công ty 1'), findsNothing);

    await tester.tap(find.text('Chọn công ty'));
    await tester.pumpAndSettle();

    expect(find.text('Công ty 1'), findsOneWidget);

    await tester.tap(find.text('Công ty 1'));
    await tester.pumpAndSettle();

    expect(selectedValue, 'company-1');
  });
}
