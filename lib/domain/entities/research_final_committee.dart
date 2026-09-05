class ResearchFinalOption {
  const ResearchFinalOption({
    required this.researchId,
    required this.researchTopic,
  });

  final String researchId;
  final String researchTopic;

  factory ResearchFinalOption.fromJson(Map<String, dynamic> json) {
    return ResearchFinalOption(
      researchId: _readRequiredString(
        json,
        'researchId',
        label: 'Mã đề tài nghiệm thu',
      ),
      researchTopic: _readRequiredString(
        json,
        'researchTopic',
        label: 'Tên đề tài nghiệm thu',
      ),
    );
  }
}

class ResearchFinalCommitteeMember {
  const ResearchFinalCommitteeMember({
    required this.memberId,
    required this.memberName,
    required this.department,
    required this.role,
    this.avatarUrl,
  });

  final String memberId;
  final String memberName;
  final String department;
  final String role;
  final String? avatarUrl;

  factory ResearchFinalCommitteeMember.fromJson(Map<String, dynamic> json) {
    return ResearchFinalCommitteeMember(
      memberId: _readRequiredString(
        json,
        'memberId',
        label: 'Mã thành viên hội đồng nghiệm thu',
      ),
      memberName: _readRequiredString(
        json,
        'memberName',
        label: 'Tên thành viên hội đồng nghiệm thu',
      ),
      department: _readRequiredString(
        json,
        'department',
        label: 'Đơn vị thành viên hội đồng nghiệm thu',
      ),
      role: _readRequiredString(
        json,
        'role',
        label: 'Vai trò thành viên hội đồng nghiệm thu',
      ),
      avatarUrl: _readNullableString(json, 'avatarUrl'),
    );
  }
}

class ResearchFinalCommitteeResearch {
  const ResearchFinalCommitteeResearch({
    required this.researchId,
    required this.researchTopic,
    required this.presentationOrder,
    this.reviewerName,
  });

  final String researchId;
  final String researchTopic;
  final int presentationOrder;
  final String? reviewerName;

  factory ResearchFinalCommitteeResearch.fromJson(Map<String, dynamic> json) {
    return ResearchFinalCommitteeResearch(
      researchId: _readRequiredString(
        json,
        'researchId',
        label: 'Mã đề tài trong hội đồng nghiệm thu',
      ),
      researchTopic: _readRequiredString(
        json,
        'researchTopic',
        label: 'Tên đề tài trong hội đồng nghiệm thu',
      ),
      presentationOrder: _readInt(json, 'presentationOrder', fallback: -1),
      reviewerName: _readNullableString(json, 'reviewerName'),
    );
  }
}

class ResearchFinalCommittee {
  const ResearchFinalCommittee({
    required this.committeeId,
    required this.name,
    required this.members,
    required this.research,
    this.time,
    this.date,
    this.location,
  });

  final String committeeId;
  final String name;
  final String? time;
  final DateTime? date;
  final String? location;
  final List<ResearchFinalCommitteeMember> members;
  final ResearchFinalCommitteeResearch research;

  factory ResearchFinalCommittee.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    if (rawMembers is! List) {
      throw const FormatException(
        'Danh sách thành viên hội đồng nghiệm thu không đúng định dạng.',
      );
    }

    return ResearchFinalCommittee(
      committeeId: _readRequiredString(
        json,
        'committeeId',
        label: 'Mã hội đồng nghiệm thu',
      ),
      name: _readRequiredString(json, 'name', label: 'Tên hội đồng nghiệm thu'),
      time: _readNullableString(json, 'time'),
      date: _readNullableDate(json, 'date'),
      location: _readNullableString(json, 'location'),
      members: rawMembers
          .map(
            (item) => ResearchFinalCommitteeMember.fromJson(
              _asJsonObject(item, label: 'Thành viên hội đồng nghiệm thu'),
            ),
          )
          .toList(growable: false),
      research: ResearchFinalCommitteeResearch.fromJson(
        _asJsonObject(
          json['research'],
          label: 'Đề tài trong hội đồng nghiệm thu',
        ),
      ),
    );
  }
}

class ResearchFinalCommitteeResult {
  const ResearchFinalCommitteeResult({
    required this.researches,
    required this.committee,
  });

  final List<ResearchFinalOption> researches;
  final ResearchFinalCommittee? committee;

  factory ResearchFinalCommitteeResult.fromJson(Map<String, dynamic> json) {
    final rawResearches = json['researches'];
    if (rawResearches is! List) {
      throw const FormatException(
        'Danh sách đề tài nghiệm thu không đúng định dạng.',
      );
    }

    final rawCommittee = json['committee'];
    return ResearchFinalCommitteeResult(
      researches: rawResearches
          .map(
            (item) => ResearchFinalOption.fromJson(
              _asJsonObject(item, label: 'Đề tài nghiệm thu'),
            ),
          )
          .toList(growable: false),
      committee: rawCommittee == null
          ? null
          : ResearchFinalCommittee.fromJson(
              _asJsonObject(rawCommittee, label: 'Hội đồng nghiệm thu'),
            ),
    );
  }
}

Map<String, dynamic> _asJsonObject(Object? value, {required String label}) {
  if (value is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }

  return Map<String, dynamic>.from(value);
}

String _readRequiredString(
  Map<String, dynamic> json,
  String key, {
  required String label,
}) {
  final value = json[key];
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) {
    throw FormatException('$label không hợp lệ.');
  }

  return text;
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int _readInt(Map<String, dynamic> json, String key, {required int fallback}) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _readNullableDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null || value.toString().trim().isEmpty) {
    return null;
  }

  final date = DateTime.tryParse(value.toString());
  if (date == null) {
    throw const FormatException(
      'Ngày tổ chức hội đồng nghiệm thu không hợp lệ.',
    );
  }

  return date;
}
