import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_read_only_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_section_card.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_text_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';

// ─── Section 1: Năm học + Học kỳ + Lĩnh vực ─────────────────────────────────

class ProjectRegistrationInfoSection extends StatelessWidget {
  const ProjectRegistrationInfoSection({
    required this.academicYears,
    required this.selectedAcademicYearId,
    required this.selectedPeriod,
    required this.fieldController,
    required this.isBusy,
    required this.canEdit,
    required this.onAcademicYearChanged,
    required this.onPeriodChanged,
    super.key,
  });

  final List<AcademicYearOption> academicYears;
  final String? selectedAcademicYearId;
  final String? selectedPeriod;
  final TextEditingController fieldController;
  final bool isBusy;
  final bool canEdit;
  final ValueChanged<String?> onAcademicYearChanged;
  final ValueChanged<String?> onPeriodChanged;

  static const List<_PeriodOption> _periods = [
    _PeriodOption(value: '1', label: 'Học kỳ 1'),
    _PeriodOption(value: '2', label: 'Học kỳ 2'),
    _PeriodOption(value: '3', label: 'Học kỳ hè'),
  ];

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Thông tin đăng ký',
      child: Column(
        children: [
          FormDropdownField<String>(
            label: 'Năm học',
            value: selectedAcademicYearId,
            hintText: 'Chọn năm học',
            enabled: !isBusy,
            items: academicYears
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(item.name),
                  ),
                )
                .toList(growable: false),
            onChanged: onAcademicYearChanged,
          ),
          const SizedBox(height: 12),
          FormDropdownField<String>(
            label: 'Học kỳ',
            value: selectedPeriod,
            hintText: 'Chọn học kỳ',
            enabled: canEdit,
            items: _periods
                .map(
                  (p) => DropdownMenuItem<String>(
                    value: p.value,
                    child: Text(p.label),
                  ),
                )
                .toList(growable: false),
            onChanged: onPeriodChanged,
          ),
          const SizedBox(height: 12),
          FormTextField(
            label: 'Lĩnh vực',
            controller: fieldController,
            enabled: canEdit,
            hintText: 'Nhập lĩnh vực đề tài',
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}

class _PeriodOption {
  const _PeriodOption({required this.value, required this.label});
  final String value;
  final String label;
}

// ─── Section 2: Thông tin sinh viên (read-only) ───────────────────────────────

class ProjectRegistrationStudentSection extends StatelessWidget {
  const ProjectRegistrationStudentSection({
    required this.studentId,
    required this.fullName,
    required this.className,
    super.key,
  });

  final String studentId;
  final String fullName;
  final String className;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Thông tin sinh viên',
      child: Column(
        children: [
          FormReadOnlyField(label: 'Mã sinh viên', value: studentId),
          const SizedBox(height: 12),
          FormReadOnlyField(label: 'Họ và tên', value: fullName),
          const SizedBox(height: 12),
          FormReadOnlyField(label: 'Lớp', value: className),
        ],
      ),
    );
  }
}

// ─── Section 3: Thông tin đề tài ─────────────────────────────────────────────

class ProjectRegistrationProjectSection extends StatelessWidget {
  const ProjectRegistrationProjectSection({
    required this.projectNameController,
    required this.keywordController,
    required this.descriptionController,
    required this.outcomeController,
    required this.canEdit,
    super.key,
  });

  final TextEditingController projectNameController;
  final TextEditingController keywordController;
  final TextEditingController descriptionController;
  final TextEditingController outcomeController;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Thông tin đề tài',
      child: Column(
        children: [
          FormTextField(
            label: 'Tên đề tài',
            controller: projectNameController,
            enabled: canEdit,
            hintText: 'Nhập tên đề tài',
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          FormTextField(
            label: 'Từ khóa',
            controller: keywordController,
            enabled: canEdit,
            hintText: 'Nhập từ khóa (phân cách bằng dấu phẩy)',
          ),
          const SizedBox(height: 12),
          FormTextField(
            label: 'Mô tả',
            controller: descriptionController,
            enabled: canEdit,
            hintText: 'Nhập mô tả đề tài',
            height: 120,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          FormTextField(
            label: 'Kết quả dự kiến',
            controller: outcomeController,
            enabled: canEdit,
            hintText: 'Nhập kết quả dự kiến',
            height: 100,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}

// ─── Section 4: Giảng viên hướng dẫn (tùy chọn) ─────────────────────────────

class ProjectRegistrationGuiderSection extends StatelessWidget {
  const ProjectRegistrationGuiderSection({
    required this.guiderNameController,
    required this.canEdit,
    super.key,
  });

  final TextEditingController guiderNameController;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Giảng viên hướng dẫn',
      child: FormTextField(
        label: 'Tên giảng viên hướng dẫn (tùy chọn)',
        controller: guiderNameController,
        enabled: canEdit,
        hintText: 'Nhập tên giảng viên',
        textCapitalization: TextCapitalization.words,
      ),
    );
  }
}

// ─── Section 5: Thành viên nhóm ──────────────────────────────────────────────

class ProjectRegistrationMembersSection extends StatelessWidget {
  const ProjectRegistrationMembersSection({
    required this.members,
    required this.searchController,
    required this.searchResults,
    required this.isSearching,
    required this.searchError,
    required this.isAddingMember,
    required this.canEdit,
    required this.onStartAdd,
    required this.onCancelAdd,
    required this.onSearchChanged,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final List<ProjectMemberEntry> members;
  final TextEditingController searchController;
  final List<StudentSearchResult> searchResults;
  final bool isSearching;
  final String? searchError;
  final bool isAddingMember;
  final bool canEdit;
  final VoidCallback onStartAdd;
  final VoidCallback onCancelAdd;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<StudentSearchResult> onAdd;
  final ValueChanged<ProjectMemberEntry> onRemove;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Thành viên nhóm',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current members list
          if (members.isNotEmpty) ...[
            ...members.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MemberTile(
                  member: member,
                  canEdit: canEdit,
                  onRemove: () => onRemove(member),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Add member button or search field
          if (canEdit) ...[
            if (!isAddingMember)
              OutlinedButton.icon(
                onPressed: onStartAdd,
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Thêm thành viên'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              )
            else
              _MemberSearchField(
                controller: searchController,
                results: searchResults,
                isSearching: isSearching,
                error: searchError,
                onChanged: onSearchChanged,
                onCancel: onCancelAdd,
                onSelect: onAdd,
              ),
          ],
        ],
      ),
    );
  }
}

class ProjectMemberEntry {
  const ProjectMemberEntry({
    required this.studentId,
    required this.label,
    this.studentName = '',
  });

  final String studentId;
  final String label;
  final String studentName;
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.canEdit,
    required this.onRemove,
  });

  final ProjectMemberEntry member;
  final bool canEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18, color: Color(0xFF5D5F5F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              member.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
          if (canEdit)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 18,
                color: Color(0xFF5D5F5F),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberSearchField extends StatelessWidget {
  const _MemberSearchField({
    required this.controller,
    required this.results,
    required this.isSearching,
    required this.error,
    required this.onChanged,
    required this.onCancel,
    required this.onSelect,
  });

  final TextEditingController controller;
  final List<StudentSearchResult> results;
  final bool isSearching;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;
  final ValueChanged<StudentSearchResult> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFADACB2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        onChanged: onChanged,
                        decoration: const InputDecoration(
                          hintText: 'Nhập mã hoặc tên sinh viên...',
                          hintStyle: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onCancel, child: const Text('Hủy')),
          ],
        ),
        if (isSearching)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error!,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
            ),
          )
        else if (results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: results
                  .map(
                    (student) => InkWell(
                      onTap: () => onSelect(student),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 18,
                              color: Color(0xFF5D5F5F),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatLabel(student),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1F1F1F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }

  String _formatLabel(StudentSearchResult student) {
    final label = student.label.trim();
    if (label.isNotEmpty) return label;

    final name = student.studentName.trim();
    final id = student.studentId.trim();

    if (name.isNotEmpty && id.isNotEmpty) return '$name ($id)';
    return name.isNotEmpty ? name : id;
  }
}

// ─── Submit Button ────────────────────────────────────────────────────────────

class ProjectRegistrationSubmitButton extends StatelessWidget {
  const ProjectRegistrationSubmitButton({
    required this.label,
    required this.canSubmit,
    required this.isViewOnly,
    required this.onSubmit,
    super.key,
  });

  final String label;
  final bool canSubmit;
  final bool isViewOnly;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (isViewOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Hồ sơ đang ở chế độ chỉ xem.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? onSubmit : null,
        child: Text(label),
      ),
    );
  }
}
