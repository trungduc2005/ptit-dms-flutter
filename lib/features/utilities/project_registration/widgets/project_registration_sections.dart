import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_read_only_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_section_card.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_segmented_tabs.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_text_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_option.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';

// ─── Registration tabs ───────────────────────────────────────────────────────

enum ProjectRegistrationTab { information, status }

class ProjectRegistrationTabSwitcher extends StatelessWidget {
  const ProjectRegistrationTabSwitcher({
    required this.selectedTab,
    required this.onChanged,
    super.key,
  });

  final ProjectRegistrationTab selectedTab;
  final ValueChanged<ProjectRegistrationTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormSegmentedTabs<ProjectRegistrationTab>(
      selectedValue: selectedTab,
      onChanged: onChanged,
      items: const [
        FormSegmentedTabItem(
          value: ProjectRegistrationTab.information,
          label: 'Thông tin đăng ký',
        ),
        FormSegmentedTabItem(
          value: ProjectRegistrationTab.status,
          label: 'Trạng thái',
        ),
      ],
    );
  }
}

// ─── Registration status ─────────────────────────────────────────────────────

class ProjectRegistrationStatusSection extends StatelessWidget {
  const ProjectRegistrationStatusSection({required this.project, super.key});

  final Project? project;

  @override
  Widget build(BuildContext context) {
    final currentProject = project;
    if (currentProject == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: const Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Color(0xFFADACB2)),
            SizedBox(height: 12),
            Text(
              'Chưa có thông tin trạng thái',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Thông tin sẽ được cập nhật sau khi bạn gửi đăng ký đồ án.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF5D5F5F)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _StatusCard(
          title: 'Trạng thái đăng ký',
          value: _projectStatusLabel(currentProject.status),
          color: _projectStatusColor(currentProject.status),
          icon: Icons.assignment_turned_in_outlined,
        ),
        const SizedBox(height: 12),
        _StatusCard(
          title: 'Xác nhận thành viên',
          value: _memberStatusLabel(currentProject.memberApprovalStatus),
          color: _memberStatusColor(currentProject.memberApprovalStatus),
          icon: Icons.groups_outlined,
        ),
        const SizedBox(height: 12),
        _StatusCard(
          title: 'Tiếp nhận giảng viên hướng dẫn',
          value: _guiderStatusLabel(currentProject.guiderReceptionStatus),
          color: _guiderStatusColor(currentProject.guiderReceptionStatus),
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: 12),
        _StatusCard(
          title: 'Được GVHD chấp thuận',
          value: _guiderApprovalStatusLabel(
            currentProject.guiderApprovalStatus,
          ),
          color: _guiderApprovalStatusColor(
            currentProject.guiderApprovalStatus,
          ),
          icon: Icons.fact_check_outlined,
        ),
        if (currentProject.members.isNotEmpty) ...[
          const SizedBox(height: 16),
          FormSectionCard(
            title: 'Trạng thái thành viên',
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < currentProject.members.length;
                  index++
                ) ...[
                  _MemberApprovalItem(member: currentProject.members[index]),
                  if (index < currentProject.members.length - 1)
                    const Divider(height: 24),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _projectStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Đã phê duyệt';
      case 'rejected':
        return 'Đã từ chối';
      case 'hasIssue':
      case 'project_needs_revision':
        return 'Cần chỉnh sửa';
      case 'pending':
      default:
        return 'Đang chờ duyệt';
    }
  }

  static Color _projectStatusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF16803C);
      case 'rejected':
        return const Color(0xFFBC2626);
      case 'hasIssue':
      case 'project_needs_revision':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF2563EB);
    }
  }

  static String _memberStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Đã xác nhận đầy đủ';
      case 'needs_revision':
        return 'Cần cập nhật thành viên';
      case 'waiting_members':
      default:
        return 'Đang chờ thành viên xác nhận';
    }
  }

  static Color _memberStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF16803C);
      case 'needs_revision':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF2563EB);
    }
  }

  static String _guiderStatusLabel(String status) {
    switch (status) {
      case 'assigned':
        return 'Đã phân công';
      case 'approved':
        return 'Đã tiếp nhận';
      case 'rejected':
        return 'Đã từ chối';
      case 'processing':
      default:
        return 'Đang xử lý';
    }
  }

  static Color _guiderStatusColor(String status) {
    switch (status) {
      case 'assigned':
      case 'approved':
        return const Color(0xFF16803C);
      case 'rejected':
        return const Color(0xFFBC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

  static String _guiderApprovalStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Đã chấp thuận';
      case 'rejected':
        return 'Đã từ chối';
      case 'processing':
      default:
        return 'Đang chờ chấp thuận';
    }
  }

  static Color _guiderApprovalStatusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF16803C);
      case 'rejected':
        return const Color(0xFFBC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }
}

class ProjectMembershipInvitationCard extends StatelessWidget {
  const ProjectMembershipInvitationCard({
    required this.project,
    required this.currentStudentId,
    required this.isResponding,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  final Project? project;
  final String currentStudentId;
  final bool isResponding;
  final ValueChanged<ProjectMember> onApprove;
  final ValueChanged<ProjectMember> onReject;

  @override
  Widget build(BuildContext context) {
    final normalizedStudentId = currentStudentId.trim();
    final member = project?.members
        .where(
          (item) =>
              normalizedStudentId.isNotEmpty &&
              item.studentId.trim() == normalizedStudentId,
        )
        .firstOrNull;
    final hasPendingInvitation =
        member != null &&
        !member.isLeader &&
        member.isPending &&
        member.studentRef.trim().isNotEmpty;

    if (!hasPendingInvitation) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4C95D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                color: Color(0xFFD97706),
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lời mời tham gia nhóm',
                  style: TextStyle(
                    color: Color(0xFF7C4A03),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bạn được thêm vào nhóm đồ án này. Vui lòng xác nhận hoặc từ chối lời mời.',
            style: TextStyle(
              color: Color(0xFF5D5F5F),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (isResponding)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onReject(member),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Từ chối'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFBC2626),
                      side: const BorderSide(color: Color(0xFFBC2626)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onApprove(member),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF5D5F5F),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberApprovalItem extends StatelessWidget {
  const _MemberApprovalItem({required this.member});

  final ProjectMember member;

  @override
  Widget build(BuildContext context) {
    final approved = member.isApproved;
    final name = member.studentName.trim();
    final studentId = member.studentId.trim();

    return Row(
      children: [
        Icon(
          approved ? Icons.check_circle : Icons.schedule,
          size: 22,
          color: approved ? const Color(0xFF16803C) : const Color(0xFFD97706),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : studentId,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (name.isNotEmpty && studentId.isNotEmpty)
                Text(
                  studentId,
                  style: const TextStyle(
                    color: Color(0xFF5D5F5F),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        Text(
          approved ? 'Đã xác nhận' : 'Chờ xác nhận',
          style: TextStyle(
            color: approved ? const Color(0xFF16803C) : const Color(0xFFD97706),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Section 1: Năm học + Học kỳ + Lĩnh vực ─────────────────────────────────

class ProjectRegistrationInfoSection extends StatelessWidget {
  const ProjectRegistrationInfoSection({
    required this.academicYears,
    required this.selectedAcademicYearId,
    required this.periods,
    required this.selectedPeriod,
    required this.fieldController,
    required this.isBusy,
    required this.canEdit,
    this.displayOnly = false,
    required this.onAcademicYearChanged,
    required this.onPeriodChanged,
    super.key,
  });

  final List<AcademicYearOption> academicYears;
  final String? selectedAcademicYearId;
  final List<ProjectPeriodOption> periods;
  final String? selectedPeriod;
  final TextEditingController fieldController;
  final bool isBusy;
  final bool canEdit;
  final bool displayOnly;
  final ValueChanged<String?> onAcademicYearChanged;
  final ValueChanged<String?> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final selectedAcademicYearName = academicYears
        .where((item) => item.id == selectedAcademicYearId)
        .map((item) => item.name)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayOnly)
          FormReadOnlyField(
            label: 'Năm học',
            value: selectedAcademicYearName ?? 'Chưa có thông tin',
          )
        else
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
        if (displayOnly)
          FormReadOnlyField(
            label: 'Đợt đăng ký',
            value: selectedPeriod?.trim().isNotEmpty == true
                ? selectedPeriod!
                : 'Chưa có thông tin',
          )
        else
          FormDropdownField<String>(
            label: 'Đợt đăng ký',
            value: periods.any((item) => item.name == selectedPeriod)
                ? selectedPeriod
                : null,
            hintText: periods.isEmpty
                ? 'Chưa có đợt đăng ký'
                : 'Chọn đợt đăng ký',
            enabled: canEdit && periods.isNotEmpty,
            items: periods
                .map(
                  (period) => DropdownMenuItem<String>(
                    value: period.name,
                    child: Text(period.name),
                  ),
                )
                .toList(growable: false),
            onChanged: onPeriodChanged,
          ),
        const SizedBox(height: 12),
        if (displayOnly)
          FormReadOnlyField(
            label: 'Ngành',
            value: fieldController.text.trim().isNotEmpty
                ? fieldController.text.trim()
                : 'Chưa có thông tin',
          )
        else
          FormDropdownField<String>(
            label: 'Ngành',
            value: fieldController.text.trim().isEmpty
                ? null
                : fieldController.text.trim(),
            hintText: 'Chọn ngành',
            enabled: canEdit,
            items: [
              if (fieldController.text.trim().isNotEmpty)
                DropdownMenuItem<String>(
                  value: fieldController.text.trim(),
                  child: Text(fieldController.text.trim()),
                ),
            ],
            onChanged: (value) {
              fieldController.text = value ?? '';
            },
          ),
      ],
    );
  }
}

// ─── Section 2: Thông tin đề tài ─────────────────────────────────────────────

class ProjectRegistrationProjectSection extends StatelessWidget {
  const ProjectRegistrationProjectSection({
    required this.projectNameController,
    required this.keywordController,
    required this.descriptionController,
    required this.outcomeController,
    required this.canEdit,
    this.displayOnly = false,
    super.key,
  });

  final TextEditingController projectNameController;
  final TextEditingController keywordController;
  final TextEditingController descriptionController;
  final TextEditingController outcomeController;
  final bool canEdit;
  final bool displayOnly;

  @override
  Widget build(BuildContext context) {
    if (displayOnly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormReadOnlyField(
            label: 'Tên đề tài',
            value: _displayValue(projectNameController.text),
          ),
          const SizedBox(height: 12),
          FormReadOnlyField(
            label: 'Từ khóa',
            value: _displayValue(keywordController.text),
          ),
          const SizedBox(height: 12),
          FormReadOnlyField(
            label: 'Mô tả',
            value: _displayValue(descriptionController.text),
          ),
          const SizedBox(height: 12),
          FormReadOnlyField(
            label: 'Mục tiêu đề tài',
            value: _displayValue(outcomeController.text),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          label: 'Mục tiêu đề tài',
          controller: outcomeController,
          enabled: canEdit,
          hintText: 'Nhập mục tiêu đề tài',
          height: 100,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  String _displayValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Chưa có thông tin' : trimmed;
  }
}

// ─── Section 3: Giảng viên hướng dẫn (tùy chọn) ─────────────────────────────

class ProjectRegistrationGuiderSection extends StatelessWidget {
  const ProjectRegistrationGuiderSection({
    required this.guiders,
    required this.selectedGuiderId,
    required this.canEdit,
    this.displayOnly = false,
    this.existingGuiderName,
    required this.onChanged,
    super.key,
  });

  final List<ProjectGuiderOption> guiders;
  final String? selectedGuiderId;
  final bool canEdit;
  final bool displayOnly;
  final String? existingGuiderName;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedGuider = guiders
        .where((item) => item.lecturerId == selectedGuiderId)
        .firstOrNull;
    final hasSelectedGuider = selectedGuider != null;

    if (displayOnly) {
      final guiderName = existingGuiderName?.trim().isNotEmpty == true
          ? existingGuiderName!.trim()
          : selectedGuider?.fullName.trim();

      return FormReadOnlyField(
        label: 'GVHD dự kiến',
        value: guiderName?.isNotEmpty == true
            ? guiderName!
            : 'Chưa đăng ký giảng viên hướng dẫn',
      );
    }

    return FormDropdownField<String>(
      label: 'GVHD dự kiến',
      value: hasSelectedGuider ? selectedGuiderId : null,
      hintText: guiders.isEmpty
          ? 'Chưa có giảng viên phù hợp'
          : 'Chọn giảng viên hướng dẫn',
      enabled: canEdit && guiders.isNotEmpty,
      items: guiders
          .map(
            (guider) => DropdownMenuItem<String>(
              value: guider.lecturerId,
              enabled: !guider.isFull || guider.lecturerId == selectedGuiderId,
              child: Text(
                [
                  guider.fullName,
                  if (guider.departmentName.isNotEmpty) guider.departmentName,
                  'Còn ${guider.remainingSlot}/${guider.limit} suất',
                ].join(' • '),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

// ─── Section 4: Thành viên nhóm ──────────────────────────────────────────────

class ProjectRegistrationMembersSection extends StatelessWidget {
  const ProjectRegistrationMembersSection({
    required this.leaderStudentId,
    required this.leaderFullName,
    required this.members,
    required this.minMember,
    required this.maxMember,
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

  final String leaderStudentId;
  final String leaderFullName;
  final List<ProjectMemberEntry> members;
  final int minMember;
  final int maxMember;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormReadOnlyField(
          label: minMember == maxMember
              ? 'Thành viên ($maxMember thành viên)'
              : 'Thành viên (từ $minMember đến $maxMember thành viên)',
          value: '$leaderFullName - $leaderStudentId',
        ),
        const SizedBox(height: 12),

        // Current members list
        if (members.isNotEmpty) ...[
          const SizedBox(height: 12),
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
    this.leadingIcon,
    super.key,
  });

  final String label;
  final bool canSubmit;
  final bool isViewOnly;
  final VoidCallback onSubmit;
  final IconData? leadingIcon;

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
        child: leadingIcon == null
            ? Text(label)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(leadingIcon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
