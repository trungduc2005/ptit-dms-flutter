import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';

void main() {
  group('ProjectRegistrationRequest', () {
    test('toJson creates the same payload expected by the web API', () {
      const request = ProjectRegistrationRequest(
        academicYearId: 'year-01',
        field: 'Công nghệ phần mềm',
        period: 'Đợt 1',
        projectName: 'Hệ thống quản lý đồ án',
        keyword: 'Flutter, DMS',
        description: 'Ứng dụng quản lý đồ án sinh viên',
        outcome: 'Ứng dụng di động và báo cáo',
        guiderId: 'lecturer-01',
        guiderName: 'Nguyễn Văn A',
        members: [
          {'studentId': 'B23DCCN001'},
          {'studentId': 'B23DCCN002'},
        ],
      );

      expect(request.toJson(), {
        'academicYearId': 'year-01',
        'field': 'Công nghệ phần mềm',
        'period': 'Đợt 1',
        'projectName': 'Hệ thống quản lý đồ án',
        'keyword': 'Flutter, DMS',
        'description': 'Ứng dụng quản lý đồ án sinh viên',
        'outcome': 'Ứng dụng di động và báo cáo',
        'guiderId': 'lecturer-01',
        'guiderName': 'Nguyễn Văn A',
        'members': [
          {'studentId': 'B23DCCN001'},
          {'studentId': 'B23DCCN002'},
        ],
      });
    });

    test('toJson omits optional guider fields when no guider is selected', () {
      const request = ProjectRegistrationRequest(
        academicYearId: 'year-01',
        field: 'Mạng máy tính',
        period: 'Đợt 2',
        projectName: 'Đồ án mạng',
        keyword: 'network',
        description: 'Mô tả',
        outcome: 'Sản phẩm',
      );

      final json = request.toJson();

      expect(json.containsKey('guiderId'), isFalse);
      expect(json.containsKey('guiderName'), isFalse);
      expect(json['members'], isEmpty);
    });
  });

  group('ProjectPeriodOption', () {
    test('parses MongoDB id and name', () {
      final option = ProjectPeriodOption.fromJson({
        '_id': 'period-01',
        'name': 'Đợt 1',
      });

      expect(option.id, 'period-01');
      expect(option.name, 'Đợt 1');
    });
  });

  group('ProjectGuiderOption', () {
    test(
      'parses populated lecturer response and calculates remaining slots',
      () {
        final option = ProjectGuiderOption.fromJson({
          'lecturerId': 'lecturer-01',
          'userId': {
            'fullName': 'Nguyễn Văn A',
            'departmentId': {'name': 'Công nghệ thông tin'},
          },
          'limit': 5,
          'usedSlot': 3,
        });

        expect(option.lecturerId, 'lecturer-01');
        expect(option.fullName, 'Nguyễn Văn A');
        expect(option.departmentName, 'Công nghệ thông tin');
        expect(option.limit, 5);
        expect(option.usedSlot, 3);
        expect(option.remainingSlot, 2);
        expect(option.isFull, isFalse);
      },
    );

    test(
      'marks a lecturer as full and never returns a negative slot count',
      () {
        final option = ProjectGuiderOption.fromJson({
          '_id': 'lecturer-02',
          'fullName': 'Trần Văn B',
          'limit': 2,
          'usedSlot': 3,
        });

        expect(option.remainingSlot, 0);
        expect(option.isFull, isTrue);
      },
    );
  });
}
