import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research_seminar_committee.dart';

const _titleColor = Color(0xFF202124);
const _mutedColor = Color(0xFF6B7280);
const _borderColor = Color(0xFFE7E8EC);

class ResearchSeminarCommitteeFilterSection extends StatelessWidget {
  const ResearchSeminarCommitteeFilterSection({
    required this.academicYears,
    required this.researches,
    required this.selectedAcademicYearId,
    required this.selectedResearchId,
    required this.isYearLoading,
    required this.isCommitteeLoading,
    required this.onAcademicYearChanged,
    required this.onResearchChanged,
    super.key,
  });

  final List<AcademicYearOption> academicYears;
  final List<ResearchSeminarOption> researches;
  final String? selectedAcademicYearId;
  final String? selectedResearchId;
  final bool isYearLoading;
  final bool isCommitteeLoading;
  final ValueChanged<String?> onAcademicYearChanged;
  final ValueChanged<String?> onResearchChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelectedYear = academicYears.any(
      (year) => year.id == selectedAcademicYearId,
    );
    final hasSelectedResearch = researches.any(
      (research) => research.researchId == selectedResearchId,
    );

    return ResearchSeminarCommitteeSurfaceCard(
      key: const ValueKey('research-seminar-committee-filter'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ResearchSeminarCommitteeSectionHeading(
            icon: Icons.tune_outlined,
            title: 'Thông tin hội thảo',
          ),
          const SizedBox(height: 16),
          FormDropdownField<String>(
            key: const ValueKey('research-seminar-committee-year-dropdown'),
            label: 'Năm học',
            value: hasSelectedYear ? selectedAcademicYearId : null,
            hintText: isYearLoading ? 'Đang tải năm học...' : 'Chọn năm học',
            enabled: !isYearLoading && academicYears.isNotEmpty,
            items: academicYears
                .map(
                  (year) => DropdownMenuItem<String>(
                    value: year.id,
                    child: Text(
                      year.name.trim().isNotEmpty ? year.name : year.code,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onAcademicYearChanged,
          ),
          const SizedBox(height: 14),
          FormDropdownField<String>(
            key: const ValueKey('research-seminar-committee-research-dropdown'),
            label: 'Đề tài hội thảo',
            value: hasSelectedResearch ? selectedResearchId : null,
            hintText: isCommitteeLoading
                ? 'Đang tải danh sách đề tài...'
                : 'Chọn đề tài hội thảo',
            enabled: !isCommitteeLoading && researches.isNotEmpty,
            items: researches
                .map(
                  (research) => DropdownMenuItem<String>(
                    value: research.researchId,
                    child: Text(
                      research.researchTopic,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onResearchChanged,
          ),
          if (isYearLoading || isCommitteeLoading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }
}

class ResearchSeminarCommitteeOverviewSection extends StatelessWidget {
  const ResearchSeminarCommitteeOverviewSection({
    required this.committee,
    super.key,
  });

  final ResearchSeminarCommittee committee;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CommitteeSummaryCard(committee: committee),
        const SizedBox(height: 16),
        ResearchSeminarCommitteeMembersSection(members: committee.members),
      ],
    );
  }
}

class ResearchSeminarCommitteeMembersSection extends StatelessWidget {
  const ResearchSeminarCommitteeMembersSection({
    required this.members,
    super.key,
  });

  final List<ResearchSeminarCommitteeMember> members;

  @override
  Widget build(BuildContext context) {
    return ResearchSeminarCommitteeSurfaceCard(
      key: const ValueKey('research-seminar-committee-members'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Thành viên hội đồng',
                    style: TextStyle(
                      color: _titleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE8E6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${members.length} thành viên',
                    style: const TextStyle(
                      color: AppTheme.brandColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _borderColor),
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chưa có thông tin thành viên hội đồng.',
                style: TextStyle(color: _mutedColor, fontSize: 14),
              ),
            )
          else
            for (var index = 0; index < members.length; index++) ...[
              _CommitteeMemberTile(number: index + 1, member: members[index]),
              if (index < members.length - 1)
                const Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: Color(0xFFEDEEF1),
                ),
            ],
        ],
      ),
    );
  }
}

class ResearchSeminarCommitteeEmptyState extends StatelessWidget {
  const ResearchSeminarCommitteeEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.groups_2_outlined,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _MessageState(icon: icon, title: title, message: message);
  }
}

class ResearchSeminarCommitteeErrorState extends StatelessWidget {
  const ResearchSeminarCommitteeErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageState(
      icon: Icons.error_outline_rounded,
      title: 'Không thể tải thông tin',
      message: message,
      action: OutlinedButton.icon(
        key: const ValueKey('research-seminar-committee-retry'),
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 19),
        label: const Text('Thử lại'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.brandColor,
          side: const BorderSide(color: AppTheme.brandColor),
        ),
      ),
    );
  }
}

class _CommitteeSummaryCard extends StatelessWidget {
  const _CommitteeSummaryCard({required this.committee});

  final ResearchSeminarCommittee committee;

  @override
  Widget build(BuildContext context) {
    return ResearchSeminarCommitteeSurfaceCard(
      key: const ValueKey('research-seminar-committee-summary'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5F4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_2_outlined,
                    color: AppTheme.brandColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hội đồng hội thảo',
                        style: TextStyle(
                          color: _mutedColor,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _displayValue(committee.name),
                        style: const TextStyle(
                          color: AppTheme.brandColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryItem(
                  icon: Icons.science_outlined,
                  label: 'Đề tài',
                  value: _displayValue(committee.research.researchTopic),
                ),
                const SizedBox(height: 18),
                _SummaryRow(
                  first: _SummaryItem(
                    icon: Icons.schedule_outlined,
                    label: 'Thời gian',
                    value: _displayValue(committee.time),
                    valueColor: AppTheme.brandColor,
                  ),
                  second: _SummaryItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày',
                    value: _formatDate(committee.date),
                    valueColor: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 18),
                _SummaryRow(
                  first: _SummaryItem(
                    icon: Icons.location_on_outlined,
                    label: 'Địa điểm',
                    value: _displayValue(committee.location),
                    valueColor: const Color(0xFF1565C0),
                  ),
                  second: _SummaryItem(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'Thứ tự trình bày',
                    value: committee.research.presentationOrder < 0
                        ? 'Chưa cập nhật'
                        : committee.research.presentationOrder.toString(),
                  ),
                ),
                const SizedBox(height: 18),
                _SummaryItem(
                  icon: Icons.rate_review_outlined,
                  label: 'Người phản biện',
                  value: _displayValue(committee.research.reviewerName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = _titleColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _mutedColor),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _mutedColor,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommitteeMemberTile extends StatelessWidget {
  const _CommitteeMemberTile({required this.number, required this.member});

  final int number;
  final ResearchSeminarCommitteeMember member;

  @override
  Widget build(BuildContext context) {
    final name = _displayValue(member.memberName);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Text(
                '$number',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _mutedColor, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _MemberAvatar(avatarUrl: member.avatarUrl, name: name),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: _titleColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (member.role.trim().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _RoleBadge(role: member.role),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _displayValue(member.department),
                    style: const TextStyle(
                      color: _mutedColor,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.avatarUrl, required this.name});

  final String? avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final validAvatar = avatarUrl?.trim().isNotEmpty == true;

    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFE5E7EB),
      foregroundImage: validAvatar ? NetworkImage(avatarUrl!) : null,
      child: validAvatar
          ? null
          : Text(
              _initials(name),
              style: const TextStyle(
                color: _mutedColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final normalizedRole = role.trim().toLowerCase();
    final Color foreground;
    final Color background;

    if (normalizedRole.contains('chủ tịch')) {
      foreground = const Color(0xFFD32F2F);
      background = const Color(0xFFFFEBEE);
    } else if (normalizedRole.contains('thư ký')) {
      foreground = const Color(0xFF1565C0);
      background = const Color(0xFFE3F2FD);
    } else if (normalizedRole.contains('phản biện')) {
      foreground = const Color(0xFF7B1FA2);
      background = const Color(0xFFF3E5F5);
    } else {
      foreground = const Color(0xFF4B5563);
      background = const Color(0xFFF3F4F6);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ResearchSeminarCommitteeSectionHeading extends StatelessWidget {
  const ResearchSeminarCommitteeSectionHeading({
    required this.icon,
    required this.title,
    super.key,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.brandColor, size: 22),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class ResearchSeminarCommitteeSurfaceCard extends StatelessWidget {
  const ResearchSeminarCommitteeSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ResearchSeminarCommitteeSurfaceCard(
      key: const ValueKey('research-seminar-committee-message'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
        child: Column(
          children: [
            Icon(icon, size: 52, color: const Color(0xFFB8BBC2)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _titleColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _mutedColor,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

String _displayValue(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? 'Chưa cập nhật' : text;
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Chưa cập nhật';
  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  return '$day/$month/${localDate.year}';
}

String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty || name == 'Chưa cập nhật') return '?';
  if (words.length == 1) return words.first[0].toUpperCase();
  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}
