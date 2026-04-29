Map<String, dynamic> asJsonMap(Object? data, {bool unwrapData = false}) {
  Object? source = data;

  if (unwrapData && data is Map && data['data'] is Map) {
    source = data['data'];
  }

  if (source is Map<String, dynamic>) {
    return source;
  }

  if (source is Map) {
    return Map<String, dynamic>.from(source);
  }

  return <String, dynamic>{};
}

Map<String, dynamic>? asNullableJsonMap(
  Object? data, {
  bool unwrapData = false,
}) {
  if (data == null) {
    return null;
  }

  Object? source = data;

  if (unwrapData && data is Map && data.containsKey('data')) {
    source = data['data'];
  }

  if (source == null) {
    return null;
  }

  if (source is Map<String, dynamic>) {
    return source.isEmpty ? null : source;
  }

  if (source is Map) {
    final map = Map<String, dynamic>.from(source);
    return map.isEmpty ? null : map;
  }

  return null;
}

List<Map<String, dynamic>> asJsonList(Object? data) {
  Object? source = data;

  if (data is Map && data['data'] is List) {
    source = data['data'];
  }

  if (source is List) {
    return source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  return const [];
}
