# PTIT DMS Flutter — Refactor Plan

## 1. Mục tiêu tài liệu

Tài liệu này là kế hoạch handoff để một coding agent khác có thể refactor codebase Flutter theo từng giai đoạn an toàn.

Các mục tiêu chính:

1. Chuẩn hóa cấu trúc thư mục của `lib/features/utilities`.
2. Giữ đúng ranh giới Clean Architecture:
   - Presentation không phụ thuộc trực tiếp vào Dio.
   - Data layer chịu trách nhiệm chuyển lỗi hạ tầng thành lỗi cấp ứng dụng.
3. Giảm trách nhiệm của các registration page đang quá lớn.
4. Loại bỏ debug code, catch rỗng và xử lý lỗi bị lặp.
5. Cải thiện khả năng test, bảo trì và mở rộng.
6. Không thay đổi hành vi nghiệp vụ hoặc giao diện ngoài phạm vi được nêu rõ.

> Nguyên tắc quan trọng: không thực hiện toàn bộ kế hoạch trong một commit hoặc một pull request. Mỗi phase phải độc lập, chạy analyzer/test thành công và có thể rollback riêng.

---

## 2. Trạng thái codebase trước refactor

Tại thời điểm lập kế hoạch:

```bash
flutter analyze
```

Kết quả:

```text
No issues found!
```

```bash
flutter test
```

Kết quả:

```text
All tests passed! — 22 tests
```

Đây là baseline bắt buộc phải được duy trì sau từng phase.

---

## 3. Các vấn đề đã xác định

### 3.1. Cấu trúc `utilities` không đồng nhất

Hiện tại `company_list` chứa đầy đủ page, BLoC và widget trong cùng feature:

```text
lib/features/utilities/company_list/
├── bloc/
├── pages/
└── widgets/
```

Nhưng các feature registration lại để page tại thư mục dùng chung:

```text
lib/features/utilities/pages/internship_registration_page.dart
lib/features/utilities/pages/project_registration_page.dart
```

Trong khi BLoC, model và widget của chúng nằm tại:

```text
lib/features/utilities/internship_registration/
lib/features/utilities/project_registration/
```

Điều này làm một feature bị phân tán ở nhiều nơi và khiến `utilities/pages` không còn thể hiện rõ vai trò.

### 3.2. Presentation phụ thuộc trực tiếp vào Dio

Nhiều BLoC bắt trực tiếp:

```dart
on DioException catch (error) {
  // ...
}
```

Các khu vực bị ảnh hưởng gồm:

- Auth.
- Profile.
- Company list.
- Project registration.
- Internship registration.

`DioException` là chi tiết hạ tầng thuộc network/data layer. BLoC thuộc presentation không nên biết project đang dùng Dio.

### 3.3. Registration page có quá nhiều trách nhiệm

Hai file chính:

```text
lib/features/utilities/pages/project_registration_page.dart
lib/features/utilities/pages/internship_registration_page.dart
```

đang đồng thời xử lý:

- Bootstrap dữ liệu.
- Form controller.
- Local form state.
- Debounce tìm kiếm.
- Search state.
- Thêm/xóa thành viên.
- Upload file/CV.
- Chọn ngày.
- Đồng bộ dữ liệu đăng ký hiện tại.
- Chuyển tab.
- Snackbar.
- Phối hợp nhiều BLoC.
- Render giao diện.

Đây là dấu hiệu của “god widget”, làm tăng rủi ro race condition, lỗi lifecycle và khó viết unit/widget test.

### 3.4. Debug code và catch không an toàn

Đã xác định:

- Có debug `print` trong:

```text
lib/data/datasources/academic_year_remote_data_source.dart
```

- Có `catch (_) {}` rỗng trong luồng auth/logout.
- Có nhiều `catch (_)` trả message chung nhưng làm mất lỗi gốc và stack trace.

### 3.5. Component form có khả năng trùng lặp

Project đã có component dùng chung tại:

```text
lib/core/widgets/form/
```

Nhưng internship registration vẫn có các component tương tự:

```text
lib/features/utilities/internship_registration/widgets/
├── internship_registration_field_shell.dart
├── internship_registration_dropdown_field.dart
├── internship_registration_section_card.dart
└── internship_registration_read_only_field.dart
```

Cần so sánh behavior và style trước khi quyết định hợp nhất. Không được hợp nhất chỉ dựa trên tên file.

### 3.6. Dependency injection có nguy cơ phình lớn

Hiện dependency được đăng ký tập trung tại:

```text
lib/core/di/injection.dart
```

Khi số feature tăng, file này sẽ khó quản lý. Đây là vấn đề ưu tiên thấp hơn error boundary và registration page.

---

## 4. Kiến trúc đích ngắn hạn

Trong phạm vi hiện tại, tiếp tục sử dụng mô hình:

```text
lib/
├── core/
├── data/
├── domain/
└── features/
```

Không chuyển toàn bộ codebase sang vertical slice trong đợt refactor này.

Cấu trúc presentation đích của `utilities`:

```text
lib/features/utilities/
├── navigation/
│   ├── utilities_router.dart
│   └── utilities_routes.dart
│
├── pages/
│   ├── utilities_page.dart
│   └── utility_placeholder_page.dart
│
├── widgets/
│   ├── utilities_section_card.dart
│   └── utility_shortcut_grid.dart
│
├── company_list/
│   ├── pages/
│   │   ├── companies_page.dart
│   │   └── company_detail_page.dart
│   ├── bloc/
│   └── widgets/
│
├── internship_registration/
│   ├── pages/
│   │   └── internship_registration_page.dart
│   ├── bloc/
│   │   ├── context/
│   │   └── submit/
│   ├── models/
│   └── widgets/
│
└── project_registration/
    ├── pages/
    │   └── project_registration_page.dart
    ├── bloc/
    │   ├── context/
    │   ├── student_search/
    │   └── submit/
    ├── models/
    └── widgets/
```

Quy ước:

- `utilities/pages` chỉ chứa page thuộc chính utilities shell/landing.
- Page thuộc utility cụ thể phải nằm trong feature tương ứng.
- Chưa thêm tầng `presentation/` riêng vì phần còn lại của codebase hiện không dùng quy ước này đồng nhất.
- Chỉ tạo `shared/` khi có code thực sự được ít nhất hai utility sử dụng và code đó không chứa nghiệp vụ riêng của một feature.

---

## 5. Data flow đích

### 5.1. Company list

```text
CompaniesPage
    ↓ dispatch event
CompanyListBloc
    ↓
CompanyRepository (domain interface)
    ↓
CompanyRepositoryImpl (data implementation)
    ↓
CompanyRemoteDataSource
    ↓
DioClient
    ↓
Backend
```

Response flow:

```text
Backend JSON
    ↓
CompanyModel.fromJson
    ↓
Company entity
    ↓
CompanyListBloc state
    ↓
CompaniesPage / CompanyListCard
```

Error flow:

```text
DioException
    ↓ map tại data/repository boundary
AppException hoặc AppFailure
    ↓
CompanyListBloc
    ↓
CompanyListFailure
    ↓
UI
```

Presentation không được import:

```dart
package:dio/dio.dart
```

### 5.2. Registration

```text
RegistrationPage
    ↓
RegistrationContextBloc
    ├── StudentProfileRepository
    ├── AcademicYearRepository
    ├── CompanyRepository
    └── RegistrationRepository
    ↓
Context state
    ↓
Form widgets
    ↓ user changes
Form state owner
    ↓ submit
RegistrationSubmitBloc
    ↓
Repository hoặc use case có business orchestration
    ↓
Remote data source
    ↓
Backend
```

Nên tách rõ ba nhóm state:

1. **Context state**
   - Dữ liệu bootstrap.
   - Profile.
   - Academic year.
   - Dropdown options.
   - Dữ liệu đăng ký hiện tại.

2. **Form state**
   - Dữ liệu người dùng đang chỉnh sửa.
   - Danh sách thành viên.
   - Loại đăng ký.
   - Khoảng thời gian.
   - File đã chọn/upload.
   - Giá trị validation.

3. **Submit state**
   - Initial.
   - Loading.
   - Success.
   - Failure.

Search sinh viên phải có state riêng vì có debounce, stale response và race condition riêng.

---

# 6. Kế hoạch triển khai

## Phase 0 — Chuẩn bị và bảo vệ baseline

### Mục tiêu

Đảm bảo agent hiểu trạng thái hiện tại và không vô tình sửa behavior khi đang move file.

### Công việc

- [ ] Kiểm tra Git working tree trước khi sửa.
- [ ] Không ghi đè hoặc rollback thay đổi chưa commit của người dùng.
- [ ] Chạy baseline:

```bash
flutter analyze
flutter test
```

- [ ] Ghi nhận lỗi có sẵn nếu kết quả khác baseline trong tài liệu này.
- [ ] Xác định tất cả import đang tham chiếu hai registration page.

Có thể tìm bằng:

```bash
rg "internship_registration_page.dart|project_registration_page.dart" lib test
```

Nếu không có `rg`, dùng công cụ search của agent.

### Tiêu chí hoàn thành

- Baseline được xác nhận.
- Danh sách file import page đã được xác định.
- Chưa thay đổi behavior hoặc source code.

---

## Phase 1 — Chuẩn hóa vị trí page trong `utilities`

### Mục tiêu

Đưa page về đúng feature folder mà không thay đổi behavior.

### Di chuyển file

Dùng `git mv` nếu có thể:

```text
lib/features/utilities/pages/internship_registration_page.dart
→ lib/features/utilities/internship_registration/pages/internship_registration_page.dart
```

```text
lib/features/utilities/pages/project_registration_page.dart
→ lib/features/utilities/project_registration/pages/project_registration_page.dart
```

Tạo thư mục `pages/` tương ứng nếu chưa tồn tại.

### File cần rà soát/chỉnh sửa

Ít nhất:

```text
lib/features/utilities/navigation/utilities_router.dart
lib/features/utilities/navigation/utilities_routes.dart
```

Ngoài ra phải search toàn bộ:

```text
lib/
test/
```

để cập nhật mọi import cũ.

### Import đích dự kiến

Trong router, tùy vị trí file và import convention hiện tại:

```dart
import '../internship_registration/pages/internship_registration_page.dart';
import '../project_registration/pages/project_registration_page.dart';
```

Hoặc dùng package import nếu project đang thống nhất package import:

```dart
import 'package:ptit_dms_flutter/features/utilities/internship_registration/pages/internship_registration_page.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/pages/project_registration_page.dart';
```

Không trộn relative import và package import tùy tiện. Phải giữ convention đang chiếm ưu thế trong file/module.

### Ràng buộc

- Không đổi tên class.
- Không đổi route path.
- Không đổi route name.
- Không đổi BLoC provisioning.
- Không thay đổi UI.
- Không refactor nội dung page trong cùng phase.
- Không chuyển `utilities_page.dart`.
- Chỉ chuyển `utility_placeholder_page.dart` nếu agent chứng minh nó chỉ thuộc một feature cụ thể; mặc định giữ nguyên.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
```

Search để bảo đảm không còn import cũ:

```bash
rg "features/utilities/pages/(internship_registration_page|project_registration_page)\.dart" lib test
```

### Tiêu chí hoàn thành

- Hai page nằm trong feature folder.
- Không còn import đến đường dẫn cũ.
- Route behavior không đổi.
- Analyzer sạch.
- Toàn bộ test pass.

### Commit gợi ý

```text
refactor(utilities): colocate registration pages with feature modules
```

---

## Phase 2 — Dọn debug code và xử lý catch không an toàn

### Mục tiêu

Loại bỏ debug output production và tránh nuốt lỗi mà chưa thay đổi kiến trúc error toàn app.

### 2.1. Xóa debug print

File:

```text
lib/data/datasources/academic_year_remote_data_source.dart
```

Xử lý đoạn dạng:

```dart
// ignore: avoid_print
print('[AcademicYearRemoteDataSource] raw first item: ${items.first}');
```

Ưu tiên:

- Xóa hoàn toàn nếu log không cần cho nghiệp vụ.
- Không thay bằng `debugPrint` nếu chỉ là debug tạm thời.
- Nếu app đã có logger abstraction thì dùng logger.
- Không thêm dependency logging mới chỉ cho một dòng log.

### 2.2. Xử lý catch rỗng trong auth/logout

Search:

```dart
catch (_) {}
```

Đặc biệt rà soát:

```text
lib/features/auth/bloc/auth_bloc.dart
lib/data/datasources/auth_remote_data_source.dart
lib/data/repositories/
```

Nếu remote logout là best effort:

1. Ghi chú rõ chủ đích.
2. Không để catch rỗng.
3. Vẫn phải clear session local trong `finally` hoặc luồng bảo đảm tương đương.
4. Nếu có logger abstraction, log error và stack trace.
5. Không hiển thị raw exception cho người dùng.

Ví dụ ý tưởng, phải điều chỉnh theo API hiện tại:

```dart
try {
  await authRepository.logout();
} catch (error, stackTrace) {
  logger.warning(
    'Remote logout failed; local session will still be cleared.',
    error,
    stackTrace,
  );
} finally {
  await sessionStorage.clear();
}
```

Không copy ví dụ nếu làm thay đổi ownership hiện tại của token/session.

### 2.3. Rà soát các catch chung

Search:

```text
catch (_)
catch (error)
```

Phân loại:

- Catch để fallback hợp lệ.
- Catch để hiển thị generic UI error.
- Catch đang nuốt lỗi.
- Catch có thể che lỗi parse JSON/type mismatch.
- Catch thiếu `mounted` check sau async trong widget.

Không sửa toàn bộ error architecture trong phase này. Chỉ xử lý debug/catch rỗng rõ ràng.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
```

Search:

```bash
rg "avoid_print|print\(|catch \(_\) \{\}" lib
```

Lưu ý: `print(` có thể xuất hiện hợp lệ trong code generated/tooling; chỉ đánh giá source production trong `lib`.

### Tiêu chí hoàn thành

- Không còn debug print đã xác định.
- Không còn catch rỗng trong logout.
- Logout vẫn clear local session theo behavior cũ.
- Analyzer sạch.
- Test pass.

### Commit gợi ý

```text
chore: remove debug output and avoid swallowed auth errors
```

---

## Phase 3 — Tạo application error boundary

### Mục tiêu

Không để `DioException` đi xuyên qua repository boundary lên presentation.

### Phạm vi triển khai đầu tiên

Chỉ migrate `company_list` làm feature mẫu vì phạm vi nhỏ.

Không migrate auth, profile và registration trong cùng commit đầu tiên.

### 3.1. Tạo lỗi cấp ứng dụng

Đề xuất vị trí:

```text
lib/core/error/
├── app_exception.dart
└── dio_exception_mapper.dart
```

Có thể dùng `AppFailure` thay cho `AppException`, nhưng agent phải chọn một mô hình và dùng nhất quán.

Phương án ít xâm lấn phù hợp codebase hiện tại: typed application exception.

Ví dụ thiết kế:

```dart
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}

final class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

final class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.fieldErrors = const {},
    super.cause,
    super.stackTrace,
  });

  final Map<String, String> fieldErrors;
}

final class ServerException extends AppException {
  const ServerException(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
}

final class UnexpectedException extends AppException {
  const UnexpectedException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}
```

Tên class có thể điều chỉnh để tránh trùng class hiện có. Phải search trước khi tạo.

### 3.2. Tạo Dio mapper

`DioExceptionMapper` chịu trách nhiệm map tối thiểu:

- Connection timeout.
- Send timeout.
- Receive timeout.
- Connection error.
- HTTP 401/403.
- HTTP 400/422 validation.
- HTTP 5xx.
- Cancelled request.
- Unknown/unexpected response.
- Backend message hợp lệ.
- Response data không đúng shape.

Không được để mapper throw thêm lỗi khi `response.data` không phải `Map<String, dynamic>`.

Ưu tiên tái sử dụng hoặc thay thế có kiểm soát logic trong:

```text
lib/core/utils/error_helpers.dart
```

Không để tồn tại hai implementation parse backend message khác nhau lâu dài.

### 3.3. Mapping tại repository boundary

Các file chính:

```text
lib/data/repositories/company_repository_impl.dart
lib/data/datasources/company_remote_data_source.dart
lib/domain/repositories/company_repository.dart
```

Repository implementation phải catch `DioException` và throw `AppException` tương ứng, hoặc datasource map rồi repository chỉ propagate. Chọn đúng một boundary thống nhất.

Khuyến nghị:

- Datasource làm HTTP và parsing.
- Repository implementation map lỗi hạ tầng.
- Domain repository interface không import Dio.
- BLoC chỉ biết application exception.

Ví dụ:

```dart
@override
Future<List<Company>> getCompanies() async {
  try {
    return await remoteDataSource.getCompanies();
  } on DioException catch (error, stackTrace) {
    throw exceptionMapper.map(error, stackTrace);
  } on FormatException catch (error, stackTrace) {
    throw UnexpectedException(
      'Dữ liệu doanh nghiệp không hợp lệ.',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
```

Cần giữ stack trace:

```dart
Error.throwWithStackTrace(mappedException, stackTrace);
```

nếu cách throw thông thường làm mất stack trace gốc.

### 3.4. Cập nhật `CompanyListBloc`

File:

```text
lib/features/utilities/company_list/bloc/company_list_bloc.dart
```

Yêu cầu:

- Xóa import Dio.
- Không gọi helper nhận `DioException`.
- Catch `AppException`.
- Vẫn giữ message và state transition tương thích UI hiện tại.
- Catch unexpected error cuối cùng với generic message an toàn.
- Không emit sau khi BLoC đã đóng.

Ví dụ:

```dart
} on AppException catch (error) {
  if (emit.isDone || isClosed) return;
  emit(state.copyWith(
    status: CompanyListStatus.failure,
    message: error.message,
  ));
} catch (error, stackTrace) {
  // Log nếu project có logger abstraction.
  if (emit.isDone || isClosed) return;
  emit(state.copyWith(
    status: CompanyListStatus.failure,
    message: 'Không thể tải danh sách doanh nghiệp.',
  ));
}
```

Phải điều chỉnh theo state API hiện tại, không tự ý đổi state model nếu không cần.

### 3.5. DI

Cập nhật:

```text
lib/core/di/injection.dart
```

nếu mapper được inject.

Mapper stateless có thể:

- Được đăng ký singleton trong DI.
- Hoặc dùng instance const/static nếu phù hợp convention hiện tại.

Không tạo service locator call bên trong repository nếu dependency có thể truyền qua constructor.

### 3.6. Test bắt buộc

Tạo hoặc cập nhật:

```text
test/core/error/dio_exception_mapper_test.dart
test/data/repositories/company_repository_impl_test.dart
test/features/utilities/company_list/bloc/company_list_bloc_test.dart
```

Test tối thiểu:

#### Dio mapper

- Timeout → network/timeout exception.
- Connection error → network exception.
- 401 → unauthorized exception.
- 422 với message → validation exception.
- 500 → server exception.
- Response payload không phải map → không crash mapper.
- Backend không có message → fallback đúng.

#### Repository

- Datasource success → trả company list.
- Datasource ném DioException → repository ném AppException.
- Parse/type error → unexpected/data exception.
- Không leak DioException ra caller.

#### BLoC

- Initial → loading → success.
- Initial → loading → failure với application exception.
- Unexpected exception → generic failure.
- Không cần import Dio trong BLoC test.

Nếu project chưa dùng `bloc_test`/`mocktail`, kiểm tra `pubspec.yaml` trước. Không thêm package nếu có thể test bằng dependency hiện có; nếu thật sự cần thêm dev dependency, tách rõ thay đổi và cập nhật lockfile.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
```

Search boundary:

```bash
rg "package:dio/dio.dart" lib/features/utilities/company_list
rg "DioException" lib/features/utilities/company_list
```

Kết quả mong đợi: không có Dio import/reference trong company presentation.

### Tiêu chí hoàn thành

- Company BLoC không phụ thuộc Dio.
- Dio được map ở data boundary.
- Mapper không crash trên malformed payload.
- Có unit test cho success/error.
- Analyzer sạch.
- Toàn bộ test pass.

### Commit gợi ý

```text
refactor(company): map dio errors at repository boundary
```

---

## Phase 4 — Migrate error boundary cho các feature còn lại

### Mục tiêu

Áp dụng pattern đã được kiểm chứng ở company cho toàn app.

### Thứ tự đề xuất

1. Academic year và student search.
2. Project registration.
3. Internship registration.
4. Profile.
5. Auth.

Auth làm cuối vì liên quan refresh token, interceptor, logout và session lifecycle.

### Khu vực cần search

```text
lib/features/auth/bloc/
lib/features/profile/bloc/
lib/features/utilities/project_registration/bloc/
lib/features/utilities/internship_registration/bloc/
```

Search:

```bash
rg "DioException|package:dio/dio.dart" lib/features
```

### Yêu cầu

- Presentation không import Dio.
- Repository implementation che giấu network client.
- Giữ nguyên UI message nếu không có lý do nghiệp vụ để đổi.
- Không log token, password, CV URL riêng tư hoặc payload chứa thông tin cá nhân.
- Refresh-token behavior phải giữ nguyên.
- Không biến mọi lỗi thành cùng một generic exception nếu UI cần phân biệt unauthorized/validation.

### Auth-specific checklist

- [ ] Refresh token chỉ chạy khi đúng điều kiện.
- [ ] Không tạo refresh loop.
- [ ] Nhiều request 401 đồng thời không tạo nhiều refresh request không kiểm soát.
- [ ] Request được retry tối đa theo behavior hiện tại.
- [ ] Nếu refresh thất bại, session được clear đúng cách.
- [ ] Logout local không phụ thuộc hoàn toàn vào remote logout.
- [ ] Không nuốt lỗi mà không có chủ đích/logging.

### Test bắt buộc

Bổ sung test theo feature trước khi hoặc cùng lúc migrate:

- BLoC success.
- Validation failure.
- Unauthorized failure.
- Network failure.
- Unexpected failure.
- Không leak DioException.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
rg "DioException|package:dio/dio.dart" lib/features
```

Kết quả cuối cùng mong đợi:

- Dio chỉ xuất hiện trong `core/network`, `data` và test hạ tầng phù hợp.
- Không xuất hiện trong presentation BLoC/page/widget.

### Commit strategy

Mỗi feature một commit hoặc PR nhỏ. Ví dụ:

```text
refactor(project-registration): decouple blocs from dio
refactor(internship-registration): decouple blocs from dio
refactor(profile): map infrastructure errors in repositories
refactor(auth): isolate dio errors from auth presentation
```

---

## Phase 5 — Tách `project_registration_page`

### Mục tiêu

Giảm trách nhiệm và kích thước của page, nhưng giữ nguyên UI và workflow.

Làm project registration trước vì có phạm vi nhỏ hơn internship registration và có thể dùng làm pattern.

### Cấu trúc đích gợi ý

```text
lib/features/utilities/project_registration/
├── pages/
│   └── project_registration_page.dart
├── bloc/
│   ├── context/
│   ├── form/
│   ├── student_search/
│   └── submit/
├── models/
│   ├── project_registration_form_state.dart
│   └── project_member_entry.dart
└── widgets/
    ├── project_registration_view.dart
    ├── project_information_section.dart
    ├── project_members_section.dart
    ├── project_member_search.dart
    ├── project_member_list.dart
    └── project_registration_actions.dart
```

Tên file có thể thay đổi dựa trên widget hiện có. Không tạo file chỉ để chứa vài dòng không có trách nhiệm rõ ràng.

### Phân chia trách nhiệm

#### `ProjectRegistrationPage`

Chỉ nên:

- Cung cấp các BLoC/Cubit cần thiết.
- Thiết lập route-level dependencies.
- Render `ProjectRegistrationView`.

#### `ProjectRegistrationView`

Chỉ nên:

- Phối hợp top-level layout.
- Chứa `BlocListener`/`BlocConsumer` cho effect.
- Điều phối snackbar/navigation sau success/failure.

#### Context BLoC

Quản lý:

- Bootstrap dữ liệu.
- Profile.
- Academic year/options.
- Current registration.
- Read-only context.

#### Student search BLoC

Quản lý:

- Query.
- Debounce hoặc droppable/restartable behavior.
- Loading.
- Result.
- Error.
- Bỏ qua stale response.

Phải tránh case:

```text
query A gửi trước
query B gửi sau
response B về trước
response A về sau và ghi đè result B
```

Có thể dùng:

- Query identity check.
- Request sequence number.
- `restartable()` event transformer nếu dependency hiện tại hỗ trợ.
- Cancel token nếu phù hợp.

#### Form state

Quản lý:

- Selected period.
- Danh sách member.
- Member add/remove.
- Giá trị editable.
- Validation cục bộ/nghiệp vụ.
- Dirty state nếu cần.

Không bắt buộc đưa `TextEditingController` vào BLoC. Controller có thể ở widget form nhỏ, nhưng dữ liệu nghiệp vụ phải có một source of truth rõ ràng.

#### Submit BLoC

Chỉ quản lý:

- Submit request.
- Loading.
- Success.
- Failure.
- Không chứa toàn bộ mutable form state nếu không cần.

### Async/null-safety checklist

- [ ] Sau mỗi `await` trong `State`, kiểm tra `mounted` trước khi dùng context/setState.
- [ ] Cancel `Timer` debounce trong `dispose`.
- [ ] Dispose tất cả controller/focus node.
- [ ] Không gọi `setState` sau dispose.
- [ ] Không để stale search response ghi đè query mới.
- [ ] Không force unwrap `!` nếu value đến từ backend/form mà chưa validate.
- [ ] Không catch parse/type error rồi âm thầm dùng dữ liệu rỗng nếu đó là lỗi contract.
- [ ] Prevent double submit.
- [ ] Submit state được reset có chủ đích.

### Test cần bổ sung

- Context bootstrap success/failure.
- Student search debounce/stale result.
- Add/remove member.
- Không thêm trùng member nếu nghiệp vụ cấm.
- Validation trước submit.
- Submit success/failure.
- Widget smoke test cho page.
- Route vẫn tạo đúng BLoC provider.

### Ràng buộc

- Không redesign UI.
- Không đổi text/label nếu không cần.
- Không đổi request payload.
- Không đổi endpoint.
- Không refactor internship page trong cùng PR.
- Không tạo một form BLoC khổng lồ thay cho một page khổng lồ.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
```

Nếu project có integration test phù hợp, chạy thêm registration flow.

### Tiêu chí hoàn thành

- Page chủ yếu làm composition.
- Logic search/member/form có thể test độc lập.
- Không có regression UI/route/request payload.
- Analyzer sạch.
- Test pass.

### Commit gợi ý

```text
refactor(project-registration): split page state and presentation responsibilities
```

---

## Phase 6 — Tách `internship_registration_page`

### Mục tiêu

Áp dụng pattern đã ổn định từ project registration cho workflow internship phức tạp hơn.

### Cấu trúc đích gợi ý

```text
lib/features/utilities/internship_registration/
├── pages/
│   └── internship_registration_page.dart
├── bloc/
│   ├── context/
│   ├── form/
│   ├── member_search/
│   ├── upload/
│   └── submit/
├── models/
└── widgets/
    ├── internship_registration_view.dart
    ├── internship_information_section.dart
    ├── internship_members_section.dart
    ├── internship_company_preferences_section.dart
    ├── internship_evidence_section.dart
    ├── internship_registered_tabs.dart
    └── internship_registration_actions.dart
```

Không bắt buộc có tất cả BLoC trên. Chỉ tách khi lifecycle/state độc lập đủ rõ.

### Trách nhiệm đặc biệt cần tách

- Self-contact member state.
- Student/member search.
- CV upload per member.
- Evidence upload.
- Preferred companies.
- Date range.
- Registration form type.
- Registered tab state.
- Current registration synchronization.
- Submit lifecycle.

### Upload state

Không nên chỉ giữ một global boolean nếu nhiều member có thể upload độc lập.

Có thể dùng:

```dart
Set<String> uploadingStudentIds
```

hoặc state map:

```dart
Map<String, UploadStatus> uploadStatusByStudentId
```

Phải giữ behavior hiện tại nếu chỉ cho phép một upload tại một thời điểm.

### File handling

- Không giữ file bytes lớn trong BLoC lâu hơn cần thiết.
- Không log file content.
- Validate extension/size theo rule hiện có.
- Khi upload thất bại, không xóa file key thành công trước đó ngoài ý muốn.
- Phân biệt picked file local và uploaded file metadata.
- Không submit khi upload bắt buộc vẫn đang chạy.

### Race condition

Kiểm tra kỹ:

- Search query cũ.
- Upload cho member đã bị xóa.
- Page dispose trong lúc upload.
- Bootstrap và user edit diễn ra đồng thời.
- Current registration reload ghi đè form người dùng đang chỉnh.
- Hai lần submit liên tiếp.

### Test bắt buộc

- Bootstrap context.
- Loại form khác nhau.
- Search member stale response.
- Add/remove member.
- Upload success/failure.
- Preferred company selection.
- Date validation.
- Submit payload theo từng registration type.
- Registered tab rendering.
- Existing registration synchronization.
- Không double submit.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
```

### Tiêu chí hoàn thành

- Page chỉ composition/effect orchestration.
- Upload, search, form và submit state có ownership rõ.
- Không regression payload/UI.
- Analyzer sạch.
- Test pass.

### Commit gợi ý

```text
refactor(internship-registration): split complex page workflows
```

---

## Phase 7 — Rà soát và hợp nhất form components

### Mục tiêu

Giảm duplication có giá trị mà không tạo “super widget” quá nhiều tham số.

### File cần so sánh

Core:

```text
lib/core/widgets/form/form_section_card.dart
lib/core/widgets/form/form_field_shell.dart
lib/core/widgets/form/form_dropdown_field.dart
lib/core/widgets/form/form_read_only_field.dart
lib/core/widgets/form/form_text_field.dart
```

Internship:

```text
lib/features/utilities/internship_registration/widgets/internship_registration_field_shell.dart
lib/features/utilities/internship_registration/widgets/internship_registration_dropdown_field.dart
lib/features/utilities/internship_registration/widgets/internship_registration_section_card.dart
lib/features/utilities/internship_registration/widgets/internship_registration_read_only_field.dart
lib/features/utilities/internship_registration/widgets/internship_registration_date_field.dart
```

Project:

```text
lib/features/utilities/project_registration/widgets/project_registration_section_card.dart
lib/features/utilities/project_registration/widgets/project_registration_sections.dart
```

### Quy tắc quyết định

Chuyển/hợp nhất vào `core` khi:

- Widget không biết entity hoặc rule của feature.
- Khác biệt chủ yếu là theme/padding/style có thể cấu hình đơn giản.
- Có ít nhất hai feature thực sự sử dụng.
- API sau hợp nhất dễ hiểu hơn code duplicate.

Giữ trong feature khi:

- Có behavior nghiệp vụ riêng.
- Biết registration type/member/company.
- Có validation riêng.
- Việc dùng widget core khiến phải thêm quá nhiều callback/flag.
- Duplication nhỏ và ổn định hơn abstraction.

### Không được làm

- Không tạo widget với hàng chục boolean flag.
- Không truyền domain object vào widget core.
- Không đổi tất cả UI component trong một commit không có test.
- Không xóa component feature trước khi search toàn bộ usage.

### Test

- Widget test cho dropdown.
- Read-only field.
- Validation/error rendering.
- Focus/open-close behavior.
- Không thay đổi semantics/accessibility ngoài ý muốn.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
```

### Commit gợi ý

```text
refactor(forms): consolidate reusable form primitives
```

---

## Phase 8 — Modular hóa dependency injection

### Mục tiêu

Giảm kích thước và trách nhiệm của:

```text
lib/core/di/injection.dart
```

### Cấu trúc gợi ý

```text
lib/core/di/
├── injection.dart
├── network_module.dart
├── auth_module.dart
├── profile_module.dart
├── company_module.dart
├── project_registration_module.dart
└── internship_registration_module.dart
```

`injection.dart` làm composition root:

```dart
Future<void> configureDependencies() async {
  registerNetworkDependencies();
  registerAuthDependencies();
  registerProfileDependencies();
  registerCompanyDependencies();
  registerProjectRegistrationDependencies();
  registerInternshipRegistrationDependencies();
}
```

Tên function phải phù hợp DI library/convention hiện tại.

### Quy tắc

- Network/core dependency đăng ký trước feature dependency.
- Không đăng ký trùng type.
- Giữ đúng singleton/factory/lazy singleton lifecycle hiện tại.
- Không gọi service locator sâu trong BLoC/repository nếu constructor injection làm được.
- Không thay đổi public DI API mà `main.dart`/`app.dart` đang gọi nếu không cần.
- Có smoke test resolve các dependency chính nếu khả thi.

### Verification

```bash
dart format lib test
flutter analyze
flutter test
```

Ngoài ra khởi động app hoặc widget smoke test để phát hiện runtime DI registration error.

### Commit gợi ý

```text
refactor(di): split dependency registration by module
```

---

## Phase 9 — Vertical slice dài hạn, không thuộc refactor bắt buộc hiện tại

### Mục tiêu

Đánh giá chuyển từ cấu trúc layer-first toàn app:

```text
lib/data/
lib/domain/
lib/features/
```

sang feature-first đầy đủ:

```text
lib/features/<feature>/
├── data/
├── domain/
└── presentation/
```

### Không thực hiện big bang

Chỉ chọn một feature nhỏ làm thử nghiệm, ví dụ company:

```text
lib/features/company/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### Điều kiện trước khi triển khai

- Error boundary đã ổn định.
- Import convention đã rõ.
- Test coverage feature đủ tốt.
- Team thống nhất ownership của shared entity/repository.
- Đã xác định thứ gì thuộc `core` và thứ gì thuộc feature.

### Lưu ý về use case

Không tạo use case chỉ để bọc một repository method mà không thêm giá trị.

Use case phù hợp khi có:

- Business validation.
- Orchestration nhiều repository.
- Authorization rule.
- Mapping input/output nghiệp vụ.
- Workflow được tái sử dụng.

Ví dụ có thể phù hợp:

```text
SubmitProjectRegistrationUseCase
RegisterInternshipWishUseCase
UploadMemberCvUseCase
BootstrapRegistrationFormUseCase
```

Không bắt buộc tạo:

```text
GetCompaniesUseCase
```

nếu nó chỉ gọi thẳng `repository.getCompanies()` mà không có business rule.

---

# 7. Danh sách file dự kiến theo phase

## Phase 1

Di chuyển:

```text
lib/features/utilities/pages/internship_registration_page.dart
lib/features/utilities/pages/project_registration_page.dart
```

Chỉnh import:

```text
lib/features/utilities/navigation/utilities_router.dart
lib/features/utilities/navigation/utilities_routes.dart
```

Và mọi usage được tìm thấy trong:

```text
lib/
test/
```

## Phase 2

Chỉnh:

```text
lib/data/datasources/academic_year_remote_data_source.dart
lib/features/auth/bloc/auth_bloc.dart
```

Có thể thêm/chỉnh logger abstraction nếu project đã có:

```text
lib/core/logging/
```

Không tự ý thêm logging package nếu chưa cần.

## Phase 3

Tạo:

```text
lib/core/error/app_exception.dart
lib/core/error/dio_exception_mapper.dart
test/core/error/dio_exception_mapper_test.dart
test/data/repositories/company_repository_impl_test.dart
test/features/utilities/company_list/bloc/company_list_bloc_test.dart
```

Chỉnh:

```text
lib/core/utils/error_helpers.dart
lib/core/di/injection.dart
lib/data/repositories/company_repository_impl.dart
lib/features/utilities/company_list/bloc/company_list_bloc.dart
```

Rà soát:

```text
lib/data/datasources/company_remote_data_source.dart
lib/domain/repositories/company_repository.dart
```

## Phase 4

Chỉnh repository implementations và BLoC tương ứng trong:

```text
lib/data/repositories/
lib/features/auth/bloc/
lib/features/profile/bloc/
lib/features/utilities/project_registration/bloc/
lib/features/utilities/internship_registration/bloc/
```

Thêm test mirror theo feature trong:

```text
test/data/repositories/
test/features/
```

## Phase 5

Chỉnh:

```text
lib/features/utilities/project_registration/pages/project_registration_page.dart
lib/features/utilities/project_registration/bloc/
lib/features/utilities/project_registration/widgets/
```

Có thể tạo:

```text
lib/features/utilities/project_registration/bloc/form/
lib/features/utilities/project_registration/models/
```

Thêm test:

```text
test/features/utilities/project_registration/
```

## Phase 6

Chỉnh:

```text
lib/features/utilities/internship_registration/pages/internship_registration_page.dart
lib/features/utilities/internship_registration/bloc/
lib/features/utilities/internship_registration/models/
lib/features/utilities/internship_registration/widgets/
```

Thêm test:

```text
test/features/utilities/internship_registration/
```

## Phase 7

Rà soát/chỉnh:

```text
lib/core/widgets/form/
lib/features/utilities/internship_registration/widgets/
lib/features/utilities/project_registration/widgets/
```

## Phase 8

Tạo/chỉnh:

```text
lib/core/di/
lib/main.dart
lib/app.dart
```

Chỉ chỉnh `main.dart`/`app.dart` nếu DI entrypoint thực sự thay đổi.

---

# 8. Quy tắc bắt buộc dành cho coding agent

## 8.1. Trước khi sửa

1. Đọc file thật, không suy đoán từ tên.
2. Search tất cả usage/import trước khi move/rename/delete.
3. Kiểm tra `pubspec.yaml`, `analysis_options.yaml` và DI hiện tại.
4. Kiểm tra working tree; không xóa thay đổi của người dùng.
5. Chạy test liên quan trước khi refactor lớn.

## 8.2. Trong khi sửa

1. Mỗi phase là một thay đổi độc lập.
2. Ưu tiên targeted edit thay vì rewrite file lớn.
3. Không đổi behavior khi mục tiêu chỉ là move file.
4. Không đổi API/backend payload trong architectural refactor.
5. Không sửa test assertion để hợp thức hóa regression.
6. Không để presentation import Dio.
7. Không dùng catch rỗng.
8. Catch async error phải cân nhắc stack trace.
9. Trong StatefulWidget:
   - Kiểm tra `mounted` sau `await`.
   - Dispose timer/controller/focus node.
   - Tránh stale response.
10. Không log dữ liệu nhạy cảm.
11. Dùng tên phản ánh trách nhiệm, tránh `helper`, `manager`, `common` quá chung chung.
12. Không thêm abstraction nếu abstraction phức tạp hơn duplication hiện tại.

## 8.3. Sau mỗi phase

Chạy:

```bash
dart format lib test
flutter analyze
flutter test
```

Sau move/rename, search đường dẫn cũ.

Sau error refactor, search:

```bash
rg "DioException|package:dio/dio.dart" lib/features
```

Sau xóa debug code, search:

```bash
rg "avoid_print|print\(|catch \(_\) \{\}" lib
```

Kiểm tra Git diff:

- Không có file ngoài phạm vi bị sửa bất ngờ.
- Không có generated artifact/temp file mới.
- Không có formatting toàn repo không cần thiết.
- Không có endpoint/request field thay đổi ngoài ý muốn.

---

# 9. Definition of Done toàn bộ kế hoạch

Kế hoạch được coi là hoàn thành khi:

## Cấu trúc

- [ ] Registration page nằm trong đúng feature folder.
- [ ] `utilities/pages` chỉ chứa utilities-level page/placeholder dùng chung.
- [ ] Không còn import đường dẫn cũ.
- [ ] Feature presentation có cấu trúc nhất quán.

## Architecture

- [ ] Presentation không import Dio.
- [ ] Repository/data boundary map lỗi hạ tầng.
- [ ] Domain interface không phụ thuộc network library.
- [ ] Error model được dùng nhất quán.
- [ ] Không có hai cách parse backend error song song không cần thiết.

## Code quality

- [ ] Không còn debug print production đã xác định.
- [ ] Không có catch rỗng.
- [ ] Generic UI error không làm mất observability hoàn toàn.
- [ ] Registration page không còn giữ toàn bộ workflow trong một State object.
- [ ] Search debounce/stale response được xử lý an toàn.
- [ ] Controller/timer/focus node được dispose.
- [ ] Component dùng chung không chứa domain-specific behavior.

## Test

- [ ] `flutter analyze` không có issue.
- [ ] Toàn bộ `flutter test` pass.
- [ ] Có test cho Dio mapper.
- [ ] Có repository test bảo đảm không leak DioException.
- [ ] Có BLoC test cho company và registration workflows chính.
- [ ] Có test cho search race condition.
- [ ] Có test cho submit success/failure.
- [ ] Có smoke/widget test cho các registration page sau khi tách.

## Behavior

- [ ] Route path/name không đổi ngoài yêu cầu.
- [ ] UI không bị redesign ngoài yêu cầu.
- [ ] Endpoint không đổi.
- [ ] Request payload không đổi.
- [ ] Auth refresh/logout behavior không regression.
- [ ] Upload CV/evidence không regression.
- [ ] Existing registration synchronization không ghi đè dữ liệu user ngoài ý muốn.

---

# 10. Thứ tự ưu tiên cuối cùng

Thực hiện theo thứ tự:

1. **Phase 1 — Move registration pages.**
2. **Phase 2 — Xóa debug print và catch rỗng.**
3. **Phase 3 — Error boundary cho company làm mẫu.**
4. **Phase 4 — Migrate error boundary theo từng feature.**
5. **Phase 5 — Tách project registration page.**
6. **Phase 6 — Tách internship registration page.**
7. **Phase 7 — Hợp nhất form primitive có chọn lọc.**
8. **Phase 8 — Modular hóa DI.**
9. **Phase 9 — Đánh giá vertical slice dài hạn.**

Nếu chỉ có thời gian làm một PR ngắn, chỉ làm Phase 1.

Nếu có thời gian làm ba PR ưu tiên cao nhất:

1. Move page.
2. Company error boundary.
3. Tách project registration page có test.

---

# 11. Prompt ngắn gợi ý cho agent triển khai

Có thể giao từng phase bằng prompt sau:

```text
Hãy triển khai Phase <N> trong REFACTOR_PLAN.md.

Yêu cầu:
- Đọc toàn bộ phần mô tả, phạm vi, ràng buộc và tiêu chí hoàn thành của phase.
- Khảo sát các file liên quan trước khi sửa, không suy đoán.
- Không triển khai phase khác.
- Không thay đổi behavior, UI, route, endpoint hoặc request payload ngoài phạm vi phase.
- Giữ Clean Architecture và convention hiện tại của project.
- Bổ sung/cập nhật test được yêu cầu.
- Sau khi sửa, chạy dart format lib test, flutter analyze và flutter test.
- Search để xác nhận không còn import/reference cũ hoặc dependency bị cấm.
- Báo cáo danh sách file đã tạo/chỉnh sửa, quyết định kỹ thuật và kết quả verification.
```

Đối với Phase 1:

```text
Hãy triển khai riêng Phase 1 trong REFACTOR_PLAN.md: chuyển hai registration page về đúng feature folder, cập nhật toàn bộ import và giữ nguyên behavior. Không refactor nội dung page. Sau đó chạy format, analyzer và toàn bộ test.
```

Đối với Phase 3:

```text
Hãy triển khai riêng Phase 3 trong REFACTOR_PLAN.md: tạo application error boundary và migrate company_list làm feature mẫu. Presentation không được import Dio. Bổ sung mapper, repository tests và CompanyListBloc tests. Không migrate feature khác trong cùng thay đổi.
```

Đối với Phase 5:

```text
Hãy triển khai riêng Phase 5 trong REFACTOR_PLAN.md: tách project_registration_page theo trách nhiệm, giữ nguyên UI/request payload/route. Viết test cho context, search, member state và submit. Không chỉnh internship_registration_page trong phase này.