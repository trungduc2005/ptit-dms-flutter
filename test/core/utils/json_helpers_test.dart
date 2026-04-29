import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';

void main() {
  test('returns a json map from a plain map', () {
    expect(asJsonMap({'id': '1'}), {'id': '1'});
  });

  test('unwraps data map only when requested', () {
    final response = {
      'data': {'id': '1'},
    };

    expect(asJsonMap(response), response);
    expect(asJsonMap(response, unwrapData: true), {'id': '1'});
  });

  test('returns null for nullable empty or non-map payloads', () {
    expect(asNullableJsonMap(null), isNull);
    expect(asNullableJsonMap({}), isNull);
    expect(asNullableJsonMap('invalid'), isNull);
  });

  test('unwraps list payloads from data', () {
    final items = asJsonList({
      'data': [
        {'id': '1'},
        'invalid',
        {'id': '2'},
      ],
    });

    expect(items, [
      {'id': '1'},
      {'id': '2'},
    ]);
  });
}
