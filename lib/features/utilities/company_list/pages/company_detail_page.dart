import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';

class CompanyDetailPage extends StatelessWidget {
  const CompanyDetailPage({required this.company, super.key});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const AppHeader(
        title: 'Chi tiết doanh nghiệp',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            _CompanyOverviewCard(company: company),
            const SizedBox(height: 16),
            _CompanyDetailSection(
              title: 'Thông tin tuyển dụng',
              icon: Icons.work_outline_rounded,
              children: [
                _CompanyDetailItem(
                  icon: Icons.groups_2_outlined,
                  label: 'Chỉ tiêu sinh viên',
                  value: company.studentLimit?.toString() ?? '-',
                ),
                _CompanyDetailItem(
                  icon: Icons.school_outlined,
                  label: 'CPA tối thiểu',
                  value: _formatCpa(company.minCpa),
                ),
                _CompanyDetailItem(
                  icon: Icons.group_add_outlined,
                  label: 'Cho phép vượt chỉ tiêu',
                  value: _formatAllowOverLimit(company.allowOverLimit),
                ),
                _CompanyDetailItem(
                  icon: Icons.location_on_outlined,
                  label: 'Địa điểm thực tập',
                  value: _textOrDash(company.internshipLocation),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CompanyDetailSection(
              title: 'Thông tin liên hệ',
              icon: Icons.contact_phone_outlined,
              children: [
                _CompanyDetailItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Người đại diện',
                  value: _textOrDash(company.representativeName),
                ),
                _CompanyDetailItem(
                  icon: Icons.badge_outlined,
                  label: 'Chức vụ',
                  value: _textOrDash(company.representativeJob),
                ),
                _CompanyDetailItem(
                  icon: Icons.phone_outlined,
                  label: 'Số điện thoại',
                  value: _textOrDash(company.representativePhoneNumber),
                ),
                _CompanyDetailItem(
                  icon: Icons.link_rounded,
                  label: 'Kênh liên hệ',
                  value: _textOrDash(company.contactLink),
                ),
                _CompanyDetailItem(
                  icon: Icons.location_city_outlined,
                  label: 'Địa chỉ doanh nghiệp',
                  value: _textOrDash(company.companyAddress),
                  isLast: true,
                ),
              ],
            ),
            if (_hasAdditionalInformation(company)) ...[
              const SizedBox(height: 16),
              _CompanyDetailSection(
                title: 'Thông tin thực tập',
                icon: Icons.description_outlined,
                children: [
                  if (_hasText(company.jobDescription))
                    _CompanyDescriptionItem(
                      label: 'Mô tả công việc',
                      value: company.jobDescription!.trim(),
                    ),
                  if (_hasText(company.qualityRequirements))
                    _CompanyDescriptionItem(
                      label: 'Yêu cầu ứng viên',
                      value: company.qualityRequirements!.trim(),
                    ),
                  if (_hasText(company.benefits))
                    _CompanyDescriptionItem(
                      label: 'Quyền lợi',
                      value: company.benefits!.trim(),
                      isLast: true,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static bool _hasAdditionalInformation(Company company) {
    return _hasText(company.jobDescription) ||
        _hasText(company.qualityRequirements) ||
        _hasText(company.benefits);
  }

  static bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;

  static String _textOrDash(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return '-';
    return text;
  }

  static String _formatAllowOverLimit(bool? value) {
    if (value == null) return '-';
    return value ? 'Có' : 'Không';
  }

  static String _formatCpa(double? value) {
    if (value == null) return '-';
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _CompanyOverviewCard extends StatelessWidget {
  const _CompanyOverviewCard({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final companyName = company.companyName.trim();
    final companyField = company.companyField?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.brandColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            companyName.isEmpty ? 'Chưa có tên doanh nghiệp' : companyName,
            style: const TextStyle(
              color: Color(0xFF151A2D),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            companyField == null || companyField.isEmpty
                ? 'Chưa cập nhật lĩnh vực hoạt động'
                : companyField,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyDetailSection extends StatelessWidget {
  const _CompanyDetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.brandColor, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF151A2D),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEF0F4)),
          ...children,
        ],
      ),
    );
  }
}

class _CompanyDetailItem extends StatelessWidget {
  const _CompanyDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF0F1F4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, color: const Color(0xFF7D8597), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF151A2D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyDescriptionItem extends StatelessWidget {
  const _CompanyDescriptionItem({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF0F1F4))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF151A2D),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _htmlToPlainText(value),
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  static String _htmlToPlainText(String value) {
    return value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li(?:\s[^>]*)?>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('\u0026nbsp;', ' ')
        .replaceAll('\u0026amp;', '\u0026')
        .replaceAll('\u0026lt;', '<')
        .replaceAll('\u0026gt;', '>')
        .replaceAll('\u0026quot;', '"')
        .replaceAll('\u0026#39;', "'")
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
