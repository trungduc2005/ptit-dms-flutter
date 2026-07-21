import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_progress_report_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_progress_report/bloc/project_progress_report_bloc.dart';

class _MockProjectProgressReportRepository extends Mock
    implements ProjectProgressReportRepository {}

void main() {
  const projectObjectId = 'project-object-1';
  const projectId = 'PROJECT-001';
  const academicYearId = 'academic-year-1';

  const request = ProjectProgressReportRequest(
    projectId: projectId,
    key: 'Tuần 1',
    brief: 'Hoàn thành phân tích yêu cầu',
    difficulty: 'Thiếu dữ liệu mẫu',
    expectation: 'Hoàn thành thiết kế',
    link: 'https://example.com/report',
    academicYearId: academicYearId,
  );

  const report = ProjectProgressReport(
    id: 'report-1',
    projectId: projectId,
    key: 'Tuần 1',
    brief: 'Hoàn thành phân tích yêu cầu',
    difficulty: 'Thiếu dữ liệu mẫu',
    expectation: 'Hoàn thành thiết kế',
    link: 'https://example.com/report',
  );

  const updatedReport = ProjectProgressReport(
    id: 'report-1',
    projectId: projectId,
    key: 'Tuần 1 - cập nhật',
    brief: 'Đã hoàn thành thiết kế',
    difficulty: 'Không',
    expectation: 'Bắt đầu lập trình',
    link: 'https://example.com/report-updated',
  );

  const reply = ProjectReportReply(
    key: 'Tuần 1',
    brief: 'Phản hồi của giảng viên',
    content: 'Tiếp tục triển khai.',
  );

  late _MockProjectProgressReportRepository repository;

  setUpAll(() {
    registerFallbackValue(request);
  });

  setUp(() {
    repository = _MockProjectProgressReportRepository();
  });

  ProjectProgressReportBloc buildBloc() =>
      ProjectProgressReportBloc(repository: repository);

  group('ProjectProgressReportBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ProjectProgressReportState());
    });

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'loads reports and replies then emits success',
      setUp: () {
        when(
          () => repository.getReports(
            projectObjectId: projectObjectId,
            academicYearId: academicYearId,
          ),
        ).thenAnswer((_) async => const [report]);
        when(
          () => repository.getReplies(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).thenAnswer((_) async => const [reply]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectProgressReportStarted(
          projectObjectId: '  $projectObjectId  ',
          projectId: '  $projectId  ',
          academicYearId: '  $academicYearId  ',
        ),
      ),
      expect: () => const [
        ProjectProgressReportState(
          loadStatus: ProjectProgressReportLoadStatus.loading,
          projectObjectId: projectObjectId,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectProgressReportState(
          loadStatus: ProjectProgressReportLoadStatus.success,
          projectObjectId: projectObjectId,
          projectId: projectId,
          academicYearId: academicYearId,
          reports: [report],
          replies: [reply],
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getReports(
            projectObjectId: projectObjectId,
            academicYearId: academicYearId,
          ),
        ).called(1);
        verify(
          () => repository.getReplies(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).called(1);
      },
    );

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'does not call repository when load parameters are invalid',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectProgressReportStarted(
          projectObjectId: ' ',
          projectId: projectId,
          academicYearId: academicYearId,
        ),
      ),
      expect: () => const [
        ProjectProgressReportState(
          loadStatus: ProjectProgressReportLoadStatus.failure,
          projectId: projectId,
          academicYearId: academicYearId,
          loadErrorMessage: 'Thiếu định danh đồ án.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.getReports(
          projectObjectId: any(named: 'projectObjectId'),
          academicYearId: any(named: 'academicYearId'),
        ),
      ),
    );

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'preserves AppException message when loading fails',
      setUp: () {
        when(
          () => repository.getReports(
            projectObjectId: projectObjectId,
            academicYearId: academicYearId,
          ),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
        when(
          () => repository.getReplies(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).thenAnswer((_) async => const []);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectProgressReportStarted(
          projectObjectId: projectObjectId,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
      ),
      expect: () => const [
        ProjectProgressReportState(
          loadStatus: ProjectProgressReportLoadStatus.loading,
          projectObjectId: projectObjectId,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectProgressReportState(
          loadStatus: ProjectProgressReportLoadStatus.failure,
          projectObjectId: projectObjectId,
          projectId: projectId,
          academicYearId: academicYearId,
          loadErrorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'creates a report and inserts it into the current list',
      setUp: () {
        when(
          () => repository.createReport(request: request),
        ).thenAnswer((_) async => report);
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ProjectProgressReportCreated(request: request)),
      expect: () => const [
        ProjectProgressReportState(
          actionStatus: ProjectProgressReportActionStatus.loading,
          action: ProjectProgressReportAction.create,
        ),
        ProjectProgressReportState(
          actionStatus: ProjectProgressReportActionStatus.success,
          action: ProjectProgressReportAction.create,
          reports: [report],
          savedReport: report,
          actionMessage: 'Tạo báo cáo tiến độ thành công.',
        ),
      ],
      verify: (_) {
        verify(() => repository.createReport(request: request)).called(1);
      },
    );

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'updates the matching report instead of adding a duplicate',
      setUp: () {
        when(
          () => repository.updateReport(request: request),
        ).thenAnswer((_) async => updatedReport);
      },
      build: buildBloc,
      seed: () => const ProjectProgressReportState(reports: [report]),
      act: (bloc) =>
          bloc.add(const ProjectProgressReportUpdated(request: request)),
      expect: () => const [
        ProjectProgressReportState(
          actionStatus: ProjectProgressReportActionStatus.loading,
          action: ProjectProgressReportAction.update,
          reports: [report],
        ),
        ProjectProgressReportState(
          actionStatus: ProjectProgressReportActionStatus.success,
          action: ProjectProgressReportAction.update,
          reports: [updatedReport],
          savedReport: updatedReport,
          actionMessage: 'Cập nhật báo cáo tiến độ thành công.',
        ),
      ],
    );

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'rejects an invalid request without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectProgressReportCreated(
          request: ProjectProgressReportRequest(
            projectId: projectId,
            key: ' ',
            brief: 'Nội dung',
            difficulty: 'Khó khăn',
            expectation: 'Kỳ vọng',
            link: 'https://example.com',
            academicYearId: academicYearId,
          ),
        ),
      ),
      expect: () => const [
        ProjectProgressReportState(
          actionStatus: ProjectProgressReportActionStatus.failure,
          action: ProjectProgressReportAction.create,
          actionMessage: 'Bạn phải nhập tiêu đề báo cáo.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.createReport(request: any(named: 'request')),
      ),
    );

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'preserves AppException message when creating fails',
      setUp: () {
        when(() => repository.createReport(request: request)).thenAnswer(
          (_) async =>
              throw const ValidationException('Đã tồn tại báo cáo tuần này.'),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ProjectProgressReportCreated(request: request)),
      expect: () => const [
        ProjectProgressReportState(
          actionStatus: ProjectProgressReportActionStatus.loading,
          action: ProjectProgressReportAction.create,
        ),
        ProjectProgressReportState(
          actionStatus: ProjectProgressReportActionStatus.failure,
          action: ProjectProgressReportAction.create,
          actionMessage: 'Đã tồn tại báo cáo tuần này.',
        ),
      ],
    );

    blocTest<ProjectProgressReportBloc, ProjectProgressReportState>(
      'clears action state without discarding loaded reports',
      build: buildBloc,
      seed: () => const ProjectProgressReportState(
        actionStatus: ProjectProgressReportActionStatus.success,
        action: ProjectProgressReportAction.create,
        reports: [report],
        savedReport: report,
        actionMessage: 'Tạo báo cáo tiến độ thành công.',
      ),
      act: (bloc) => bloc.add(const ProjectProgressReportActionStateCleared()),
      expect: () => const [
        ProjectProgressReportState(reports: [report]),
      ],
    );
  });
}
