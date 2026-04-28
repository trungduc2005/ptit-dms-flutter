import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/data/models/student_search_result_model.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_field_shell.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_picker_field.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_section_card.dart';

class SelfContactMemberForm {
  SelfContactMemberForm({
    required this.studentId,
    required this.label,
    required this.studentName,
  });

  final String studentId;
  final String label;
  final String studentName;
  String cpaText = '';
  String cvFileKey = '';
  String cvFileName = '';

  double get cpa => double.tryParse(cpaText.trim().replaceAll(',', '.')) ?? -1;

  bool get hasCv => cvFileKey.trim().isNotEmpty && cvFileName.trim().isNotEmpty;
}

class InternshipRegistrationSelfContactGroupSection extends StatelessWidget {
  const InternshipRegistrationSelfContactGroupSection({
    required this.canEditForm,
    required this.representativeLabel,
    required this.isAddingMember,
    required this.members,
    required this.searchController,
    required this.searchResults,
    required this.isSearching,
    required this.onStartAdd,
    required this.onCancelAdd,
    required this.onSearchChanged,
    required this.onAdd,
    required this.onRemove,
    this.representativeName,
    this.representativeCpaController,
    this.searchError,
    super.key,
  });

  final bool canEditForm;
  final String representativeLabel;
  final String? representativeName;
  final TextEditingController? representativeCpaController;
  final bool isAddingMember;
  final List<SelfContactMemberForm> members;
  final TextEditingController searchController;
  final List<StudentSearchResultModel> searchResults;
  final bool isSearching;
  final String? searchError;
  final VoidCallback onStartAdd;
  final VoidCallback onCancelAdd;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<StudentSearchResultModel> onAdd;
  final ValueChanged<SelfContactMemberForm> onRemove;

  @override
  Widget build(BuildContext context) {
    final representativeDisplayName = _displayName(
      representativeName ?? representativeLabel,
    );
    final nameFields = <Widget>[
      InternshipRegistrationPickerField<StudentSearchResultModel>(
        label: 'Thành viên nhóm',
        hintText: '',
        displayText: representativeLabel,
        readOnly: true,
        options:
            const <
              InternshipRegistrationPickerOption<StudentSearchResultModel>
            >[],
        trailing: IconButton(
          onPressed: canEditForm && !isAddingMember ? onStartAdd : null,
          icon: const Icon(Icons.add, color: Colors.black),
          tooltip: 'Thêm sinh viên',
        ),
      ),
      if (isAddingMember)
        InternshipRegistrationPickerField<StudentSearchResultModel>(
          hintText: 'Tìm sinh viên theo tên hoặc mã sinh viên',
          controller: searchController,
          enabled: canEditForm,
          options: searchResults
              .map(
                (student) => InternshipRegistrationPickerOption(
                  value: student,
                  label: _studentOptionLabel(student),
                  subtitle: _studentOptionSubtitle(student),
                ),
              )
              .toList(growable: false),
          onQueryChanged: onSearchChanged,
          onChanged: (student) {
            if (student != null) {
              onAdd(student);
            }
          },
          isLoading: isSearching,
          errorText: searchError,
          trailing: IconButton(
            onPressed: canEditForm ? onCancelAdd : null,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Xóa dòng tìm kiếm',
          ),
        ),
      ...members.map(
        (member) => InternshipRegistrationPickerField<StudentSearchResultModel>(
          hintText: '',
          displayText: member.label,
          readOnly: true,
          options:
              const <
                InternshipRegistrationPickerOption<StudentSearchResultModel>
              >[],
          trailing: IconButton(
            onPressed: canEditForm ? () => onRemove(member) : null,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Xóa sinh viên',
          ),
        ),
      ),
    ];

    final cpaFields = <Widget>[
      if (representativeCpaController != null)
        _RepresentativeCpaInput(
          studentName: representativeDisplayName,
          controller: representativeCpaController!,
          enabled: canEditForm,
        ),
      ...members.map(
        (member) => _MemberCpaInput(
          member: member,
          studentName: _displayNameForMember(member),
          enabled: canEditForm,
        ),
      ),
    ];

    return InternshipRegistrationSectionCard(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._withSpacing(nameFields),
          if (cpaFields.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._withSpacing(cpaFields),
          ],
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> children) {
    return [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) const SizedBox(height: 8),
        children[index],
      ],
    ];
  }

  String _studentOptionLabel(StudentSearchResultModel student) {
    final label = student.label.trim();
    if (label.isNotEmpty) return label;

    final name = student.studentName.trim();
    final studentId = student.studentId.trim();

    if (name.isNotEmpty && studentId.isNotEmpty) {
      return '$name - $studentId';
    }

    return name.isNotEmpty ? name : studentId;
  }

  String? _studentOptionSubtitle(StudentSearchResultModel student) {
    final studentId = student.studentId.trim();
    final label = student.label.trim();

    if (studentId.isEmpty || label.contains(studentId)) {
      return null;
    }

    return studentId;
  }
}

class InternshipRegistrationSelfContactGroupCvSection extends StatelessWidget {
  const InternshipRegistrationSelfContactGroupCvSection({
    required this.canEditForm,
    required this.representativeName,
    required this.hasRepresentativeCv,
    required this.representativeCvName,
    required this.isUploadingRepresentativeCv,
    required this.members,
    required this.uploadingMemberStudentId,
    required this.onPickRepresentativeCv,
    required this.onPickCv,
    this.pickedRepresentativeCvName,
    super.key,
  });

  final bool canEditForm;
  final String representativeName;
  final bool hasRepresentativeCv;
  final String representativeCvName;
  final String? pickedRepresentativeCvName;
  final bool isUploadingRepresentativeCv;
  final List<SelfContactMemberForm> members;
  final String? uploadingMemberStudentId;
  final VoidCallback onPickRepresentativeCv;
  final ValueChanged<SelfContactMemberForm> onPickCv;

  @override
  Widget build(BuildContext context) {
    final representativeDisplayName = _displayName(representativeName);
    final cvFields = <Widget>[
      _CvUploadField(
        studentName: representativeDisplayName,
        hasCv: hasRepresentativeCv,
        cvFileName: representativeCvName,
        pickedFileName: pickedRepresentativeCvName,
        enabled: canEditForm,
        isUploading: isUploadingRepresentativeCv,
        onTap: onPickRepresentativeCv,
      ),
      ...members.map((member) {
        final isUploading = uploadingMemberStudentId == member.studentId;

        return _CvUploadField(
          studentName: _displayNameForMember(member),
          hasCv: member.hasCv,
          cvFileName: member.cvFileName,
          enabled: canEditForm,
          isUploading: isUploading,
          onTap: () => onPickCv(member),
        );
      }),
    ];

    return InternshipRegistrationSectionCard(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < cvFields.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            cvFields[index],
          ],
        ],
      ),
    );
  }
}

String _displayNameForMember(SelfContactMemberForm member) {
  final studentName = member.studentName.trim();
  if (studentName.isNotEmpty) return studentName;

  return _displayName(member.label);
}

String _displayName(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';

  final separatorIndex = text.indexOf(' - ');
  if (separatorIndex > 0) {
    return text.substring(0, separatorIndex).trim();
  }

  return text;
}

class _RepresentativeCpaInput extends StatelessWidget {
  const _RepresentativeCpaInput({
    required this.studentName,
    required this.controller,
    required this.enabled,
  });

  final String studentName;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InternshipRegistrationFieldShell(
      label: 'CPA của $studentName (thang 4)',
      enabled: enabled,
      child: SizedBox.expand(
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          expands: true,
          minLines: null,
          maxLines: null,
          textAlignVertical: TextAlignVertical.center,
          decoration: _cpaInputDecoration,
          style: _cpaTextStyle,
        ),
      ),
    );
  }
}

class _MemberCpaInput extends StatelessWidget {
  const _MemberCpaInput({
    required this.member,
    required this.studentName,
    required this.enabled,
  });

  final SelfContactMemberForm member;
  final String studentName;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InternshipRegistrationFieldShell(
      label: 'CPA của $studentName (thang 4)',
      enabled: enabled,
      child: SizedBox.expand(
        child: TextFormField(
          key: ValueKey('cpa-${member.studentId}'),
          initialValue: member.cpaText,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          expands: true,
          minLines: null,
          maxLines: null,
          textAlignVertical: TextAlignVertical.center,
          decoration: _cpaInputDecoration,
          style: _cpaTextStyle,
          onChanged: (value) => member.cpaText = value.trim(),
        ),
      ),
    );
  }
}

class _CvUploadField extends StatelessWidget {
  const _CvUploadField({
    required this.studentName,
    required this.hasCv,
    required this.cvFileName,
    required this.enabled,
    required this.isUploading,
    required this.onTap,
    this.pickedFileName,
  });

  final String studentName;
  final bool hasCv;
  final String cvFileName;
  final String? pickedFileName;
  final bool enabled;
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pickedName = pickedFileName?.trim() ?? '';
    final effectiveCvName = cvFileName.trim();
    final displayText = isUploading
        ? 'Đang upload CV cho $studentName'
        : hasCv && effectiveCvName.isNotEmpty
        ? effectiveCvName
        : pickedName.isNotEmpty
        ? pickedName
        : 'CV cho $studentName';
    final hasFileText =
        (hasCv && effectiveCvName.isNotEmpty) ||
        pickedName.isNotEmpty ||
        isUploading;
    final textColor = hasFileText
        ? const Color(0xFF1F1F1F)
        : const Color(0xFFE5483E);
    final canTap = enabled && !isUploading && onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFADACB2), width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.attach_file,
                size: 20,
                color: enabled ? textColor : const Color(0xFF757575),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled ? textColor : const Color(0xFF757575),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
              if (isUploading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

const _cpaInputDecoration = InputDecoration(
  isCollapsed: true,
  hintText: 'Nhập CPA',
  hintStyle: TextStyle(
    color: Color(0xFF757575),
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  contentPadding: EdgeInsets.zero,
  fillColor: Colors.transparent,
  filled: false,
);

const _cpaTextStyle = TextStyle(
  color: Color(0xFF1F1F1F),
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.2,
);
