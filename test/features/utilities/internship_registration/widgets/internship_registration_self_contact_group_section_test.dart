import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_self_contact_group_section.dart';

void main() {
  testWidgets(
    'group section stacks member name fields before cpa fields only',
    (tester) async {
      final searchController = TextEditingController();
      addTearDown(searchController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InternshipRegistrationSelfContactGroupSection(
                canEditForm: true,
                representativeLabel: 'Le Tuan Minh - B21DCCN001',
                isAddingMember: false,
                members: [
                  SelfContactMemberForm(
                    studentId: 'B21DCCN002',
                    label: 'Nguyen Viet Hai - B21DCCN002',
                    studentName: 'Nguyen Viet Hai',
                  ),
                ],
                searchController: searchController,
                searchResults: const <StudentSearchResult>[],
                isSearching: false,
                onStartAdd: () {},
                onCancelAdd: () {},
                onSearchChanged: (_) {},
                onAdd: (_) {},
                onRemove: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('CPA của Nguyen Viet Hai (thang 4)'), findsOneWidget);
      expect(find.text('CV cho Nguyen Viet Hai'), findsNothing);

      final memberNameTop = tester
          .getTopLeft(find.text('Nguyen Viet Hai - B21DCCN002'))
          .dy;
      final cpaTop = tester
          .getTopLeft(find.text('CPA của Nguyen Viet Hai (thang 4)'))
          .dy;

      expect(memberNameTop, lessThan(cpaTop));
    },
  );
}
