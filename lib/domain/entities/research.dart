class ResearchMember {
  const ResearchMember({
    required this.userId,
    required this.memberId,
    required this.memberName,
    required this.role,
    this.avatarUrl,
  });

  final String userId;
  final String memberId;
  final String memberName;
  final String role;
  final String? avatarUrl;

  factory ResearchMember.fromJson(Map<String, dynamic> json) {
    return ResearchMember(
      userId: json['userId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Member',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  bool get isLeader => role == 'Leader';
}

class ResearchGuider {
  const ResearchGuider({this.lecturerRef, this.lecturerId, this.lecturerName});

  final String? lecturerRef;
  final String? lecturerId;
  final String? lecturerName;

  factory ResearchGuider.fromJson(Map<String, dynamic> json) {
    return ResearchGuider(
      lecturerRef: json['lecturerRef']?.toString(),
      lecturerId: json['lecturerId']?.toString(),
      lecturerName: json['lecturerName']?.toString(),
    );
  }
}

class ResearchCommitteeSummary {
  const ResearchCommitteeSummary({
    this.committeeRef,
    this.committeeId,
    this.committeeName,
  });

  final String? committeeRef;
  final String? committeeId;
  final String? committeeName;

  factory ResearchCommitteeSummary.fromJson(Map<String, dynamic> json) {
    return ResearchCommitteeSummary(
      committeeRef: json['committeeRef']?.toString(),
      committeeId: json['committeeId']?.toString(),
      committeeName: json['committeeName']?.toString(),
    );
  }
}

class ResearchReviewer {
  const ResearchReviewer({
    this.lecturerRef,
    this.reviewerId,
    this.reviewerName,
  });

  final String? lecturerRef;
  final String? reviewerId;
  final String? reviewerName;

  factory ResearchReviewer.fromJson(Map<String, dynamic> json) {
    return ResearchReviewer(
      lecturerRef: json['lecturerRef']?.toString(),
      reviewerId: json['reviewerId']?.toString(),
      reviewerName: json['reviewerName']?.toString(),
    );
  }
}

class ResearchComment {
  const ResearchComment({
    required this.content,
    this.commentedBy,
    this.commentedAt,
  });

  final String content;
  final String? commentedBy;
  final DateTime? commentedAt;

  factory ResearchComment.fromJson(Map<String, dynamic> json) {
    return ResearchComment(
      content: json['content']?.toString() ?? '',
      commentedBy: json['commentedBy']?.toString(),
      commentedAt: DateTime.tryParse(json['commentedAt']?.toString() ?? ''),
    );
  }
}

class Research {
  const Research({
    required this.id,
    required this.userId,
    required this.researchId,
    required this.type,
    required this.researchTopic,
    required this.keyword,
    required this.outcome,
    required this.description,
    required this.researchNecessity,
    required this.nationalOverview,
    required this.internationalOverview,
    required this.yearId,
    required this.approvalStatus,
    required this.members,
    required this.comments,
    this.level,
    this.yearCode,
    this.yearName,
    this.guider,
    this.approvalCommittee,
    this.presentationCommittee,
    this.finalCommittee,
    this.reviewer,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String researchId;
  final String type;
  final String? level;
  final String researchTopic;
  final String keyword;
  final String outcome;
  final String description;
  final String researchNecessity;
  final String nationalOverview;
  final String internationalOverview;
  final String yearId;
  final String? yearCode;
  final String? yearName;
  final String approvalStatus;
  final List<ResearchMember> members;
  final ResearchGuider? guider;
  final ResearchCommitteeSummary? approvalCommittee;
  final ResearchCommitteeSummary? presentationCommittee;
  final ResearchCommitteeSummary? finalCommittee;
  final ResearchReviewer? reviewer;
  final List<ResearchComment> comments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Research.fromJson(Map<String, dynamic> json) {
    final year = _asMap(json['yearRef']);
    final guider = _asMap(json['guider']);
    final approvalCommittee = _asMap(json['approvalCommittee']);
    final presentationCommittee = _asMap(json['presentationCommittee']);
    final finalCommittee = _asMap(json['finalCommittee']);
    final reviewer = _asMap(json['reviewer']);

    return Research(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      researchId: json['researchId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      level: json['level']?.toString(),
      researchTopic: json['researchTopic']?.toString() ?? '',
      keyword: json['keyword']?.toString() ?? '',
      outcome: json['outcome']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      researchNecessity: json['researchNecessity']?.toString() ?? '',
      nationalOverview: json['nationalOverview']?.toString() ?? '',
      internationalOverview: json['internationalOverview']?.toString() ?? '',
      yearId: year?['_id']?.toString() ?? json['yearRef']?.toString() ?? '',
      yearCode: year?['code']?.toString(),
      yearName: year?['name']?.toString(),
      approvalStatus: json['approvalStatus']?.toString() ?? 'pending',
      members: _asMapList(
        json['members'],
      ).map(ResearchMember.fromJson).toList(growable: false),
      guider: guider == null ? null : ResearchGuider.fromJson(guider),
      approvalCommittee: approvalCommittee == null
          ? null
          : ResearchCommitteeSummary.fromJson(approvalCommittee),
      presentationCommittee: presentationCommittee == null
          ? null
          : ResearchCommitteeSummary.fromJson(presentationCommittee),
      finalCommittee: finalCommittee == null
          ? null
          : ResearchCommitteeSummary.fromJson(finalCommittee),
      reviewer: reviewer == null ? null : ResearchReviewer.fromJson(reviewer),
      comments: _asMapList(
        json['comments'],
      ).map(ResearchComment.fromJson).toList(growable: false),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  bool get isEditable => approvalStatus != 'approved';

  ResearchMember? get leader {
    for (final member in members) {
      if (member.isLeader) return member;
    }
    return null;
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
