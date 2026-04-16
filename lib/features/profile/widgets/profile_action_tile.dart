import 'package:flutter/material.dart';

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140C0C0D),
                blurRadius: 8,
                offset: Offset(0, 4),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0x140C0C0D),
                blurRadius: 28,
                offset: Offset(0, 14),
                spreadRadius: -16,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF98A2B3),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
