import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_styles.dart';

class RequiredProfileActions extends StatelessWidget {
  const RequiredProfileActions({
    required this.isSubmitting,
    required this.onSubmit,
    required this.onLogout,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: LoginStyles.brandColor,
              side: const BorderSide(color: LoginStyles.brandColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: LoginStyles.brandColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: LoginStyles.brandColor.withValues(
                  alpha: 0.72,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Cập nhật',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
