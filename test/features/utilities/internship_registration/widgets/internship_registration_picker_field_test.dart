import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_picker_field.dart';

void main() {
  testWidgets('picker shows a dropdown button and filters local options', (
    tester,
  ) async {
    String? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InternshipRegistrationPickerField<String>(
            label: 'Nguyện vọng 1',
            hintText: 'Chọn công ty',
            enableLocalSearch: true,
            options: const [
              InternshipRegistrationPickerOption(
                value: 'company-1',
                label: 'FPT Software',
              ),
              InternshipRegistrationPickerOption(
                value: 'company-2',
                label: 'VNPT Telecom',
              ),
            ],
            onChanged: (value) => selectedValue = value,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    expect(find.text('FPT Software'), findsNothing);
    expect(find.text('VNPT Telecom'), findsNothing);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'FPT');
    await tester.pumpAndSettle();

    expect(find.text('FPT Software'), findsOneWidget);
    expect(find.text('VNPT Telecom'), findsNothing);

    await tester.tap(find.text('FPT Software'));
    await tester.pumpAndSettle();

    expect(selectedValue, 'company-1');
    expect(find.text('FPT Software'), findsOneWidget);
  });
}
