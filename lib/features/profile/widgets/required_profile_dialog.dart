import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/required_profile_form.dart';

class RequiredProfileDialog extends StatelessWidget {
  const RequiredProfileDialog({super.key});

  double _clamp(num value, num min, num max) {
    return value.clamp(min, max).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final dialogHeight = _clamp(media.size.height * 0.78, 520, 680);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: 360,
          height: dialogHeight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EAF0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const RequiredProfileForm(),
          ),
        ),
      ),
    );
  }
}
