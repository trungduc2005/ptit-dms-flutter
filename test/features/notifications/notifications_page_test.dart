import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/features/notifications/notifications_page.dart';

void main() {
  testWidgets('uses shared app header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationsPage()));

    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(
      find.byKey(const Key('notifications_under_construction_icon')),
      findsOneWidget,
    );
  });
}
