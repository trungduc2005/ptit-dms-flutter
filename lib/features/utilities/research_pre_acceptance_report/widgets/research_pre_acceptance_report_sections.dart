import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';

class ResearchPreAcceptanceContextSection extends StatelessWidget {
  const ResearchPreAcceptanceContextSection({
    required this.academicYears,
    required this.researches,
    required this.selectedAcademicYearId,
    required this.selectedResearchId,
    required this.isBusy,
    required this.onAcademicYearChanged,
    required this.onResearchChanged,
    super.key,
  });

  final List<AcademicYearOption> academicYears;
  final List<Research> researches;
  final String? selectedAcademicYearId;
  final String? selectedResearchId;
  final bool isBusy;
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

    return ResearchPreAcceptanceSurfaceCard(
      key: const ValueKey('research-pre-acceptance-context'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ResearchPreAcceptanceSectionHeading(
            icon: Icons.tune_outlined,
            title: 'Thông tin báo cáo',
          ),
          const SizedBox(height: 16),
          FormDropdownField<String>(
            key: const ValueKey('research-pre-acceptance-year-dropdown'),
            label: 'Năm học',
            value: hasSelectedYear ? selectedAcademicYearId : null,
            hintText: 'Chọn năm học',
            enabled: !isBusy && academicYears.isNotEmpty,
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
            key: const ValueKey('research-pre-acceptance-research-dropdown'),
            label: 'Đề tài nghiên cứu',
            value: hasSelectedResearch ? selectedResearchId : null,
            hintText: isBusy
                ? 'Đang tải danh sách đề tài...'
                : 'Chọn đề tài nghiên cứu',
            enabled: !isBusy && researches.isNotEmpty,
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
          if (isBusy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }
}

class ResearchPreAcceptanceUploadSection extends StatelessWidget {
  const ResearchPreAcceptanceUploadSection({
    required this.reportFile,
    required this.turnitinReportFile,
    required this.enabled,
    required this.isUploading,
    required this.uploadProgress,
    required this.isResubmission,
    required this.onPickReport,
    required this.onPickTurnitin,
    required this.onRemoveReport,
    required this.onRemoveTurnitin,
    required this.onSubmit,
    super.key,
  });

  final ResearchPreAcceptanceUploadFile? reportFile;
  final ResearchPreAcceptanceUploadFile? turnitinReportFile;
  final bool enabled;
  final bool isUploading;
  final double uploadProgress;
  final bool isResubmission;
  final VoidCallback onPickReport;
  final VoidCallback onPickTurnitin;
  final VoidCallback onRemoveReport;
  final VoidCallback onRemoveTurnitin;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hasRequiredFiles = reportFile != null && turnitinReportFile != null;

    return ResearchPreAcceptanceSurfaceCard(
      key: const ValueKey('research-pre-acceptance-upload-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResearchPreAcceptanceSectionHeading(
            icon: isResubmission
                ? Icons.replay_outlined
                : Icons.cloud_upload_outlined,
            title: isResubmission ? 'Nộp lại báo cáo' : 'Tệp báo cáo',
          ),
          const SizedBox(height: 8),
          const Text(
            'Cần chọn đủ hai tệp. Hỗ trợ PDF, DOC, DOCX; tối đa 10 MB mỗi tệp.',
            style: TextStyle(
              color: Color(0xFF747982),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ResearchPreAcceptanceFilePicker(
            key: const ValueKey('research-pre-acceptance-report-file'),
            title: 'Quyển báo cáo',
            subtitle: 'Bản báo cáo trước nghiệm thu',
            icon: Icons.description_outlined,
            file: reportFile,
            enabled: enabled && !isUploading,
            onPick: onPickReport,
            onRemove: onRemoveReport,
          ),
          const SizedBox(height: 12),
          ResearchPreAcceptanceFilePicker(
            key: const ValueKey('research-pre-acceptance-turnitin-file'),
            title: 'Báo cáo kiểm tra đạo văn',
            subtitle: 'Báo cáo Turnitin hoặc tệp kiểm tra tương đồng',
            icon: Icons.fact_check_outlined,
            file: turnitinReportFile,
            enabled: enabled && !isUploading,
            onPick: onPickTurnitin,
            onRemove: onRemoveTurnitin,
          ),
          if (isUploading) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Đang tải lên...',
                  style: TextStyle(
                    color: Color(0xFF555A63),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(uploadProgress.clamp(0, 1) * 100).round()}%',
                  key: const ValueKey(
                    'research-pre-acceptance-upload-progress',
                  ),
                  style: const TextStyle(
                    color: AppTheme.brandColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: uploadProgress > 0 ? uploadProgress.clamp(0, 1) : null,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              key: const ValueKey('research-pre-acceptance-submit'),
              onPressed: enabled && hasRequiredFiles && !isUploading
                  ? onSubmit
                  : null,
              icon: isUploading
                  ? const SizedBox.square(
                      dimension: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                isUploading
                    ? 'Đang nộp báo cáo...'
                    : isResubmission
                    ? 'Nộp lại báo cáo'
                    : 'Nộp báo cáo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResearchPreAcceptanceFilePicker extends StatelessWidget {
  const ResearchPreAcceptanceFilePicker({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ResearchPreAcceptanceUploadFile? file;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selectedFile = file;

    return Material(
      color: selectedFile == null
          ? const Color(0xFFFAFAFB)
          : const Color(0xFFF4FAF7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onPick : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selectedFile == null
                  ? const Color(0xFFE1E4E9)
                  : const Color(0xFFB9DDCB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedFile == null
                      ? AppTheme.brandColor.withValues(alpha: 0.08)
                      : const Color(0xFFE1F4EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  selectedFile == null ? icon : Icons.check_circle_outline,
                  color: selectedFile == null
                      ? AppTheme.brandColor
                      : const Color(0xFF21835A),
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedFile?.fileName ?? title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF292D34),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedFile == null
                          ? subtitle
                          : _formatFileSize(selectedFile.effectiveSize),
                      style: const TextStyle(
                        color: Color(0xFF7A7F88),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (selectedFile == null)
                const Icon(Icons.add_circle_outline, color: AppTheme.brandColor)
              else
                IconButton(
                  tooltip: 'Bỏ chọn',
                  onPressed: enabled ? onRemove : null,
                  icon: const Icon(Icons.close, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResearchPreAcceptanceStatusSection extends StatelessWidget {
  const ResearchPreAcceptanceStatusSection({required this.report, super.key});

  final ResearchPreAcceptanceReport report;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(report.status);

    return ResearchPreAcceptanceSurfaceCard(
      key: const ValueKey('research-pre-acceptance-status'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ResearchPreAcceptanceSectionHeading(
            icon: Icons.verified_outlined,
            title: 'Trạng thái hiện tại',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(report.status), color: color, size: 25),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(report.status),
                        style: TextStyle(
                          color: color,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _statusDescription(report.status),
                        style: const TextStyle(
                          color: Color(0xFF626771),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
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

class ResearchPreAcceptanceHistorySection extends StatelessWidget {
  const ResearchPreAcceptanceHistorySection({
    required this.reports,
    this.onOpenFile,
    super.key,
  });

  final List<ResearchPreAcceptanceReport> reports;
  final ValueChanged<String>? onOpenFile;

  @override
  Widget build(BuildContext context) {
    return ResearchPreAcceptanceSurfaceCard(
      key: const ValueKey('research-pre-acceptance-history'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResearchPreAcceptanceSectionHeading(
            icon: Icons.history,
            title: 'Lịch sử nộp (${reports.length})',
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < reports.length; index++) ...[
            ResearchPreAcceptanceHistoryCard(
              key: ValueKey(
                'research-pre-acceptance-history-${reports[index].order}',
              ),
              report: reports[index],
              onOpenFile: onOpenFile,
            ),
            if (index < reports.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class ResearchPreAcceptanceHistoryCard extends StatelessWidget {
  const ResearchPreAcceptanceHistoryCard({
    required this.report,
    this.onOpenFile,
    super.key,
  });

  final ResearchPreAcceptanceReport report;
  final ValueChanged<String>? onOpenFile;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(report.status);
    final reviewerName = report.reviewerName?.trim();
    final comment = report.comment.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Lần nộp ${report.order}',
                style: const TextStyle(
                  color: Color(0xFF292D34),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              _formatDateTime(report.submissionDate),
              style: const TextStyle(color: Color(0xFF858A93), fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _HistoryFileRow(
          label: report.reportFile.fileName,
          fileUrl: report.reportFile.fileUrl,
          onOpenFile: onOpenFile,
        ),
        const SizedBox(height: 8),
        _HistoryFileRow(
          label: report.turnitinReportFile.fileName,
          fileUrl: report.turnitinReportFile.fileUrl,
          onOpenFile: onOpenFile,
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Icon(_statusIcon(report.status), size: 17, color: statusColor),
            const SizedBox(width: 7),
            Text(
              _statusLabel(report.status),
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (reviewerName != null && reviewerName.isNotEmpty) ...[
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 17,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Người duyệt: $reviewerName',
                  style: const TextStyle(
                    color: Color(0xFF555A63),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (report.reviewedAt != null) ...[
          const SizedBox(height: 6),
          Text(
            'Duyệt lúc ${_formatDateTime(report.reviewedAt!)}',
            style: const TextStyle(color: Color(0xFF858A93), fontSize: 11),
          ),
        ],
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              comment,
              style: const TextStyle(
                color: Color(0xFF555A63),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HistoryFileRow extends StatelessWidget {
  const _HistoryFileRow({
    required this.label,
    required this.fileUrl,
    required this.onOpenFile,
  });

  final String label;
  final String? fileUrl;
  final ValueChanged<String>? onOpenFile;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = fileUrl?.trim();
    final canOpen =
        normalizedUrl != null && normalizedUrl.isNotEmpty && onOpenFile != null;

    return Row(
      children: [
        const Icon(
          Icons.description_outlined,
          size: 18,
          color: AppTheme.brandColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF4A4F57), fontSize: 13),
          ),
        ),
        if (canOpen)
          IconButton(
            tooltip: 'Mở tệp',
            visualDensity: VisualDensity.compact,
            onPressed: () => onOpenFile!(normalizedUrl),
            icon: const Icon(Icons.open_in_new, size: 18),
            color: AppTheme.brandColor,
          ),
      ],
    );
  }
}

class ResearchPreAcceptanceEmptyState extends StatelessWidget {
  const ResearchPreAcceptanceEmptyState({
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
    return ResearchPreAcceptanceSurfaceCard(
      key: const ValueKey('research-pre-acceptance-empty'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.brandColor, size: 31),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF292D34),
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

class ResearchPreAcceptanceErrorState extends StatelessWidget {
  const ResearchPreAcceptanceErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ResearchPreAcceptanceSurfaceCard(
      key: const ValueKey('research-pre-acceptance-error'),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.brandColor,
            size: 38,
          ),
          const SizedBox(height: 11),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF555A63),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
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

class ResearchPreAcceptanceSectionHeading extends StatelessWidget {
  const ResearchPreAcceptanceSectionHeading({
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
              color: Color(0xFF24272D),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class ResearchPreAcceptanceSurfaceCard extends StatelessWidget {
  const ResearchPreAcceptanceSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
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

String _formatFileSize(int? bytes) {
  if (bytes == null) return 'Đã chọn tệp';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} • $hour:$minute';
}

Color _statusColor(ResearchPreAcceptanceReportStatus status) {
  return switch (status) {
    ResearchPreAcceptanceReportStatus.approved => const Color(0xFF21835A),
    ResearchPreAcceptanceReportStatus.rejected => AppTheme.brandColor,
    ResearchPreAcceptanceReportStatus.pending => const Color(0xFFC47B10),
  };
}

IconData _statusIcon(ResearchPreAcceptanceReportStatus status) {
  return switch (status) {
    ResearchPreAcceptanceReportStatus.approved => Icons.check_circle_outline,
    ResearchPreAcceptanceReportStatus.rejected => Icons.cancel_outlined,
    ResearchPreAcceptanceReportStatus.pending => Icons.schedule_outlined,
  };
}

String _statusLabel(ResearchPreAcceptanceReportStatus status) {
  return switch (status) {
    ResearchPreAcceptanceReportStatus.approved => 'Đã được duyệt',
    ResearchPreAcceptanceReportStatus.rejected => 'Cần nộp lại',
    ResearchPreAcceptanceReportStatus.pending => 'Đang chờ duyệt',
  };
}

String _statusDescription(ResearchPreAcceptanceReportStatus status) {
  return switch (status) {
    ResearchPreAcceptanceReportStatus.approved =>
      'Báo cáo trước nghiệm thu đã được phê duyệt.',
    ResearchPreAcceptanceReportStatus.rejected =>
      'Xem nhận xét và nộp lại báo cáo đã chỉnh sửa.',
    ResearchPreAcceptanceReportStatus.pending =>
      'Báo cáo đang được người phụ trách xem xét.',
  };
}
