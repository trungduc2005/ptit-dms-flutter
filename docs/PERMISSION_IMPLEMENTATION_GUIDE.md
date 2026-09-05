# Hướng dẫn triển khai phân quyền theo Role cho PTIT DMS Flutter App

> **Yêu cầu cốt lõi**:
> - Phân quyền **dựa vào trường `role`** (`role: asString(json['role'])`) nhận được từ backend trong Auth Result/Session. **TUYỆT ĐỐI KHÔNG dùng `roleManagement` / `roleManagements`**.
> - Hai role cần xử lý:
>   - `student`: Giữ nguyên toàn bộ giao diện và chức năng hiện tại của app (hiển thị đầy đủ các icon trong tab Tiện ích).
>   - `lecturer`: **Ẩn toàn bộ** các icon trong phần Tiện ích, hiển thị thông báo phù hợp.

---

## 1. Khảo sát hiện trạng Codebase

### 1.1. Phân quyền trên Web (Frontend Reference)

Trên Web (`ptit-dms/management-system`), hệ thống phân biệt người dùng thông qua role chính:
- `student`: Sinh viên (xem danh sách doanh nghiệp, đăng ký thực tập, nộp báo cáo, đăng ký đồ án, NCKH...).
- `lecturer`: Giảng viên (chấm điểm, duyệt báo cáo, hướng dẫn đồ án, hội đồng...).

Web kiểm tra quyền chính bằng chuỗi `role`:
```javascript
// Web AppSidebar.jsx
if (role === "student") {
    menuItems = [homeItem, ...studentItems, personalInfoItem, settingsItem];
}

if (role === "lecturer") {
    menuItems = [
        homeItem,
        ...getAdministrativeItems(role, roleManagements),
        ...getLecturerItems(roleManagements),
        personalInfoItem,
        settingsItem,
    ];
}
```

### 1.2. Hiện trạng trên Flutter App

Trong Flutter App, dữ liệu `role` **đã được parse và lưu trữ hoàn chỉnh** trong State Management:

1. **`AuthLoginResult`** (`lib/domain/entities/auth_login_result.dart`):
   ```dart
   factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
     return AuthLoginResult(
       success: asBool(json['success']) ?? false,
       message: asString(json['message']),
       userId: asString(json['userId']),
       role: asString(json['role']), // <-- ĐÃ CÓ ROLE
     );
   }
   ```

2. **`AuthSessionUser`** (`lib/domain/entities/auth_session.dart`):
   ```dart
   role: asString(json['role']), // <-- ĐÃ CÓ ROLE
   ```

3. **`AuthState`** (`lib/features/auth/bloc/auth_state.dart`):
   ```dart
   final class AuthState extends Equatable {
     const AuthState({
       this.status = AuthStatus.initial,
       this.message,
       this.userId,
       this.role, // <-- ĐÃ CÓ ROLE TRONG STATE
     });
     ...
   ```

4. **`AuthBloc`** (`lib/features/auth/bloc/auth_bloc.dart`):
   - Khi check session thành công:
     ```dart
     emit(state.copyWith(
       status: AuthStatus.authenticated,
       userId: data.user?.userId,
       role: data.user?.role, // <-- ĐÃ EMIT ROLE
     ));
     ```
   - Khi đăng nhập thành công:
     ```dart
     emit(state.copyWith(
       status: AuthStatus.authenticated,
       userId: data.userId,
       role: data.role, // <-- ĐÃ EMIT ROLE
     ));
     ```

### 1.3. Kết luận kiến trúc

- **Data Layer & Domain Layer**: Đã đầy đủ, **KHÔNG CẦN THAY ĐỔI**.
- **AuthBloc & AuthState**: Đã lưu và emit `role`, **KHÔNG CẦN THAY ĐỔI**.
- **Nơi duy nhất cần xử lý**: `UtilitiesPage` (`lib/features/utilities/pages/utilities_page.dart`) để đọc `role` từ `AuthBloc` và ẩn icon khi người dùng là `lecturer`.

---

## 2. Quy tắc nghiệp vụ (Business Rules)

| Giá trị `role` | Hành vi tab Tiện ích |
|---|---|
| `'lecturer'` | **Ẩn toàn bộ icon/sections**. Hiển thị giao diện thông báo: tài khoản giảng viên hiện chưa có tiện ích trên mobile, vui lòng sử dụng bản web. |
| `'student'` | **Hiển thị đầy đủ** 3 mục: Thực tập, Đồ án, NCKH (giữ nguyên hiện tại). |
| `null` hoặc giá trị khác | **Mặc định hiển thị như student** (đảm bảo không bị vỡ giao diện nếu role chưa kịp tải). |

> **Lưu ý**: Tab "Tiện ích" ở Bottom Navigation Bar vẫn giữ nguyên cho mọi role, chỉ có nội dung bên trong trang `UtilitiesPage` là thay đổi theo role.

---

## 3. Hướng dẫn chi tiết triển khai

### File cần chỉnh sửa:
`lib/features/utilities/pages/utilities_page.dart`

### Các bước thực hiện:
1. Thêm import `flutter_bloc` và `AuthBloc`:
   ```dart
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
   ```
2. Trong hàm `build(BuildContext context)`:
   - Đọc `role` từ `AuthBloc`:
     ```dart
     final role = context.select<AuthBloc, String?>((bloc) => bloc.state.role);
     final isLecturer = role == 'lecturer';
     ```
   - Nếu `isLecturer == true`: render giao diện thông báo trống (Empty State).
   - Nếu `isLecturer == false`: render `SingleChildScrollView` chứa các section cards như hiện tại.

### Mã nguồn hoàn chỉnh cho `UtilitiesPage`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_routes.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utilities_section_card.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utility_shortcut_grid.dart';

class UtilitiesPage extends StatelessWidget {
  const UtilitiesPage({super.key});

  static const List<UtilityShortcutData> _internshipShortcuts = [
    UtilityShortcutData(
      title: 'Doanh\nnghiệp',
      iconAsset: 'assets/icons/company.svg',
      routeName: UtilitiesRoutes.companies,
    ),
    UtilityShortcutData(
      title: 'Đăng ký\nthực tập',
      iconAsset: 'assets/icons/register.svg',
      routeName: UtilitiesRoutes.internshipRegistration,
    ),
  ];

  static const List<UtilityShortcutData> _researchShortcuts = [
    UtilityShortcutData(
      title: 'Đăng ký\nnghiên cứu',
      iconAsset: 'assets/icons/research.svg',
      routeName: UtilitiesRoutes.researchRegistration,
    ),
    UtilityShortcutData(
      title: 'BC trước\nnghiệm thu',
      iconAsset: 'assets/icons/research_pre_acceptance_report.svg',
      routeName: UtilitiesRoutes.researchPreAcceptanceReport,
    ),
    UtilityShortcutData(
      title: 'BC sau\nnghiệm thu',
      iconAsset: 'assets/icons/research_post_acceptance_report.svg',
      routeName: UtilitiesRoutes.researchPostAcceptanceReport,
    ),
    UtilityShortcutData(
      title: 'Hội đồng\nhội thảo',
      iconAsset: 'assets/icons/committee.svg',
      routeName: UtilitiesRoutes.researchSeminarCommittee,
    ),
    UtilityShortcutData(
      title: 'Hội đồng\nnghiệm thu',
      iconAsset: 'assets/icons/committee.svg',
      routeName: UtilitiesRoutes.researchFinalCommittee,
    ),
  ];

  static const List<UtilityShortcutData> _projectShortcuts = [
    UtilityShortcutData(
      title: 'Đăng ký\nđồ án',
      iconAsset: 'assets/icons/project.svg',
      routeName: UtilitiesRoutes.projectRegistration,
    ),
    UtilityShortcutData(
      title: 'Thông tin\nhội đồng',
      iconAsset: 'assets/icons/committee.svg',
      routeName: UtilitiesRoutes.projectCommittee,
    ),
    UtilityShortcutData(
      title: 'Báo cáo\ntiến độ',
      iconAsset: 'assets/icons/progression.svg',
      routeName: UtilitiesRoutes.projectProgressReport,
    ),
    UtilityShortcutData(
      title: 'Nộp trước\nbảo vệ',
      iconAsset: 'assets/icons/project_pre_defense_submission.svg',
      routeName: UtilitiesRoutes.projectPreDefenseSubmission,
    ),
    UtilityShortcutData(
      title: 'Nộp sau\nbảo vệ',
      iconAsset: 'assets/icons/project_post_defense_submission.svg',
      routeName: UtilitiesRoutes.projectPostDefenseSubmission,
    ),
    UtilityShortcutData(
      title: 'Kết quả\nđồ án',
      iconAsset: 'assets/icons/project_result.svg',
      routeName: UtilitiesRoutes.projectResult,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final role = context.select<AuthBloc, String?>(
      (bloc) => bloc.state.role,
    );
    final isLecturer = role == 'lecturer';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AppHeader(title: 'Tiện ích'),
      body: isLecturer ? _buildLecturerEmptyState() : _buildStudentUtilities(),
    );
  }

  Widget _buildStudentUtilities() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          UtilitiesSectionCard(
            title: 'Thực tập',
            child: UtilityShortcutGrid(shortcuts: _internshipShortcuts),
          ),
          SizedBox(height: 16),
          UtilitiesSectionCard(
            title: 'Đồ án',
            child: UtilityShortcutGrid(shortcuts: _projectShortcuts),
          ),
          SizedBox(height: 16),
          UtilitiesSectionCard(
            title: 'Nghiên cứu khoa học',
            child: UtilityShortcutGrid(shortcuts: _researchShortcuts),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturerEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Color(0xFFBDBDBD),
            ),
            SizedBox(height: 16),
            Text(
              'Không có tiện ích khả dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tài khoản giảng viên hiện chưa có tiện ích trên ứng dụng di động. '
              'Vui lòng đăng nhập trên hệ thống website để thực hiện các nghiệp vụ quản lý.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Kiểm thử và Xác minh (Testing & Verification)

### 4.1. Unit / Widget Test khuyến nghị

Tạo file test: `test/features/utilities/pages/utilities_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/pages/utilities_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main breathe() {
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

  testWidgets('Hiển thị đầy đủ icon tiện ích khi role là student', (tester) async {
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
  });

  testWidgets('Hiển thị giao diện mặc định (student) khi role là null', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(
      const AuthState(status: AuthStatus.authenticated, role: null),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Thực tập'), findsOneWidget);
    expect(find.text('Không có tiện ích khả dụng'), findsNothing);
  });
}
```

### 4.2. Checklist xác minh

- [ ] Chạy `flutter analyze` để đảm bảo không có warning hoặc error.
- [ ] Chạy `flutter test test/features/utilities/pages/utilities_page_test.dart`.
- [ ] Đăng nhập tài khoản `student` → Tab Tiện ích hiển thị đầy đủ Thực tập, Đồ án, NCKH.
- [ ] Đăng nhập tài khoản `lecturer` → Tab Tiện ích hiển thị màn hình thông báo trống, không có bất kỳ icon tiện ích nào.

---

## 5. Tóm tắt cho Agent thực hiện

1. **Không sửa backend**.
2. **Không sửa Data Layer hay Domain Layer** (`AuthLoginResult`, `AuthSessionUser` đã có trường `role`).
3. **Không sửa `AuthBloc` hay `AuthState`** (đã emit `role`).
4. **Chỉ sửa `UtilitiesPage`**: Lấy `role` từ `AuthBloc` và ẩn các section card nếu `role == 'lecturer'`.
