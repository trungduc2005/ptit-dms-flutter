bool isLecturerRole(String? role) {
  final normalized = role?.trim().toLowerCase();
  return normalized == 'lecturer' || normalized == 'lecture';
}
