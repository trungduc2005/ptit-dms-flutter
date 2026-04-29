import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utilities_header.dart';

class CompanyDetailPage extends StatelessWidget {
  const CompanyDetailPage({required this.company, super.key});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const UtilitiesHeader(
        title: 'Doanh nghiệp',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _textOrFallback(
                company.companyName,
                fallback: 'Chưa có tên doanh nghiệp',
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 46),
            _CompanyDetailRow(
              label: 'Người đại\ndiện',
              value: _textOrDash(company.representativeName),
            ),
            _CompanyDetailRow(
              label: 'Lĩnh vực',
              value: _textOrDash(company.companyField),
            ),
            _CompanyDetailRow(
              label: 'Số lượng',
              value: company.studentLimit?.toString() ?? '-',
            ),
            _CompanyDetailRow(
              label: 'Cho phép vượt\ngiới hạn',
              value: _formatAllowOverLimit(company.allowOverLimit),
            ),
            _CompanyDetailRow(
              label: 'Địa chỉ',
              value: _textOrDash(company.companyAddress),
            ),
          ],
        ),
      ),
    );
  }

  static String _textOrDash(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return '-';
    return text;
  }

  static String _textOrFallback(String? value, {required String fallback}) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  static String _formatAllowOverLimit(bool? value) {
    if (value == null) return '-';
    return value ? 'Có' : 'Không';
  }
}

class _CompanyDetailRow extends StatelessWidget {
  const _CompanyDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: _textStyle)),
          const SizedBox(width: 32),
          Expanded(child: Text(value, style: _textStyle)),
        ],
      ),
    );
  }

  static const TextStyle _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );
}
