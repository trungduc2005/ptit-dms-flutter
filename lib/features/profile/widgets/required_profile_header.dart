import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_styles.dart';

class RequiredProfileHeader extends StatelessWidget {
  const RequiredProfileHeader({
    required this.mustChangePassword,
    super.key,
  });

  final bool mustChangePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Cập nhật thông tin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          mustChangePassword
              ? 'Hãy đổi mật khẩu và cập nhật đầy đủ các thông tin dưới đây để tiếp tục sử dụng'
              : 'Hãy cập nhật đầy đủ các thông tin dưới đây để tiếp tục sử dụng',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: LoginStyles.subtitleColor,
            fontSize: 15,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
