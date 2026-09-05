import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';
import 'package:ptit_dms_flutter/features/utilities/research_final_committee/widgets/research_final_committee_sections.dart';

void main() {
  const academicYear = AcademicYearOption(
    id: 'academic-year-1',
    code: '2026-2027',
    name: 'Năm học 2026-2027',
  );
  const research = ResearchFinalOption(
    researchId: 'research-1',
    researchTopic: 'Ứng dụng trí tuệ nhân tạo trong giáo dục',
  );
  final committee = ResearchFinalCommittee(
    committeeId: 'committee-1',
    name: 'Hội đồng nghiệm thu nghiên cứu khoa học số 1',
    time: '08:30',
    date: DateTime(2026, 8, 12),
    location: 'Phòng 101 - A2',
    members: const [
      ResearchFinalCommitteeMember(
        memberId: 'member-1',
        memberName: 'Nguyễn Văn An',
        department: 'Khoa Công nghệ thông tin',
        role: 'Chủ tịch',
      ),
      ResearchFinalCommitteeMember(
        memberId: 'member-2',
        memberName: 'Trần Thị Bình',
        department: 'Khoa Đa phương tiện',
        role: 'Thư ký',
      ),
    ],
    research: const ResearchFinalCommitteeResearch(
      researchId: 'research-1',
      researchTopic: 'Ứng dụng trí tuệ nhân tạo trong giáo dục',
      presentationOrder: 2,
      reviewerName: 'PGS. TS. Lê Văn Cường',
    ),
  );

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('hiển thị bộ lọc năm học và đề tài nghiệm thu đã chọn', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ResearchFinalCommitteeFilterSection(
          academicYears: const [academicYear],
          researches: const [research],
          selectedAcademicYearId: academicYear.id,
          selectedResearchId: research.researchId,
          isYearLoading: false,
          isCommitteeLoading: false,
          onAcademicYearChanged: (_) {},
          onResearchChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Thông tin nghiệm thu'), findsOneWidget);
    expect(find.text(academicYear.name), findsOneWidget);
    expect(find.text(research.researchTopic), findsOneWidget);
  });

  testWidgets('hiển thị tiến độ khi đang tải danh sách đề tài', (tester) async {
    await tester.pumpWidget(
      wrap(
        ResearchFinalCommitteeFilterSection(
          academicYears: const [academicYear],
          researches: const [],
          selectedAcademicYearId: academicYear.id,
          selectedResearchId: null,
          isYearLoading: false,
          isCommitteeLoading: true,
          onAcademicYearChanged: (_) {},
          onResearchChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Đang tải danh sách đề tài...'), findsOneWidget);
  });

  testWidgets('hiển thị đầy đủ thông tin hội đồng nghiệm thu và thành viên', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(ResearchFinalCommitteeOverviewSection(committee: committee)),
    );

    expect(find.text(committee.name), findsOneWidget);
    expect(find.text(committee.research.researchTopic), findsOneWidget);
    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('12/08/2026'), findsOneWidget);
    expect(find.text('Phòng 101 - A2'), findsOneWidget);
    expect(find.text('PGS. TS. Lê Văn Cường'), findsOneWidget);
    expect(find.text('2 thành viên'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('Chủ tịch'), findsOneWidget);
    expect(find.text('Trần Thị Bình'), findsOneWidget);
    expect(find.text('Thư ký'), findsOneWidget);
  });

  testWidgets('hiển thị giá trị dự phòng khi lịch chưa được cập nhật', (
    tester,
  ) async {
    const incompleteCommittee = ResearchFinalCommittee(
      committeeId: 'committee-2',
      name: 'Hội đồng nghiệm thu số 2',
      members: [],
      research: ResearchFinalCommitteeResearch(
        researchId: 'research-2',
        researchTopic: 'Đề tài chưa xếp lịch',
        presentationOrder: -1,
      ),
    );

    await tester.pumpWidget(
      wrap(
        const ResearchFinalCommitteeOverviewSection(
          committee: incompleteCommittee,
        ),
      ),
    );

    expect(find.text('N/A'), findsNWidgets(5));
    expect(find.text('Chưa cập nhật'), findsNothing);
    expect(find.text('Chưa có thông tin thành viên hội đồng.'), findsOneWidget);

    for (final text in tester.widgetList<Text>(find.text('N/A'))) {
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    }
  });

  testWidgets(
    'xếp giá trị xuống dưới nhãn dài trên màn hình điện thoại để không bị cắt',
    (tester) async {
      const incompleteCommittee = ResearchFinalCommittee(
        committeeId: 'committee-compact',
        name: 'Hội đồng nghiệm thu',
        members: [],
        research: ResearchFinalCommitteeResearch(
          researchId: 'research-compact',
          researchTopic: 'Đề tài kiểm thử responsive',
          presentationOrder: -1,
        ),
      );
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrap(
          const ResearchFinalCommitteeOverviewSection(
            committee: incompleteCommittee,
          ),
        ),
      );

      final presentationLabel = find.text('Thứ tự trình bày:');
      expect(presentationLabel, findsOneWidget);

      final labelTop = tester.getTopLeft(presentationLabel).dy;
      final fallbackValues = find.text('N/A');
      final hasFallbackBelowLabel = fallbackValues
          .evaluate()
          .map((element) => find.byWidget(element.widget))
          .any((finder) => tester.getTopLeft(finder).dy > labelTop);

      expect(hasFallbackBelowLabel, isTrue);
    },
  );

  testWidgets('hiển thị empty state', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ResearchFinalCommitteeEmptyState(
          title: 'Chưa được phân hội đồng',
          message: 'Thông tin hội đồng nghiệm thu chưa được công bố.',
        ),
      ),
    );

    expect(find.text('Chưa được phân hội đồng'), findsOneWidget);
    expect(
      find.text('Thông tin hội đồng nghiệm thu chưa được công bố.'),
      findsOneWidget,
    );
  });

  testWidgets('hiển thị lỗi và gọi callback thử lại', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      wrap(
        ResearchFinalCommitteeErrorState(
          message: 'Không thể kết nối máy chủ.',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('Không thể tải thông tin'), findsOneWidget);
    expect(find.text('Không thể kết nối máy chủ.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('research-final-committee-retry')),
    );

    expect(retried, isTrue);
  });
}
