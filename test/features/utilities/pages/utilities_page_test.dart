import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/pages/utilities_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const UtilitiesPage(),
      ),
    );
  }

  testWidgets('Hiển thị đầy đủ icon tiện ích khi role là student', (
    tester,
  ) async {
    when(() => mockAuthBloc.state).thenReturn(
      const AuthState(status: AuthStatus.authenticated, role: 'student'),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Thực tập'), findsOneWidget);
    expect(find.text('Đồ án'), findsOneWidget);
    expect(find.text('Nghiên cứu khoa học'), findsOneWidget);
    expect(find.text('Không có tiện ích khả dụng'), findsNothing);
  });

  testWidgets('Ẩn toàn bộ icon tiện ích khi role là lecturer', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(
      const AuthState(status: AuthStatus.authenticated, role: 'lecturer'),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Thực tập'), findsNothing);
    expect(find.text('Đồ án'), findsNothing);
    expect(find.text('Nghiên cứu khoa học'), findsNothing);
    expect(find.text('Không có tiện ích khả dụng'), findsOneWidget);
    expect(
      find.textContaining(
        'Tài khoản giảng viên hiện chưa có tiện ích trên ứng dụng di động.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
  });

  testWidgets('Hiển thị giao diện mặc định (student) khi role là null', (
    tester,
  ) async {
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthState(status: AuthStatus.authenticated, role: null));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Thực tập'), findsOneWidget);
    expect(find.text('Đồ án'), findsOneWidget);
    expect(find.text('Nghiên cứu khoa học'), findsOneWidget);
    expect(find.text('Không có tiện ích khả dụng'), findsNothing);
  });
}
