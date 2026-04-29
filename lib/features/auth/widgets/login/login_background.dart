import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/auth/widgets/login/login_styles.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({required this.width, required this.height, super.key});

  final double width;
  final double height;

  double _clamp(num value, num min, num max) {
    return value.clamp(min, max).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [Color(0xFFFFFCF8), Color(0xFFF8F2FF)],
                stops: const [0.08, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          left: -width * 0.42,
          top: -height * 0.13,
          child: _buildAmbientShape(
            size: _clamp(width * 1.16, 420, 620),
            color: LoginStyles.topAmbientColor,
          ),
        ),
        Positioned(
          right: -width * 0.34,
          bottom: -height * 0.20,
          child: _buildAmbientShape(
            size: _clamp(width * 1.28, 500, 760),
            color: LoginStyles.bottomAmbientColor,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.02),
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.22),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmbientShape({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.58),
            color.withValues(alpha: 0.30),
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 0.80, 1.0],
        ),
      ),
    );
  }
}
