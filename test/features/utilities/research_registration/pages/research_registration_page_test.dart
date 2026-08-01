import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';
import 'package:ptit_dms_flutter/domain/entities/research_member_option.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_registration/pages/research_registration_page.dart';

class _MockAcademicYearRepository extends Mock
    implements AcademicYearRepository {}

class _MockResearchRepository extends Mock implements ResearchRepository {}

class _MockStudentProfileRepository extends Mock
    implements StudentProfileRepository {}

class _MockTimelineRepository extends Mock implements TimelineRepository {}

class _FakeResearchRegistrationRequest extends Fake
    implements ResearchRegistrationRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeResearchRegistrationRequest());
  });

  const academicYear = AcademicYearOption(
    id: 'year-1',
    code: '2026-2027',
    name: 'Năm học 2026-2027',
  );

  final registrationTimeline = Timeline(
    id: 'timeline-1',
    name: 'Đăng ký nghiên cứu khoa học',
    type: 'researchRegistration',
    startTime: DateTime(2026, 8, 1, 8),
    endTime: DateTime(2026, 8, 31, 17),
  );

  late _MockAcademicYearRepository academicYearRepository;
  late _MockResearchRepository researchRepository;
  late _MockStudentProfileRepository studentProfileRepository;
  late _MockTimelineRepository timelineRepository;

  setUp(() {
    academicYearRepository = _MockAcademicYearRepository();
    researchRepository = _MockResearchRepository();
    studentProfileRepository = _MockStudentProfileRepository();
    timelineRepository = _MockTimelineRepository();

    when(
      () => academicYearRepository.getAcademicYears(),
    ).thenAnswer((_) async => const [academicYear]);
    when(() => researchRepository.searchLecturers(query: 'Nguyễn')).thenAnswer(
      (_) async => const [
        ResearchMemberOption(
          id: 'lecturer-1',
          name: 'Nguyễn Văn Hướng',
          label: 'Nguyễn Văn Hướng - lecturer-1',
        ),
      ],
    );
    when(() => studentProfileRepository.getProfile()).thenAnswer(
      (_) async => const StudentProfile(
        id: 'profile-1',
        studentId: 'B21DCCN001',
        cohort: 'D21',
        major: ['Công nghệ thông tin'],
        user: StudentProfileUser(
          id: 'user-1',
          fullName: 'Nguyễn Văn Sinh',
          username: 'B21DCCN001',
        ),
      ),
    );
    when(
      () => timelineRepository.getResearchTimelines(
        academicYearId: academicYear.id,
      ),
    ).thenAnswer((_) async => [registrationTimeline]);
  });

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AcademicYearRepository>.value(
          value: academicYearRepository,
        ),
        RepositoryProvider<ResearchRepository>.value(value: researchRepository),
        RepositoryProvider<StudentProfileRepository>.value(
          value: studentProfileRepository,
        ),
        RepositoryProvider<TimelineRepository>.value(value: timelineRepository),
      ],
      child: const MaterialApp(home: ResearchRegistrationPage()),
    );
  }

  testWidgets('hiển thị mốc thời gian và không hiển thị đề tài đã đăng ký', (
    tester,
  ) async {
    when(
      () => researchRepository.getUserResearches(
        yearId: academicYear.id,
        type: 'student',
      ),
    ).thenAnswer((_) async => const []);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Đăng ký nghiên cứu khoa học'), findsOneWidget);
    expect(find.text(academicYear.name), findsOneWidget);
    expect(find.text('Đề tài đã đăng ký'), findsNothing);
    expect(
      find.text('Bạn chưa có đề tài nghiên cứu trong năm học này.'),
      findsNothing,
    );
    expect(
      find.text('Thời gian: 01/08/2026 • 08:00 - 31/08/2026 • 17:00'),
      findsOneWidget,
    );
    expect(find.text('Thông tin đăng ký'), findsOneWidget);
    expect(find.text('Tên chủ đề *'), findsOneWidget);
    expect(find.text('Từ khóa *'), findsOneWidget);
    expect(find.text('Mục tiêu *'), findsOneWidget);
    expect(find.text('Nội dung *'), findsOneWidget);
    expect(find.text('Tình hình nghiên cứu trong nước *'), findsOneWidget);
    expect(find.text('Tình hình nghiên cứu quốc tế *'), findsOneWidget);
    expect(find.text('Tính cấp thiết của đề tài *'), findsOneWidget);
    expect(find.text('Giảng viên hướng dẫn *'), findsOneWidget);
    expect(
      find.text('Thành viên trong nhóm (tối đa 5 thành viên)'),
      findsOneWidget,
    );
    expect(find.text('Nguyễn Văn Sinh - B21DCCN001'), findsOneWidget);
    expect(find.text('Gửi đăng ký'), findsOneWidget);

    verify(() => academicYearRepository.getAcademicYears()).called(1);
    verifyNever(() => academicYearRepository.getProjectAcademicYears());
    verify(
      () => researchRepository.getUserResearches(
        yearId: academicYear.id,
        type: 'student',
      ),
    ).called(1);
    verify(
      () => timelineRepository.getResearchTimelines(
        academicYearId: academicYear.id,
      ),
    ).called(1);
    verifyNever(
      () => timelineRepository.getProjectTimelines(
        academicYearId: any(named: 'academicYearId'),
      ),
    );
  });

  testWidgets(
    'hiển thị đề tài đã đăng ký thay cho form tạo mới khi API trả dữ liệu',
    (tester) async {
      const research = Research(
        id: 'research-ref-1',
        userId: 'user-1',
        researchId: 'RESEARCH-1',
        type: 'student',
        researchTopic: 'Ứng dụng AI trong giáo dục',
        keyword: 'AI, giáo dục',
        outcome: 'Mô hình thử nghiệm',
        description: 'Nội dung nghiên cứu',
        researchNecessity: 'Tính cấp thiết',
        nationalOverview: 'Tổng quan trong nước',
        internationalOverview: 'Tổng quan quốc tế',
        yearId: 'year-1',
        approvalStatus: 'pending',
        guider: ResearchGuider(
          lecturerId: 'lecturer-1',
          lecturerName: 'Nguyễn Văn Hướng',
        ),
        members: [
          ResearchMember(
            userId: 'user-1',
            memberId: 'B21DCCN001',
            memberName: 'Nguyễn Văn Sinh',
            role: 'Leader',
          ),
        ],
        comments: [],
      );
      when(
        () => researchRepository.getUserResearches(
          yearId: academicYear.id,
          type: 'student',
        ),
      ).thenAnswer((_) async => const [research]);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Đề tài đã đăng ký'), findsOneWidget);
      expect(find.text(research.researchTopic), findsOneWidget);
      expect(find.text('Nguyễn Văn Hướng'), findsOneWidget);
      expect(find.text('Nguyễn Văn Sinh - B21DCCN001'), findsOneWidget);
      expect(find.text('Đang chờ duyệt'), findsOneWidget);
      expect(find.text('Thông tin đăng ký'), findsNothing);
      expect(find.text('Gửi đăng ký'), findsNothing);
    },
  );

  testWidgets('tìm và chọn giảng viên bằng danh sách gợi ý', (tester) async {
    when(
      () => researchRepository.getUserResearches(
        yearId: academicYear.id,
        type: 'student',
      ),
    ).thenAnswer((_) async => const []);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final lecturerDropdown = find.byKey(
      const ValueKey('research-lecturer-dropdown'),
    );
    final lecturerInput = find.byKey(
      const ValueKey('research-lecturer-search-input'),
    );
    await tester.dragUntilVisible(
      lecturerDropdown,
      find.byType(ListView).first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(lecturerDropdown, findsOneWidget);
    expect(find.text('Tìm giảng viên theo mã hoặc tên'), findsOneWidget);

    await tester.tap(lecturerInput);
    await tester.enterText(lecturerInput, 'Nguyễn');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final lecturerOption = find.text('Nguyễn Văn Hướng - lecturer-1');
    expect(lecturerOption, findsOneWidget);
    expect(
      tester.getRect(lecturerOption).bottom,
      lessThanOrEqualTo(
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      ),
    );
    expect(
      tester.hitTestOnBinding(tester.getCenter(lecturerOption)).path,
      isNotEmpty,
    );

    await tester.tap(lecturerOption);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: lecturerDropdown,
        matching: find.text('Nguyễn Văn Hướng - lecturer-1'),
      ),
      findsOneWidget,
    );

    verify(() => researchRepository.searchLecturers(query: 'Nguyễn')).called(1);

    final addMemberButton = find.text('Thêm thành viên');
    await tester.dragUntilVisible(
      addMemberButton,
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nguyễn Văn Sinh - B21DCCN001'), findsOneWidget);
    expect(addMemberButton, findsOneWidget);

    await tester.tap(addMemberButton);
    await tester.pump();

    expect(find.text('Nhập mã hoặc tên sinh viên...'), findsOneWidget);
  });

  testWidgets('kiểm tra trường bắt buộc trước khi gửi đăng ký', (tester) async {
    when(
      () => researchRepository.getUserResearches(
        yearId: academicYear.id,
        type: 'student',
      ),
    ).thenAnswer((_) async => const []);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final submitLabel = find.text('Gửi đăng ký');
    await tester.dragUntilVisible(
      submitLabel,
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(submitLabel, findsOneWidget);
    await tester.tap(submitLabel);
    await tester.pumpAndSettle();

    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Bạn phải nhập tên chủ đề.'), findsOneWidget);
    verifyNever(
      () => researchRepository.createResearch(request: any(named: 'request')),
    );
  });
}
