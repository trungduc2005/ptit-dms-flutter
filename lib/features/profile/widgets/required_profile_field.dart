import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_styles.dart';

class RequiredProfileField extends StatelessWidget {
  const RequiredProfileField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LoginStyles.subtitleColor,
            fontSize: 13,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color(0x1AE4E5E7),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            enabled: enabled,
            cursorColor: LoginStyles.brandColor,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              color: Color(0xFF1A1C1E),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF99A1AA),
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.96),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: suffixIcon,
              border: _border(LoginStyles.inputBorderColor),
              enabledBorder: _border(LoginStyles.inputBorderColor),
              focusedBorder: _border(LoginStyles.brandColor),
              disabledBorder: _border(LoginStyles.inputBorderColor),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.1),
    );
  }
}
