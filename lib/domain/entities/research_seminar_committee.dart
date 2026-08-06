class ResearchSeminarOption {
  const ResearchSeminarOption({
    required this.researchId,
    required this.researchTopic,
  });

  final String researchId;
  final String researchTopic;

  factory ResearchSeminarOption.fromJson(Map<String, dynamic> json) {
    return ResearchSeminarOption(
      researchId: _readRequiredString(
        json,
        'researchId',
        label: 'Mã đề tài hội thảo',
      ),
      researchTopic: _readRequiredString(
        json,
        'researchTopic',
        label: 'Tên đề tài hội thảo',
      ),
    );
  }
}

class ResearchSeminarCommitteeMember {
  const ResearchSeminarCommitteeMember({
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

  factory ResearchSeminarCommitteeMember.fromJson(Map<String, dynamic> json) {
    return ResearchSeminarCommitteeMember(
      memberId: _readRequiredString(
        json,
        'memberId',
        label: 'Mã thành viên hội đồng',
      ),
      memberName: _readRequiredString(
        json,
        'memberName',
        label: 'Tên thành viên hội đồng',
      ),
      department: _readRequiredString(
        json,
        'department',
        label: 'Đơn vị thành viên hội đồng',
      ),
      role: _readRequiredString(
        json,
        'role',
        label: 'Vai trò thành viên hội đồng',
      ),
      avatarUrl: _readNullableString(json, 'avatarUrl'),
    );
  }
}

class ResearchSeminarCommitteeResearch {
  const ResearchSeminarCommitteeResearch({
    required this.researchId,
    required this.researchTopic,
    required this.presentationOrder,
    this.reviewerName,
  });

  final String researchId;
  final String researchTopic;
  final int presentationOrder;
  final String? reviewerName;

  factory ResearchSeminarCommitteeResearch.fromJson(Map<String, dynamic> json) {
    return ResearchSeminarCommitteeResearch(
      researchId: _readRequiredString(
        json,
        'researchId',
        label: 'Mã đề tài trong hội đồng',
      ),
      researchTopic: _readRequiredString(
        json,
        'researchTopic',
        label: 'Tên đề tài trong hội đồng',
      ),
      presentationOrder: _readInt(json, 'presentationOrder', fallback: -1),
      reviewerName: _readNullableString(json, 'reviewerName'),
    );
  }
}

class ResearchSeminarCommittee {
  const ResearchSeminarCommittee({
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
  final List<ResearchSeminarCommitteeMember> members;
  final ResearchSeminarCommitteeResearch research;

  factory ResearchSeminarCommittee.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    if (rawMembers is! List) {
      throw const FormatException(
        'Danh sách thành viên hội đồng hội thảo không đúng định dạng.',
      );
    }

    return ResearchSeminarCommittee(
      committeeId: _readRequiredString(
        json,
        'committeeId',
        label: 'Mã hội đồng hội thảo',
      ),
      name: _readRequiredString(json, 'name', label: 'Tên hội đồng hội thảo'),
      time: _readNullableString(json, 'time'),
      date: _readNullableDate(json, 'date'),
      location: _readNullableString(json, 'location'),
      members: rawMembers
          .map(
            (item) => ResearchSeminarCommitteeMember.fromJson(
              _asJsonObject(item, label: 'Thành viên hội đồng hội thảo'),
            ),
          )
          .toList(growable: false),
      research: ResearchSeminarCommitteeResearch.fromJson(
        _asJsonObject(
          json['research'],
          label: 'Đề tài trong hội đồng hội thảo',
        ),
      ),
    );
  }
}

class ResearchSeminarCommitteeResult {
  const ResearchSeminarCommitteeResult({
    required this.researches,
    required this.committee,
  });

  final List<ResearchSeminarOption> researches;
  final ResearchSeminarCommittee? committee;

  factory ResearchSeminarCommitteeResult.fromJson(Map<String, dynamic> json) {
    final rawResearches = json['researches'];
    if (rawResearches is! List) {
      throw const FormatException(
        'Danh sách đề tài hội thảo không đúng định dạng.',
      );
    }

    final rawCommittee = json['committee'];
    return ResearchSeminarCommitteeResult(
      researches: rawResearches
          .map(
            (item) => ResearchSeminarOption.fromJson(
              _asJsonObject(item, label: 'Đề tài hội thảo'),
            ),
          )
          .toList(growable: false),
      committee: rawCommittee == null
          ? null
          : ResearchSeminarCommittee.fromJson(
              _asJsonObject(rawCommittee, label: 'Hội đồng hội thảo'),
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
    throw const FormatException('Ngày tổ chức hội đồng hội thảo không hợp lệ.');
  }

  return date;
}
