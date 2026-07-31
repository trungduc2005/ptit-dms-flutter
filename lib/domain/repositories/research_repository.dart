import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_member_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';

abstract class ResearchRepository {
  /// Lấy các đề tài nghiên cứu của người dùng hiện tại theo năm và loại.
  Future<List<Research>> getUserResearches({
    required String yearId,
    required String type,
  });

  Future<List<ResearchMemberOption>> searchLecturers({required String query});

  Future<List<ResearchMemberOption>> searchStudents({
    required String query,
    required String academicYearId,
  });

  /// Đăng ký một đề tài nghiên cứu mới.
  Future<Research> createResearch({
    required ResearchRegistrationRequest request,
  });

  /// Cập nhật đề tài nghiên cứu chưa được duyệt.
  ///
  /// [researchId] là mã nghiệp vụ do backend sinh, không phải MongoDB `_id`.
  Future<Research> updateResearch({
    required String researchId,
    required ResearchRegistrationRequest request,
  });
}
