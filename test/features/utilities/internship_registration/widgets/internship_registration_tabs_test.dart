import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/current_intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_request.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_sections.dart';

void main() {
  testWidgets('segmented tabs show current tab and switch on tap', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InternshipRegistrationSegmentedTabs(
                selectedIndex: selectedIndex,
                onChanged: (value) {
                  setState(() => selectedIndex = value);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Thông tin đăng ký'), findsOneWidget);
    expect(find.text('Trạng thái'), findsOneWidget);

    await tester.tap(find.text('Trạng thái'));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
  });

  testWidgets('status section shows current registration details', (
    tester,
  ) async {
    final registration = CurrentInternRegistration(
      id: 'registration-1',
      internId: 'intern-1',
      studentId: 'B21DCCN001',
      type: InternRegistrationType.registerWish.value,
      preferredCompanies: [
        CurrentInternPreferredCompany(
          order: 1,
          companyId: 'company-1',
          companyName: 'FPT Software',
        ),
        CurrentInternPreferredCompany(
          order: 2,
          companyId: 'company-2',
          companyName: 'VNPT Telecom',
        ),
      ],
      cvFileName: 'cv.pdf',
      rejectReasons: [
        CurrentInternRejectReason(reason: 'Thiếu minh chứng CPA'),
      ],
      status: 'pending',
      cpa: 3.25,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InternshipRegistrationStatusSection(
              registration: registration,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Trạng thái'), findsOneWidget);
    expect(find.text('Chờ duyệt'), findsOneWidget);
    expect(find.text('Hình thức đăng ký'), findsOneWidget);
    expect(find.text('Chọn doanh nghiệp thực tập'), findsOneWidget);
    expect(find.text('CPA'), findsOneWidget);
    expect(find.text('3.25'), findsOneWidget);
    expect(find.text('CV'), findsOneWidget);
    expect(find.text('cv.pdf'), findsOneWidget);
    expect(find.text('Nguyện vọng 1'), findsOneWidget);
    expect(find.text('FPT Software'), findsOneWidget);
    expect(find.text('Nguyện vọng 2'), findsOneWidget);
    expect(find.text('VNPT Telecom'), findsOneWidget);
    expect(find.text('Lý do từ chối'), findsOneWidget);
    expect(find.text('Thiếu minh chứng CPA'), findsOneWidget);
  });

  testWidgets('registered tabs render the selected tab content', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InternshipRegistrationRegisteredTabs(
                selectedIndex: selectedIndex,
                onChanged: (value) => setState(() => selectedIndex = value),
                informationContent: const Text('Current form content'),
                statusContent: const Text('Current status content'),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Current form content'), findsOneWidget);
    expect(find.text('Current status content'), findsNothing);

    await tester.tap(find.text('Trạng thái'));
    await tester.pumpAndSettle();

    expect(find.text('Current form content'), findsNothing);
    expect(find.text('Current status content'), findsOneWidget);
  });
}
