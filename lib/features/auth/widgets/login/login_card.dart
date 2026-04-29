import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_form.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_header.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    required this.screenWidth,
    required this.isLoading,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    super.key,
  });

  final double screenWidth;
  final bool isLoading;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  double _clamp(num value, num min, num max) {
    return value.clamp(min, max).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final cardPadding = _clamp(screenWidth * 0.07, 24, 32);
    final logoSize = _clamp(screenWidth * 0.22, 84, 108);
    final titleSize = _clamp(screenWidth * 0.086, 28, 34);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            cardPadding,
            cardPadding + 6,
            cardPadding,
            cardPadding,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.90),
                const Color(0xFFF7F3FF).withValues(alpha: 0.84),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginHeader(logoSize: logoSize, titleSize: titleSize),
              const SizedBox(height: 30),
              LoginForm(
                usernameController: usernameController,
                passwordController: passwordController,
                obscurePassword: obscurePassword,
                isLoading: isLoading,
                onTogglePassword: onTogglePassword,
                onSubmit: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
