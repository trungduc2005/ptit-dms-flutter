import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/features/home/pages/home_page.dart';

void main() {
  testWidgets('uses shared app header and under construction asset', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(
      find.byKey(const Key('home_under_construction_icon')),
      findsOneWidget,
    );
  });
}
