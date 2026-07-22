import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';

class CompanyListCard extends StatelessWidget {
  const CompanyListCard({required this.company, this.onTap, super.key});

  final Company company;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final companyField = company.companyField?.trim();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE7EAF0)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.companyName.trim().isEmpty
                              ? 'Chưa có tên doanh nghiệp'
                              : company.companyName.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF151A2D),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        if (companyField != null &&
                            companyField.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            companyField,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF98A0B2),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFEEF0F4)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CompanyMetaChip(
                    icon: Icons.school_outlined,
                    label: 'CPA tối thiểu',
                    value: _formatCpa(company.minCpa),
                  ),
                  _CompanyMetaChip(
                    icon: Icons.groups_2_outlined,
                    label: 'Chỉ tiêu',
                    value: company.studentLimit?.toString() ?? '-',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCpa(double? value) {
    if (value == null) return '-';

    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _CompanyMetaChip extends StatelessWidget {
  const _CompanyMetaChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.brandColor, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF151A2D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
