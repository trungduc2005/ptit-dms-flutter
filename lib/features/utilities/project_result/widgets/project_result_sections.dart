import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_dropdown_field.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project_result.dart';

class ProjectResultAcademicYearSection extends StatelessWidget {
  const ProjectResultAcademicYearSection({
    super.key,
    required this.academicYears,
    required this.selectedAcademicYearId,
    required this.isLoading,
    required this.onChanged,
  });

  final List<AcademicYearOption> academicYears;
  final String? selectedAcademicYearId;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: FormDropdownField<String>(
        label: 'Năm học',
        value: selectedAcademicYearId,
        hintText: isLoading ? 'Đang tải năm học...' : 'Chọn năm học',
        enabled: !isLoading && academicYears.isNotEmpty,
        accentColor: const Color(0xFFB71C1C),
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
        onChanged: onChanged,
      ),
    );
  }
}

class ProjectResultOverviewSection extends StatelessWidget {
  const ProjectResultOverviewSection({super.key, required this.result});

  final ProjectResult result;

  @override
  Widget build(BuildContext context) {
    final memberWithClosIndex = result.members.indexWhere(
      (member) => member.clos.isNotEmpty,
    );
    final sharedClos = memberWithClosIndex == -1
        ? const <ProjectCloResult>[]
        : result.members[memberWithClosIndex].clos;

    return Column(
      children: [
        ...result.members.indexed.map(
          (entry) => Padding(
            padding: EdgeInsets.only(
              bottom:
                  entry.$1 < result.members.length - 1 || sharedClos.isNotEmpty
                  ? 16
                  : 0,
            ),
            child: ProjectResultMemberCard(member: entry.$2),
          ),
        ),
        if (sharedClos.isNotEmpty) _CloNotes(clos: sharedClos),
      ],
    );
  }
}

class ProjectResultMemberCard extends StatelessWidget {
  const ProjectResultMemberCard({super.key, required this.member});

  final ProjectResultMember member;

  String _formatScore(double score) {
    final fixed = score.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = member.fullName.trim().isEmpty
        ? '?'
        : member.fullName.trim().substring(0, 1).toUpperCase();

    return _SectionCard(
      title: member.fullName.trim().isEmpty ? 'Sinh viên' : member.fullName,
      icon: Icons.person_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFFE8E8),
                backgroundImage:
                    member.avatarUrl == null || member.avatarUrl!.trim().isEmpty
                    ? null
                    : NetworkImage(member.avatarUrl!),
                child:
                    member.avatarUrl == null || member.avatarUrl!.trim().isEmpty
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFFB71C1C),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.studentId,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF343A40),
                      ),
                    ),
                    if (member.className?.trim().isNotEmpty ?? false) ...[
                      const SizedBox(height: 3),
                      Text(
                        member.className!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Điểm chuẩn đầu ra',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF343A40),
            ),
          ),
          const SizedBox(height: 10),
          if (member.clos.isEmpty)
            const Text(
              'Chưa có điểm chuẩn đầu ra.',
              style: TextStyle(color: Color(0xFF6C757D)),
            )
          else
            ...member.clos.indexed.map(
              (entry) => _CloResultRow(
                cloName: entry.$2.cloName,
                scoreText: _formatScore(entry.$2.average),
                showDivider: entry.$1 < member.clos.length - 1,
              ),
            ),
          const Divider(height: 28, color: Color(0xFFE6E8EB)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Điểm tổng kết',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatScore(member.totalGpa),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFB71C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProjectResultEmptyState extends StatelessWidget {
  const ProjectResultEmptyState({
    super.key,
    this.message = 'Kết quả đồ án chưa được công bố.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return _MessageState(
      icon: Icons.hourglass_empty_rounded,
      title: 'Chưa có kết quả',
      message: message,
    );
  }
}

class ProjectResultNoProjectState extends StatelessWidget {
  const ProjectResultNoProjectState({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MessageState(
      icon: Icons.assignment_late_outlined,
      title: 'Chưa có đồ án',
      message: 'Bạn chưa có đồ án trong năm học đã chọn.',
    );
  }
}

class ProjectResultErrorState extends StatelessWidget {
  const ProjectResultErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageState(
      icon: Icons.error_outline_rounded,
      title: 'Không thể tải kết quả',
      message: message,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Thử lại'),
      ),
    );
  }
}

class _CloResultRow extends StatelessWidget {
  const _CloResultRow({
    required this.cloName,
    required this.scoreText,
    required this.showDivider,
  });

  final String cloName;
  final String scoreText;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cloName.trim().isEmpty ? 'CLO' : cloName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF343A40),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                scoreText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB71C1C),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFEEF0F2)),
      ],
    );
  }
}

String formatProjectCloWeightPercentage(double weight) {
  final text = weight.toString();
  final isNegative = text.startsWith('-');
  final unsignedText = isNegative ? text.substring(1) : text;
  final parts = unsignedText.split('.');
  final integerDigits = parts.first;
  final fractionDigits = parts.length > 1 ? parts[1] : '';
  final digits = '$integerDigits$fractionDigits';
  final decimalIndex = integerDigits.length + 2;

  final percentage = decimalIndex >= digits.length
      ? digits.padRight(decimalIndex, '0')
      : '${digits.substring(0, decimalIndex)}.${digits.substring(decimalIndex)}';
  final withoutLeadingZeros = percentage.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  final normalized = withoutLeadingZeros.contains('.')
      ? withoutLeadingZeros
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '')
      : withoutLeadingZeros;

  return '${isNegative ? '-' : ''}${normalized.isEmpty ? '0' : normalized}';
}

class _CloNotes extends StatelessWidget {
  const _CloNotes({required this.clos});

  final List<ProjectCloResult> clos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFF6C757D),
              ),
              const SizedBox(width: 7),
              Text(
                'Chú thích',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF495057),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...clos.indexed.map((entry) {
            final clo = entry.$2;
            final description = clo.cloDescription.trim();
            final weight = formatProjectCloWeightPercentage(clo.cloWeight);

            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.$1 == clos.length - 1 ? 0 : 8,
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${clo.cloName.trim().isEmpty ? 'CLO' : clo.cloName}: ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: description.isEmpty
                          ? 'Trọng số $weight%'
                          : '$description (Trọng số $weight%)',
                    ),
                  ],
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5F6368),
                  height: 1.4,
                ),
              ),
            );
          }),
        ],
      ),
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
    return _SectionCard(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(icon, size: 48, color: const Color(0xFF9AA0A6)),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6C757D), height: 1.4),
              ),
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title, this.icon});

  final String? title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 21, color: const Color(0xFFB71C1C)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212529),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
