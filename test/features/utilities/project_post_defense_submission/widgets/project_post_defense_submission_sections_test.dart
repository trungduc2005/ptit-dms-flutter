import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_time_range_caption.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/features/utilities/project_post_defense_submission/widgets/project_post_defense_submission_sections.dart';

void main() {
  const academicYear = AcademicYearOption(
    id: 'academic-year-1',
    code: '2026-2027',
    name: 'Năm học 2026-2027',
  );

  Widget buildSubject({Timeline? timeline}) {
    return MaterialApp(
      home: Scaffold(
        body: ProjectPostDefenseContextSection(
          academicYears: const [academicYear],
          selectedAcademicYearId: academicYear.id,
          timeline: timeline,
          isBusy: false,
          onChanged: (_) {},
        ),
      ),
    );
  }

  testWidgets('hiển thị thời gian API bên dưới phần chọn năm học', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        timeline: Timeline(
          id: 'timeline-post-1',
          name: 'Nộp báo cáo sau bảo vệ',
          startTime: DateTime(2026, 8, 1, 8),
          endTime: DateTime(2026, 8, 15, 17, 30),
        ),
      ),
    );

    expect(find.byType(FormDropdownField<String>), findsOneWidget);
    expect(find.byType(FormTimeRangeCaption), findsOneWidget);
    expect(
      find.text('Thời gian: 01/08/2026 • 08:00 - 15/08/2026 • 17:30'),
      findsOneWidget,
    );

    final dropdownTop = tester.getTopLeft(
      find.byType(FormDropdownField<String>),
    );
    final captionTop = tester.getTopLeft(find.byType(FormTimeRangeCaption));
    expect(captionTop.dy, greaterThan(dropdownTop.dy));
  });

  testWidgets('không hiển thị dòng thời gian khi API chưa có timeline', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(FormTimeRangeCaption), findsNothing);
    expect(find.textContaining('Thời gian:'), findsNothing);
  });
}
