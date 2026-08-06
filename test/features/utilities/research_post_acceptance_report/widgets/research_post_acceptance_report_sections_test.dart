import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/features/utilities/research_post_acceptance_report/widgets/research_post_acceptance_report_sections.dart';

void main() {
  const academicYear = AcademicYearOption(
    id: 'academic-year-1',
    code: '2026-2027',
    name: 'Năm học 2026-2027',
  );
  const research = Research(
    id: 'research-document-1',
    userId: 'user-1',
    researchId: 'research-1',
    type: 'StudentResearch',
    researchTopic: 'Ứng dụng trí tuệ nhân tạo',
    keyword: 'AI',
    outcome: 'Sản phẩm nghiên cứu',
    description: 'Mô tả đề tài',
    researchNecessity: 'Tính cấp thiết',
    nationalOverview: 'Tổng quan trong nước',
    internationalOverview: 'Tổng quan quốc tế',
    yearId: 'academic-year-1',
    approvalStatus: 'Approved',
    members: [],
    comments: [],
  );

  Widget buildContextSection() {
    return MaterialApp(
      home: Scaffold(
        body: ResearchPostAcceptanceContextSection(
          academicYears: const [academicYear],
          researches: const [research],
          selectedAcademicYearId: academicYear.id,
          selectedResearchId: research.researchId,
          isBusy: false,
          onAcademicYearChanged: (_) {},
          onResearchChanged: (_) {},
        ),
      ),
    );
  }

  Widget buildUploadSection({
    required Map<
      ResearchPostAcceptanceFileType,
      ResearchPostAcceptanceUploadFile?
    >
    files,
    bool isUploading = false,
    double uploadProgress = 0,
    VoidCallback? onSubmit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ResearchPostAcceptanceUploadSection(
            files: files,
            enabled: true,
            isUploading: isUploading,
            uploadProgress: uploadProgress,
            isResubmission: false,
            onPick: (_) {},
            onRemove: (_) {},
            onSubmit: onSubmit ?? () {},
          ),
        ),
      ),
    );
  }

  Map<ResearchPostAcceptanceFileType, ResearchPostAcceptanceUploadFile?>
  emptyFiles() => {
    for (final type in ResearchPostAcceptanceFileType.values) type: null,
  };

  ResearchPostAcceptanceUploadFile fileFor(
    ResearchPostAcceptanceFileType type,
  ) {
    return ResearchPostAcceptanceUploadFile(
      fileName: '${type.name}.pdf',
      bytes: Uint8List.fromList(const [1, 2, 3]),
      size: 3,
    );
  }

  testWidgets('hiển thị năm học và đề tài nghiên cứu đã chọn', (tester) async {
    await tester.pumpWidget(buildContextSection());

    expect(find.text('Thông tin báo cáo'), findsOneWidget);
    expect(find.text(academicYear.name), findsOneWidget);
    expect(find.text(research.researchTopic), findsOneWidget);
  });

  testWidgets('vô hiệu hóa nút nộp khi chưa chọn đủ 6 tệp bắt buộc', (
    tester,
  ) async {
    await tester.pumpWidget(buildUploadSection(files: emptyFiles()));

    final button = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('research-post-acceptance-submit')),
    );
    expect(button.onPressed, isNull);
    expect(
      find.text(
        'Cần chọn đầy đủ 6 tệp. Hỗ trợ PDF, DOC, DOCX; tối đa 10 MB mỗi tệp.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('cho phép nộp khi đã chọn đủ 6 tệp bắt buộc', (tester) async {
    final files = emptyFiles();
    for (final type in ResearchPostAcceptanceFileType.values) {
      if (type != ResearchPostAcceptanceFileType.paper) {
        files[type] = fileFor(type);
      }
    }
    var submitted = false;

    await tester.pumpWidget(
      buildUploadSection(files: files, onSubmit: () => submitted = true),
    );

    final submitFinder = find.byKey(
      const ValueKey('research-post-acceptance-submit'),
    );
    final button = tester.widget<ElevatedButton>(submitFinder);
    expect(button.onPressed, isNotNull);

    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    expect(submitted, isTrue);
  });

  testWidgets('hiển thị tiến độ và khóa nút khi đang tải lên', (tester) async {
    await tester.pumpWidget(
      buildUploadSection(
        files: emptyFiles(),
        isUploading: true,
        uploadProgress: 0.45,
      ),
    );

    expect(
      find.byKey(const ValueKey('research-post-acceptance-upload-progress')),
      findsOneWidget,
    );
    expect(find.text('45%'), findsOneWidget);
    expect(find.text('Đang nộp báo cáo...'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('research-post-acceptance-submit')),
    );
    expect(button.onPressed, isNull);
  });
}
