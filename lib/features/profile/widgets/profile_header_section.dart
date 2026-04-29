import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_model.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({required this.profile, super.key});

  final StudentProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final fullName = _textOrFallback(user?.fullName, fallback: 'Chưa cập nhật');
    final studentId = _textOrFallback(profile.studentId, fallback: '---');
    final avatarUrl = user?.avatarUrl?.trim();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 50),
      color: primaryColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Row(
            children: [
              _ProfileAvatar(avatarUrl: avatarUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'MSV: $studentId',
                      style: const TextStyle(
                        color: Color(0xFFFDE7E7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    if (!hasAvatar) {
      return Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_rounded, size: 28, color: Colors.white),
      );
    }

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white.withValues(alpha: 0.16),
              child: const Icon(
                Icons.person_rounded,
                size: 28,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

String _textOrFallback(String? value, {required String fallback}) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? fallback : text;
}
