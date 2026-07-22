import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';

class ProjectPreDefenseContextSection extends StatelessWidget {
  const ProjectPreDefenseContextSection({
    required this.academicYears,
    required this.selectedAcademicYearId,
    required this.isBusy,
    required this.onChanged,
    super.key,
  });

  final List<AcademicYearOption> academicYears;
  final String? selectedAcademicYearId;
  final bool isBusy;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelectedValue = academicYears.any(
      (item) => item.id == selectedAcademicYearId,
    );

    return ProjectPreDefenseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProjectPreDefenseSectionHeading(
            icon: Icons.school_outlined,
            title: 'Thông tin đồ án',
          ),
          const SizedBox(height: 16),
          FormDropdownField<String>(
            label: 'Năm học',
            value: hasSelectedValue ? selectedAcademicYearId : null,
            hintText: 'Chọn năm học',
            enabled: !isBusy && academicYears.isNotEmpty,
            items: academicYears
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(
                      item.name.trim().isNotEmpty ? item.name : item.code,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class ProjectPreDefenseUploadSection extends StatelessWidget {
  const ProjectPreDefenseUploadSection({
    required this.thesisFile,
    required this.turnitinFile,
    required this.enabled,
    required this.isUploading,
    required this.uploadProgress,
    required this.onPickThesis,
    required this.onPickTurnitin,
    required this.onRemoveThesis,
    required this.onRemoveTurnitin,
    required this.onSubmit,
    required this.isResubmission,
    super.key,
  });

  final ProjectPreDefenseUploadFile? thesisFile;
  final ProjectPreDefenseUploadFile? turnitinFile;
  final bool enabled;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onPickThesis;
  final VoidCallback onPickTurnitin;
  final VoidCallback onRemoveThesis;
  final VoidCallback onRemoveTurnitin;
  final VoidCallback onSubmit;
  final bool isResubmission;

  @override
  Widget build(BuildContext context) {
    final hasFile = thesisFile != null || turnitinFile != null;

    return ProjectPreDefenseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProjectPreDefenseSectionHeading(
            icon: isResubmission
                ? Icons.replay_outlined
                : Icons.cloud_upload_outlined,
            title: isResubmission ? 'Nộp lại hồ sơ' : 'Tệp hồ sơ',
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn ít nhất một tệp. Hỗ trợ PDF, DOC, DOCX; tối đa 25 MB mỗi tệp.',
            style: TextStyle(
              color: Color(0xFF747982),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ProjectPreDefenseFilePicker(
            title: 'Quyển đồ án',
            subtitle: 'Bản hoàn chỉnh của quyển đồ án',
            icon: Icons.menu_book_outlined,
            file: thesisFile,
            enabled: enabled && !isUploading,
            onPick: onPickThesis,
            onRemove: onRemoveThesis,
          ),
          const SizedBox(height: 12),
          ProjectPreDefenseFilePicker(
            title: 'Báo cáo Turnitin',
            subtitle: 'Báo cáo kiểm tra độ tương đồng',
            icon: Icons.fact_check_outlined,
            file: turnitinFile,
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
                  '${(uploadProgress * 100).round()}%',
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
              value: uploadProgress > 0 ? uploadProgress : null,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: enabled && hasFile && !isUploading ? onSubmit : null,
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
                    ? 'Đang nộp hồ sơ...'
                    : isResubmission
                    ? 'Nộp lại hồ sơ'
                    : 'Nộp hồ sơ',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectPreDefenseFilePicker extends StatelessWidget {
  const ProjectPreDefenseFilePicker({
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
  final ProjectPreDefenseUploadFile? file;
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

class ProjectPreDefenseStatusSection extends StatelessWidget {
  const ProjectPreDefenseStatusSection({required this.submission, super.key});

  final ProjectPreDefenseSubmission submission;

  @override
  Widget build(BuildContext context) {
    final status = submission.status;
    final color = _statusColor(status);

    return ProjectPreDefenseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProjectPreDefenseSectionHeading(
            icon: Icons.verified_outlined,
            title: 'Trạng thái hồ sơ',
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
                Icon(_statusIcon(status), color: color, size: 25),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          color: color,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _statusDescription(status),
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

class ProjectPreDefenseHistorySection extends StatelessWidget {
  const ProjectPreDefenseHistorySection({required this.attempts, super.key});

  final List<ProjectPreDefenseSubmissionAttempt> attempts;

  @override
  Widget build(BuildContext context) {
    return ProjectPreDefenseSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProjectPreDefenseSectionHeading(
            icon: Icons.history,
            title: 'Lịch sử nộp (${attempts.length})',
          ),
          const SizedBox(height: 14),
          for (var index = attempts.length - 1; index >= 0; index--) ...[
            _SubmissionAttemptTile(
              attempt: attempts[index],
              attemptNumber: index + 1,
            ),
            if (index > 0) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class _SubmissionAttemptTile extends StatelessWidget {
  const _SubmissionAttemptTile({
    required this.attempt,
    required this.attemptNumber,
  });

  final ProjectPreDefenseSubmissionAttempt attempt;
  final int attemptNumber;

  @override
  Widget build(BuildContext context) {
    final approval = attempt.guiderApproval;
    final color = _statusColor(approval.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Lần nộp $attemptNumber',
                style: const TextStyle(
                  color: Color(0xFF292D34),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (attempt.uploadedAt != null)
              Text(
                _formatDateTime(attempt.uploadedAt!),
                style: const TextStyle(color: Color(0xFF858A93), fontSize: 11),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final file in attempt.files) ...[
          Row(
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
                  style: const TextStyle(
                    color: Color(0xFF4A4F57),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Icon(_statusIcon(approval.status), size: 17, color: color),
            const SizedBox(width: 7),
            Text(
              _statusLabel(approval.status),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (approval.comment?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              approval.comment!.trim(),
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

class ProjectPreDefenseEmptyState extends StatelessWidget {
  const ProjectPreDefenseEmptyState({
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
    return ProjectPreDefenseSurfaceCard(
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

class ProjectPreDefenseErrorState extends StatelessWidget {
  const ProjectPreDefenseErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ProjectPreDefenseSurfaceCard(
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

class ProjectPreDefenseSectionHeading extends StatelessWidget {
  const ProjectPreDefenseSectionHeading({
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

class ProjectPreDefenseSurfaceCard extends StatelessWidget {
  const ProjectPreDefenseSurfaceCard({
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

Color _statusColor(ProjectPreDefenseSubmissionStatus? status) {
  return switch (status) {
    ProjectPreDefenseSubmissionStatus.approved => const Color(0xFF21835A),
    ProjectPreDefenseSubmissionStatus.rejected => AppTheme.brandColor,
    ProjectPreDefenseSubmissionStatus.pending => const Color(0xFFC47B10),
    null => const Color(0xFF6B7280),
  };
}

IconData _statusIcon(ProjectPreDefenseSubmissionStatus? status) {
  return switch (status) {
    ProjectPreDefenseSubmissionStatus.approved => Icons.check_circle_outline,
    ProjectPreDefenseSubmissionStatus.rejected => Icons.cancel_outlined,
    ProjectPreDefenseSubmissionStatus.pending => Icons.schedule_outlined,
    null => Icons.help_outline,
  };
}

String _statusLabel(ProjectPreDefenseSubmissionStatus? status) {
  return switch (status) {
    ProjectPreDefenseSubmissionStatus.approved => 'Đã được duyệt',
    ProjectPreDefenseSubmissionStatus.rejected => 'Cần nộp lại',
    ProjectPreDefenseSubmissionStatus.pending => 'Đang chờ duyệt',
    null => 'Chưa xác định',
  };
}

String _statusDescription(ProjectPreDefenseSubmissionStatus? status) {
  return switch (status) {
    ProjectPreDefenseSubmissionStatus.approved =>
      'Hồ sơ đã được giảng viên hướng dẫn phê duyệt.',
    ProjectPreDefenseSubmissionStatus.rejected =>
      'Xem nhận xét của giảng viên và nộp lại hồ sơ đã chỉnh sửa.',
    ProjectPreDefenseSubmissionStatus.pending =>
      'Giảng viên hướng dẫn đang xem xét hồ sơ của bạn.',
    null => 'Chưa có thông tin trạng thái hồ sơ.',
  };
}
