import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';

class AccountAvatarSection extends StatelessWidget {
  const AccountAvatarSection({
    required this.avatarUrl,
    required this.selectedAvatarPath,
    required this.fullName,
    required this.studentId,
    required this.enabled,
    required this.onAvatarSelected,
    super.key,
  });

  final String? avatarUrl;
  final String? selectedAvatarPath;
  final String fullName;
  final String studentId;
  final bool enabled;
  final ValueChanged<String> onAvatarSelected;

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = result?.files.single.path;

    if (path == null || path.trim().isEmpty) {
      return;
    }

    onAvatarSelected(path);
  }

  @override
  Widget build(BuildContext context) {
    final selectedPath = selectedAvatarPath?.trim();
    final networkUrl = avatarUrl?.trim();
    final displayName = fullName.trim().isEmpty ? 'Sinh viên PTIT' : fullName;
    final displayStudentId = studentId.trim().isEmpty
        ? 'Chưa có mã sinh viên'
        : studentId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD84A4A), AppTheme.brandColor, Color(0xFF941B1B)],
          stops: [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2ABC2626),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 18,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _AvatarImage(
                    selectedPath: selectedPath,
                    networkUrl: networkUrl,
                  ),
                ),
              ),
              if (enabled)
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: const Color(0x40000000),
                    child: InkWell(
                      onTap: _pickAvatar,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: AppTheme.brandColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Text(
              displayStudentId,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (enabled) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: _pickAvatar,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                ),
              ),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text(
                'Thay ảnh đại diện',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (enabled && selectedPath != null && selectedPath.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 15, color: Colors.white),
                SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Ảnh mới sẽ được tải lên khi lưu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFDECEC),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.selectedPath, required this.networkUrl});

  final String? selectedPath;
  final String? networkUrl;

  @override
  Widget build(BuildContext context) {
    if (selectedPath != null && selectedPath!.isNotEmpty) {
      return Image.file(
        File(selectedPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
      );
    }

    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
      );
    }

    return const _AvatarPlaceholder();
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF8EAEA),
      child: Center(
        child: Icon(Icons.person_rounded, size: 56, color: Color(0xFFC97A7A)),
      ),
    );
  }
}
