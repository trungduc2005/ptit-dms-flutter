import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_segmented_tabs.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_text_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:url_launcher/url_launcher.dart';

enum ProjectProgressReportTab { reports, replies }

class ProjectProgressReportTabSwitcher extends StatelessWidget {
  const ProjectProgressReportTabSwitcher({
    required this.selectedTab,
    required this.reportCount,
    required this.replyCount,
    required this.onChanged,
    super.key,
  });

  final ProjectProgressReportTab selectedTab;
  final int reportCount;
  final int replyCount;
  final ValueChanged<ProjectProgressReportTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormSegmentedTabs<ProjectProgressReportTab>(
      selectedValue: selectedTab,
      onChanged: onChanged,
      items: [
        FormSegmentedTabItem(
          value: ProjectProgressReportTab.reports,
          label: 'Báo cáo',
          count: reportCount,
        ),
        FormSegmentedTabItem(
          value: ProjectProgressReportTab.replies,
          label: 'Phản hồi',
          count: replyCount,
        ),
      ],
    );
  }
}

class ProjectProgressReportContextSection extends StatelessWidget {
  const ProjectProgressReportContextSection({
    required this.academicYearItems,
    required this.selectedAcademicYearId,
    required this.isAcademicYearBusy,
    required this.onAcademicYearChanged,
    required this.reportPeriodItems,
    required this.selectedReportPeriodKey,
    required this.isReportPeriodBusy,
    required this.reportPeriodEnabled,
    required this.onReportPeriodChanged,
    required this.onReportPeriodRetry,
    this.reportPeriodErrorMessage,
    super.key,
  });

  final List<AcademicYearOption> academicYearItems;
  final String? selectedAcademicYearId;
  final bool isAcademicYearBusy;
  final ValueChanged<String?> onAcademicYearChanged;
  final List<Timeline> reportPeriodItems;
  final String? selectedReportPeriodKey;
  final bool isReportPeriodBusy;
  final bool reportPeriodEnabled;
  final String? reportPeriodErrorMessage;
  final ValueChanged<String?> onReportPeriodChanged;
  final VoidCallback onReportPeriodRetry;

  @override
  Widget build(BuildContext context) {
    final hasSelectedAcademicYear = academicYearItems.any(
      (item) => item.id == selectedAcademicYearId,
    );
    final hasSelectedReportPeriod = reportPeriodItems.any(
      (item) => item.key?.trim() == selectedReportPeriodKey,
    );

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(
            icon: Icons.tune_outlined,
            title: 'Thông tin báo cáo',
          ),
          const SizedBox(height: 16),
          FormDropdownField<String>(
            label: 'Năm học',
            value: hasSelectedAcademicYear ? selectedAcademicYearId : null,
            hintText: 'Chọn năm học',
            enabled: !isAcademicYearBusy && academicYearItems.isNotEmpty,
            items: academicYearItems
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(
                      item.name.trim().isNotEmpty ? item.name : item.code,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onAcademicYearChanged,
          ),
          const SizedBox(height: 14),
          FormDropdownField<String>(
            label: 'Đợt báo cáo *',
            value: hasSelectedReportPeriod ? selectedReportPeriodKey : null,
            hintText: isReportPeriodBusy
                ? 'Đang tải danh sách đợt...'
                : 'Chọn đợt báo cáo',
            enabled:
                reportPeriodEnabled &&
                !isReportPeriodBusy &&
                reportPeriodItems.isNotEmpty,
            items: reportPeriodItems
                .asMap()
                .entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.value.key!.trim(),
                    child: Text(
                      'Đợt ${entry.key + 1}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onReportPeriodChanged,
          ),
          if (isReportPeriodBusy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ] else if (reportPeriodErrorMessage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 18,
                  color: AppTheme.brandColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reportPeriodErrorMessage!,
                    style: const TextStyle(
                      color: AppTheme.brandColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onReportPeriodRetry,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ] else if (reportPeriodEnabled && reportPeriodItems.isEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Năm học này chưa được cấu hình đợt báo cáo tiến độ.',
              style: TextStyle(
                color: Color(0xFF777C85),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ] else if (hasSelectedReportPeriod) ...[
            const SizedBox(height: 10),
            _ReportPeriodTime(
              timeline: reportPeriodItems.firstWhere(
                (item) => item.key?.trim() == selectedReportPeriodKey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportPeriodTime extends StatelessWidget {
  const _ReportPeriodTime({required this.timeline});

  final Timeline timeline;

  @override
  Widget build(BuildContext context) {
    final start = timeline.startTime;
    final end = timeline.endTime;
    if (start == null && end == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule_outlined, size: 17, color: Color(0xFF6B7280)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            start != null && end != null
                ? 'Thời gian: ${_formatDateTime(start)} - ${_formatDateTime(end)}'
                : 'Thời gian: ${_formatDateTime(start ?? end!)}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectProgressReportForm extends StatelessWidget {
  const ProjectProgressReportForm({
    required this.briefController,
    required this.difficultyController,
    required this.expectationController,
    required this.linkController,
    required this.isEditing,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final TextEditingController briefController;
  final TextEditingController difficultyController;
  final TextEditingController expectationController;
  final TextEditingController linkController;
  final bool isEditing;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionHeading(
                  icon: isEditing ? Icons.edit_note : Icons.add_chart,
                  title: isEditing ? 'Cập nhật báo cáo' : 'Báo cáo mới',
                ),
              ),
              if (isEditing)
                IconButton(
                  tooltip: 'Hủy chỉnh sửa',
                  onPressed: isSubmitting ? null : onCancel,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Nội dung đã thực hiện *',
            controller: briefController,
            enabled: !isSubmitting,
            hintText: 'Mô tả công việc và kết quả đã hoàn thành',
            height: 120,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          FormTextField(
            label: 'Khó khăn đang gặp phải *',
            controller: difficultyController,
            enabled: !isSubmitting,
            hintText: 'Nêu vấn đề, trở ngại cần hỗ trợ',
            height: 105,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          FormTextField(
            label: 'Kết quả dự kiến *',
            controller: expectationController,
            enabled: !isSubmitting,
            hintText: 'Kế hoạch và kết quả cho giai đoạn tiếp theo',
            height: 105,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          FormTextField(
            label: 'Liên kết minh chứng *',
            controller: linkController,
            enabled: !isSubmitting,
            hintText:
                'https://github.com/... hoặc https://drive.google.com/...',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox.square(
                      dimension: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isEditing ? Icons.save_outlined : Icons.send_outlined),
              label: Text(
                isSubmitting
                    ? 'Đang gửi...'
                    : isEditing
                    ? 'Lưu thay đổi'
                    : 'Gửi báo cáo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectProgressReportCard extends StatelessWidget {
  const ProjectProgressReportCard({
    required this.report,
    required this.index,
    required this.onEdit,
    super.key,
  });

  final ProjectProgressReport report;
  final int index;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.brandColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.brandColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chi tiết báo cáo',
                        style: TextStyle(
                          color: Color(0xFF20232A),
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (report.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(report.createdAt!),
                          style: const TextStyle(
                            color: Color(0xFF8A9099),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Chỉnh sửa',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 21),
                  color: AppTheme.brandColor,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF0F3)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ReportDetail(
                  icon: Icons.task_alt_outlined,
                  label: 'Đã thực hiện',
                  value: report.brief,
                  color: const Color(0xFF21835A),
                ),
                const SizedBox(height: 14),
                _ReportDetail(
                  icon: Icons.warning_amber_rounded,
                  label: 'Khó khăn',
                  value: report.difficulty,
                  color: const Color(0xFFC47B10),
                ),
                const SizedBox(height: 14),
                _ReportDetail(
                  icon: Icons.flag_outlined,
                  label: 'Dự kiến',
                  value: report.expectation,
                  color: const Color(0xFF3E67B1),
                ),
                const SizedBox(height: 14),
                _ReportLinkDetail(link: report.link),
                if (report.replies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.forum_outlined,
                          color: AppTheme.brandColor,
                          size: 19,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          '${report.replies.length} phản hồi từ giảng viên',
                          style: const TextStyle(
                            color: Color(0xFF5A3A3A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportDetail extends StatelessWidget {
  const _ReportDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF444850),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportLinkDetail extends StatelessWidget {
  const _ReportLinkDetail({required this.link});

  final String link;

  Future<void> _openLink(BuildContext context) async {
    final normalizedLink = link.trim();
    final uri = Uri.tryParse(
      normalizedLink.startsWith(RegExp(r'https?://', caseSensitive: false))
          ? normalizedLink
          : 'https://$normalizedLink',
    );

    if (uri == null ||
        !const {'http', 'https'}.contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty) {
      _showLinkError(context, 'Link đính kèm không hợp lệ.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      _showLinkError(context, 'Không thể mở link đính kèm.');
    }
  }

  void _showLinkError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.link, color: AppTheme.brandColor, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Link',
                style: TextStyle(
                  color: AppTheme.brandColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _openLink(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Link đính kèm'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProjectReportReplyCard extends StatelessWidget {
  const ProjectReportReplyCard({
    required this.reply,
    required this.lecturerName,
    super.key,
  });

  final ProjectReportReply reply;
  final String lecturerName;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.mark_unread_chat_alt_outlined,
                    color: AppTheme.brandColor,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chi tiết phản hồi',
                        style: TextStyle(
                          color: Color(0xFF20232A),
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (reply.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(reply.createdAt!),
                          style: const TextStyle(
                            color: Color(0xFF8A9099),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF0F3)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.brandColor,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        lecturerName.trim().isEmpty
                            ? 'Giảng viên hướng dẫn'
                            : lecturerName.trim(),
                        style: const TextStyle(
                          color: AppTheme.brandColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  reply.content,
                  style: const TextStyle(
                    color: Color(0xFF363A42),
                    fontSize: 14,
                    height: 1.5,
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

class ProjectProgressReportEmptyState extends StatelessWidget {
  const ProjectProgressReportEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.brandColor, size: 32),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF292C32),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF777C85),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectProgressReportErrorState extends StatelessWidget {
  const ProjectProgressReportErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.brandColor,
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF555A63),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.brandColor, size: 22),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF24272D),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EBEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} • $hour:$minute';
}
