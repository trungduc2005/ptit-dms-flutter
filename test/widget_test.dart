import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/main/pages/main_shell_page.dart';

void main() {
  testWidgets('MainShellPage hien thi 4 tab va doi tab dung noi dung',
      (WidgetTester tester) async {
    final authBloc = AuthBloc(_FakeAuthRepository());
    addTearDown(authBloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: authBloc,
          child: const MainShellPage(),
        ),
      ),
    );

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Tiện ích'), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Cá nhân'), findsOneWidget);
    expect(find.text('Màn hình Trang chủ'), findsOneWidget);

    await tester.tap(find.text('Tiện ích'));
    await tester.pumpAndSettle();
    expect(find.text('Màn hình Tiện ích'), findsOneWidget);

    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.text('Màn hình Thông báo'), findsOneWidget);

    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    expect(find.text('Màn hình Cá nhân'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Map<String, dynamic>> checkSession() async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    return <String, dynamic>{};
  }

  @override
  Future<void> logout() async {}
}
