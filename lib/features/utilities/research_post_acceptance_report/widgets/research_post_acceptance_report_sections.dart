import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';

class ResearchPostAcceptanceContextSection extends StatelessWidget {
  const ResearchPostAcceptanceContextSection({
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

    return ResearchPostAcceptanceSurfaceCard(
      key: const ValueKey('research-post-acceptance-context'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ResearchPostAcceptanceSectionHeading(
            icon: Icons.tune_outlined,
            title: 'Thông tin báo cáo',
          ),
          const SizedBox(height: 16),
          FormDropdownField<String>(
            key: const ValueKey('research-post-acceptance-year-dropdown'),
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
            key: const ValueKey('research-post-acceptance-research-dropdown'),
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

class ResearchPostAcceptanceUploadSection extends StatelessWidget {
  const ResearchPostAcceptanceUploadSection({
    required this.files,
    required this.enabled,
    required this.isUploading,
    required this.uploadProgress,
    required this.isResubmission,
    required this.onPick,
    required this.onRemove,
    required this.onSubmit,
    super.key,
  });

  final Map<ResearchPostAcceptanceFileType, ResearchPostAcceptanceUploadFile?>
  files;
  final bool enabled;
  final bool isUploading;
  final double uploadProgress;
  final bool isResubmission;
  final ValueChanged<ResearchPostAcceptanceFileType> onPick;
  final ValueChanged<ResearchPostAcceptanceFileType> onRemove;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hasRequiredFiles = ResearchPostAcceptanceFileType.values
        .where((type) => type != ResearchPostAcceptanceFileType.paper)
        .every((type) => files[type] != null);

    return ResearchPostAcceptanceSurfaceCard(
      key: const ValueKey('research-post-acceptance-upload-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResearchPostAcceptanceSectionHeading(
            icon: isResubmission
                ? Icons.replay_outlined
                : Icons.cloud_upload_outlined,
            title: isResubmission ? 'Nộp lại báo cáo' : 'Tệp báo cáo',
          ),
          const SizedBox(height: 8),
          const Text(
            'Cần chọn đầy đủ 6 tệp. Hỗ trợ PDF, DOC, DOCX; tối đa 10 MB mỗi tệp.',
            style: TextStyle(
              color: Color(0xFF747982),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          for (final type in ResearchPostAcceptanceFileType.values)
            if (type != ResearchPostAcceptanceFileType.paper) ...[
              ResearchPostAcceptanceFilePicker(
                key: ValueKey('research-post-acceptance-${type.name}-file'),
                title: type.title,
                subtitle: type.subtitle,
                icon: type.icon,
                file: files[type],
                enabled: enabled && !isUploading,
                onPick: () => onPick(type),
                onRemove: () => onRemove(type),
              ),
              if (type != ResearchPostAcceptanceFileType.acceptanceDecision)
                const SizedBox(height: 12),
            ],
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
                    'research-post-acceptance-upload-progress',
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
              key: const ValueKey('research-post-acceptance-submit'),
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

enum ResearchPostAcceptanceFileType {
  report,
  acceptanceMinutes,
  acceptanceCommitteeList,
  proposal,
  revisionExplanation,
  acceptanceDecision,
  paper;

  String get title => switch (this) {
    report => 'Báo cáo tổng kết',
    acceptanceMinutes => 'Biên bản nghiệm thu',
    acceptanceCommitteeList => 'Danh sách hội đồng nghiệm thu',
    proposal => 'Đề cương nghiên cứu',
    revisionExplanation => 'Giải trình chỉnh sửa',
    acceptanceDecision => 'Quyết định nghiệm thu',
    paper => 'Bài báo khoa học',
  };

  String get subtitle => switch (this) {
    report => 'Bản báo cáo hoàn chỉnh sau nghiệm thu',
    acceptanceMinutes => 'Biên bản của buổi nghiệm thu',
    acceptanceCommitteeList => 'Danh sách thành viên hội đồng nghiệm thu',
    proposal => 'Đề cương nghiên cứu đã được phê duyệt',
    revisionExplanation => 'Bản giải trình các nội dung đã chỉnh sửa',
    acceptanceDecision => 'Quyết định công nhận kết quả nghiệm thu',
    paper => 'Bài báo hoặc công bố khoa học liên quan',
  };

  IconData get icon => switch (this) {
    report => Icons.description_outlined,
    acceptanceMinutes => Icons.fact_check_outlined,
    acceptanceCommitteeList => Icons.groups_outlined,
    proposal => Icons.menu_book_outlined,
    revisionExplanation => Icons.rate_review_outlined,
    acceptanceDecision => Icons.gavel_outlined,
    paper => Icons.article_outlined,
  };
}

class ResearchPostAcceptanceFilePicker extends StatelessWidget {
  const ResearchPostAcceptanceFilePicker({
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
  final ResearchPostAcceptanceUploadFile? file;
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

class ResearchPostAcceptanceStatusSection extends StatelessWidget {
  const ResearchPostAcceptanceStatusSection({required this.report, super.key});

  final ResearchPostAcceptanceReport report;

  @override
  Widget build(BuildContext context) {
    return ResearchPostAcceptanceSurfaceCard(
      key: const ValueKey('research-post-acceptance-status'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ResearchPostAcceptanceSectionHeading(
            icon: Icons.verified_outlined,
            title: 'Trạng thái hiện tại',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FB),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFB9D8ED)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.cloud_done_outlined,
                  color: Color(0xFF2878A7),
                  size: 25,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã nộp',
                        style: TextStyle(
                          color: Color(0xFF2878A7),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Hồ sơ báo cáo sau nghiệm thu đã được ghi nhận.',
                        style: TextStyle(
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

class ResearchPostAcceptanceHistorySection extends StatelessWidget {
  const ResearchPostAcceptanceHistorySection({
    required this.reports,
    required this.downloadingFileKey,
    required this.onDownloadFile,
    super.key,
  });

  final List<ResearchPostAcceptanceReport> reports;
  final String? downloadingFileKey;
  final ValueChanged<ResearchPostAcceptanceReportFile> onDownloadFile;

  @override
  Widget build(BuildContext context) {
    return ResearchPostAcceptanceSurfaceCard(
      key: const ValueKey('research-post-acceptance-history'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResearchPostAcceptanceSectionHeading(
            icon: Icons.history,
            title: 'Lịch sử nộp (${reports.length})',
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < reports.length; index++) ...[
            _HistoryCard(
              report: reports[index],
              downloadingFileKey: downloadingFileKey,
              onDownloadFile: onDownloadFile,
            ),
            if (index < reports.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.report,
    required this.downloadingFileKey,
    required this.onDownloadFile,
  });

  final ResearchPostAcceptanceReport report;
  final String? downloadingFileKey;
  final ValueChanged<ResearchPostAcceptanceReportFile> onDownloadFile;

  @override
  Widget build(BuildContext context) {
    final files = <ResearchPostAcceptanceReportFile>[
      report.reportFile,
      report.acceptanceMinutesFile,
      report.acceptanceCommitteeListFile,
      report.proposalFile,
      report.revisionExplanationFile,
      report.acceptanceDecisionFile,
      if (report.paperFile != null) report.paperFile!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
        for (final file in files)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _HistoryFileRow(
              file: file,
              isDownloading: downloadingFileKey == file.fileKey,
              onDownload: () => onDownloadFile(file),
            ),
          ),
      ],
    );
  }
}

class _HistoryFileRow extends StatelessWidget {
  const _HistoryFileRow({
    required this.file,
    required this.isDownloading,
    required this.onDownload,
  });

  final ResearchPostAcceptanceReportFile file;
  final bool isDownloading;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
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
            file.fileName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF4A4F57), fontSize: 13),
          ),
        ),
        IconButton(
          tooltip: 'Tải tệp',
          visualDensity: VisualDensity.compact,
          onPressed: isDownloading ? null : onDownload,
          icon: isDownloading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined, size: 19),
          color: AppTheme.brandColor,
        ),
      ],
    );
  }
}

class ResearchPostAcceptanceEmptyState extends StatelessWidget {
  const ResearchPostAcceptanceEmptyState({
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
    return ResearchPostAcceptanceSurfaceCard(
      key: const ValueKey('research-post-acceptance-empty'),
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

class ResearchPostAcceptanceErrorState extends StatelessWidget {
  const ResearchPostAcceptanceErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ResearchPostAcceptanceSurfaceCard(
      key: const ValueKey('research-post-acceptance-error'),
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

class ResearchPostAcceptanceSectionHeading extends StatelessWidget {
  const ResearchPostAcceptanceSectionHeading({
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

class ResearchPostAcceptanceSurfaceCard extends StatelessWidget {
  const ResearchPostAcceptanceSurfaceCard({
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
