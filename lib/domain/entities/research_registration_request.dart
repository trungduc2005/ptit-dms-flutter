class ResearchRegistrationMemberRequest {
  const ResearchRegistrationMemberRequest({required this.memberId});

  final String memberId;

  Map<String, dynamic> toJson() => {'memberId': memberId};
}

/// Body gửi cho POST /api/researches và PUT /api/researches/:researchId.
///
/// [members] không bao gồm người đăng ký. Backend tự thêm người đăng ký với
/// vai trò Leader.
class ResearchRegistrationRequest {
  const ResearchRegistrationRequest({
    required this.yearId,
    required this.type,
    required this.researchTopic,
    required this.keyword,
    required this.outcome,
    required this.description,
    required this.researchNecessity,
    required this.nationalOverview,
    required this.internationalOverview,
    this.level,
    this.guiderId,
    this.members = const [],
  });

  final String yearId;
  final String type;
  final String? level;
  final String researchTopic;
  final String keyword;
  final String outcome;
  final String description;
  final String researchNecessity;
  final String nationalOverview;
  final String internationalOverview;
  final String? guiderId;
  final List<ResearchRegistrationMemberRequest> members;

  Map<String, dynamic> toJson() {
    return {
      'yearId': yearId,
      'type': type,
      if (level != null && level!.trim().isNotEmpty) 'level': level,
      'researchTopic': researchTopic,
      'keyword': keyword,
      'outcome': outcome,
      'description': description,
      'researchNecessity': researchNecessity,
      'nationalOverview': nationalOverview,
      'internationalOverview': internationalOverview,
      if (guiderId != null && guiderId!.trim().isNotEmpty) 'guiderId': guiderId,
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}
