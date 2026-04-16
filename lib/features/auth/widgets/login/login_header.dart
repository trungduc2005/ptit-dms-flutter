import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_styles.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    required this.logoSize,
    required this.titleSize,
    super.key,
  });

  final double logoSize;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/icons/logo.svg',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 18),
        Text(
          'Đăng nhập',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginStyles.titleColor,
            fontSize: titleSize,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 240),
          child: Text(
            'Chào mừng bạn trở lại, vui lòng đăng nhập để tiếp tục',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LoginStyles.subtitleColor,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
