import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_read_only_field.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';

enum ResearchRegistrationDetailResult { edit }

class ResearchRegistrationDetailPage extends StatelessWidget {
  const ResearchRegistrationDetailPage({required this.research, super.key});

  final Research research;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AppHeader(title: 'Chi tiết đề tài', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.brandColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppTheme.brandColor,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Thông tin đề tài',
                        style: TextStyle(
                          color: Color(0xFF20232A),
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (research.isEditable)
                      IconButton(
                        key: ValueKey('edit-research-${research.researchId}'),
                        tooltip: 'Chỉnh sửa',
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(ResearchRegistrationDetailResult.edit),
                        icon: const Icon(Icons.edit_outlined, size: 21),
                        color: AppTheme.brandColor,
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: Color(0xFFEEF0F3)),
                ),
                _ResearchDetails(research: research),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResearchDetails extends StatelessWidget {
  const _ResearchDetails({required this.research});

  final Research research;

  @override
  Widget build(BuildContext context) {
    final guiderName = research.guider?.lecturerName?.trim() ?? '';
    final members = research.members;

    return Column(
      children: [
        FormReadOnlyField(
          label: 'Tên chủ đề',
          value: _displayValue(research.researchTopic),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Loại hình',
          value: research.type == 'student'
              ? 'Sinh viên'
              : _displayValue(research.type),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Từ khóa',
          value: _displayValue(research.keyword),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Mục tiêu',
          value: _displayValue(research.outcome),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Nội dung',
          value: _displayValue(research.description),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Tình hình nghiên cứu trong nước',
          value: _displayValue(research.nationalOverview),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Tình hình nghiên cứu quốc tế',
          value: _displayValue(research.internationalOverview),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Tính cấp thiết của đề tài',
          value: _displayValue(research.researchNecessity),
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Giảng viên hướng dẫn',
          value: guiderName.isEmpty ? 'Chưa có thông tin' : guiderName,
        ),
        const SizedBox(height: 12),
        FormReadOnlyField(
          label: 'Trạng thái',
          value: researchStatusLabel(research.approvalStatus),
        ),
        if (members.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var index = 0; index < members.length; index++) ...[
            FormReadOnlyField(
              label: members[index].isLeader
                  ? 'Chủ nhiệm đề tài'
                  : 'Thành viên ${index + 1}',
              value: _memberLabel(members[index]),
            ),
            if (index < members.length - 1) const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  String _displayValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Chưa có thông tin' : trimmed;
  }

  String _memberLabel(ResearchMember member) {
    final name = member.memberName.trim();
    final id = member.memberId.trim();
    if (name.isNotEmpty && id.isNotEmpty) return '$name - $id';
    if (name.isNotEmpty) return name;
    return id.isNotEmpty ? id : 'Chưa có thông tin';
  }
}

String researchStatusLabel(String status) {
  switch (status.trim().toLowerCase()) {
    case 'approved':
      return 'Đã phê duyệt';
    case 'rejected':
      return 'Đã từ chối';
    case 'hasissue':
    case 'needs_revision':
      return 'Cần chỉnh sửa';
    case 'pending':
    default:
      return 'Đang chờ duyệt';
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
