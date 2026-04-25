import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';

class CompanyListCard extends StatelessWidget {
  const CompanyListCard({
    required this.company,
    this.onTap,
    super.key,
  });

  final CompanyModel company;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 90),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.companyName.isEmpty
                        ? 'Chưa có tên doanh nghiệp'
                        : company.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CPA: ${_formatCpa(company.minCpa)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _metaStyle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Số lượng: ${company.studentLimit ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _metaStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const TextStyle _metaStyle = TextStyle(
    color: Color(0xFF6C7278),
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  String _formatCpa(double? value) {
    if (value == null) return '-';

    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
