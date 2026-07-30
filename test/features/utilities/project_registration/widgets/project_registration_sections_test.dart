import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_time_range_caption.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/widgets/project_registration_sections.dart';

void main() {
  const academicYear = AcademicYearOption(
    id: 'academic-year-1',
    code: '2026-2027',
    name: 'Năm học 2026-2027',
  );

  Widget buildSubject({Timeline? registrationTimeline}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProjectRegistrationInfoSection(
            academicYears: const [academicYear],
            selectedAcademicYearId: academicYear.id,
            periods: const [],
            selectedPeriod: null,
            registrationTimeline: registrationTimeline,
            fieldController: TextEditingController(),
            isBusy: false,
            canEdit: true,
            onAcademicYearChanged: (_) {},
            onPeriodChanged: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('hiển thị thời gian API ngay dưới phần chọn năm học', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        registrationTimeline: Timeline(
          id: 'project-registration-timeline-1',
          name: 'Đăng ký đồ án',
          startTime: DateTime(2026, 8, 1, 8),
          endTime: DateTime(2026, 8, 15, 17, 30),
        ),
      ),
    );

    expect(find.byType(FormTimeRangeCaption), findsOneWidget);
    expect(
      find.text('Thời gian: 01/08/2026 • 08:00 - 15/08/2026 • 17:30'),
      findsOneWidget,
    );

    final academicYearLabelTop = tester.getTopLeft(find.text('Năm học'));
    final captionTop = tester.getTopLeft(find.byType(FormTimeRangeCaption));
    final registrationPeriodLabelTop = tester.getTopLeft(
      find.text('Đợt đăng ký'),
    );

    expect(captionTop.dy, greaterThan(academicYearLabelTop.dy));
    expect(captionTop.dy, lessThan(registrationPeriodLabelTop.dy));
  });

  testWidgets('không hiển thị thời gian khi API chưa có mốc thời gian', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(FormTimeRangeCaption), findsNothing);
    expect(find.textContaining('Thời gian:'), findsNothing);
  });
}
