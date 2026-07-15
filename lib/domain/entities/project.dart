class ProjectMember {
  final String studentRef;
  final String studentId;
  final String studentName;
  final String role; // 'Leader' | 'Member'
  final String approvalStatus; // 'pending' | 'approved'
  final String? approvalSource; // 'student' | 'leader' | 'system'
  final DateTime? respondedAt;
  final String? avatarUrl;
  final String? classId;
  final String? cohort;

  const ProjectMember({
    required this.studentRef,
    required this.studentId,
    required this.studentName,
    required this.role,
    required this.approvalStatus,
    this.approvalSource,
    this.respondedAt,
    this.avatarUrl,
    this.classId,
    this.cohort,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      studentRef: json['studentRef'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      role: json['role'] as String? ?? 'Member',
      approvalStatus: json['approvalStatus'] as String? ?? 'approved',
      approvalSource: json['approvalSource'] as String?,
      respondedAt: json['respondedAt'] != null
          ? DateTime.tryParse(json['respondedAt'].toString())
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      classId: json['classId'] as String?,
      cohort: json['cohort'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentRef': studentRef,
      'studentId': studentId,
      'studentName': studentName,
      'role': role,
      'approvalStatus': approvalStatus,
      if (approvalSource != null) 'approvalSource': approvalSource,
      if (respondedAt != null) 'respondedAt': respondedAt!.toIso8601String(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (classId != null) 'classId': classId,
      if (cohort != null) 'cohort': cohort,
    };
  }

  bool get isPending => approvalStatus == 'pending';
  bool get isApproved => approvalStatus == 'approved';
  bool get isLeader => role == 'Leader';
}

class ProjectGuider {
  final String? lecturerRef;
  final String? lecturerId;
  final String? lecturerName;
  final String? email;
  final String? avatarUrl;

  const ProjectGuider({
    this.lecturerRef,
    this.lecturerId,
    this.lecturerName,
    this.email,
    this.avatarUrl,
  });

  factory ProjectGuider.fromJson(Map<String, dynamic> json) {
    return ProjectGuider(
      lecturerRef: json['lecturerRef'] as String?,
      lecturerId: json['lecturerId'] as String?,
      lecturerName: json['lecturerName'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lecturerRef != null) 'lecturerRef': lecturerRef,
      if (lecturerId != null) 'lecturerId': lecturerId,
      if (lecturerName != null) 'lecturerName': lecturerName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

class ProjectMemberApprovalHistory {
  final String? studentRef;
  final String? studentId;
  final String? studentName;
  final String action;
  final String? actorName;
  final String? actorRole;
  final String? reason;
  final DateTime createdAt;

  const ProjectMemberApprovalHistory({
    this.studentRef,
    this.studentId,
    this.studentName,
    required this.action,
    this.actorName,
    this.actorRole,
    this.reason,
    required this.createdAt,
  });

  factory ProjectMemberApprovalHistory.fromJson(Map<String, dynamic> json) {
    return ProjectMemberApprovalHistory(
      studentRef: json['studentRef'] as String?,
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String?,
      action: json['action'] as String? ?? '',
      actorName: json['actorName'] as String?,
      actorRole: json['actorRole'] as String?,
      reason: json['reason'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class Project {
  final String id;
  final String projectId;
  final String projectName;
  final String field;
  final String period;
  final String keyword;
  final String description;
  final String outcome;
  final String
  status; // pending | approved | rejected | hasIssue | project_needs_revision
  final String
  guiderReceptionStatus; // processing | assigned | approved | rejected
  final String
  memberApprovalStatus; // waiting_members | completed | needs_revision
  final DateTime? memberApprovalDeadline;
  final bool isNameConflict;
  final String academicYearRef;
  final String? cohort;
  final ProjectGuider? guider;
  final List<ProjectMember> members;
  final List<ProjectMemberApprovalHistory> memberApprovalHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.field,
    required this.period,
    required this.keyword,
    required this.description,
    required this.outcome,
    required this.status,
    required this.guiderReceptionStatus,
    required this.memberApprovalStatus,
    this.memberApprovalDeadline,
    this.isNameConflict = false,
    required this.academicYearRef,
    this.cohort,
    this.guider,
    required this.members,
    required this.memberApprovalHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      field: json['field'] as String? ?? '',
      period: json['period'] as String? ?? '',
      keyword: json['keyword'] as String? ?? '',
      description: json['description'] as String? ?? '',
      outcome: json['outcome'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      guiderReceptionStatus:
          json['guiderReceptionStatus'] as String? ?? 'processing',
      memberApprovalStatus:
          json['memberApprovalStatus'] as String? ?? 'waiting_members',
      memberApprovalDeadline: json['memberApprovalDeadline'] != null
          ? DateTime.tryParse(json['memberApprovalDeadline'].toString())
          : null,
      isNameConflict: json['isNameConflict'] as bool? ?? false,
      academicYearRef: json['academicYearRef'] as String? ?? '',
      cohort: json['cohort'] as String?,
      guider: json['guider'] != null
          ? ProjectGuider.fromJson(json['guider'] as Map<String, dynamic>)
          : null,
      members: (json['members'] as List<dynamic>? ?? [])
          .map((m) => ProjectMember.fromJson(m as Map<String, dynamic>))
          .toList(),
      memberApprovalHistory:
          (json['memberApprovalHistory'] as List<dynamic>? ?? [])
              .map(
                (h) => ProjectMemberApprovalHistory.fromJson(
                  h as Map<String, dynamic>,
                ),
              )
              .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// True if status allows editing by student
  bool get isEditable => status == 'project_needs_revision';

  /// True if all members have confirmed
  bool get isFullyApproved => memberApprovalStatus == 'completed';

  /// True if waiting for at least one member to respond
  bool get isWaitingMembers => memberApprovalStatus == 'waiting_members';

  ProjectMember? get leader => members.where((m) => m.isLeader).firstOrNull;
}
