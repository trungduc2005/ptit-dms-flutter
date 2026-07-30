import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_time_range_caption.dart';

void main() {
  Widget buildSubject({DateTime? startTime, DateTime? endTime}) {
    return MaterialApp(
      home: Scaffold(
        body: FormTimeRangeCaption(startTime: startTime, endTime: endTime),
      ),
    );
  }

  testWidgets('hiển thị đầy đủ khoảng thời gian và biểu tượng đồng hồ', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        startTime: DateTime(2026, 7, 9, 8),
        endTime: DateTime(2026, 7, 31, 6),
      ),
    );

    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    expect(
      find.text('Thời gian: 09/07/2026 • 08:00 - 31/07/2026 • 06:00'),
      findsOneWidget,
    );
  });

  testWidgets('hiển thị mốc có sẵn khi khoảng thời gian chỉ có một đầu', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(startTime: DateTime(2026, 7, 9, 8)));

    expect(find.text('Thời gian: 09/07/2026 • 08:00'), findsOneWidget);
  });

  testWidgets('không hiển thị nội dung khi không có thời gian', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byIcon(Icons.schedule_outlined), findsNothing);
    expect(find.textContaining('Thời gian:'), findsNothing);
  });
}
