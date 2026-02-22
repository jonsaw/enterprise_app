import 'dart:convert';

import 'package:built_value/serializer.dart';

/// Base serializer for GraphQL scalars that represent JSON objects as strings.
///
/// Handles deserialization from server responses (Map, List, or String) and
/// serialization back to JSON objects for wire transmission.
abstract class JsonStringSerializer implements PrimitiveSerializer<String> {
  /// Creates a [JsonStringSerializer].
  const JsonStringSerializer();

  @override
  String deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    if (serialized is String) {
      return serialized;
    } else if (serialized is Map) {
      return jsonEncode(serialized);
    } else if (serialized is List) {
      final list = serialized;
      if (list.length.isEven && list.isNotEmpty) {
        // built_value deserializes Maps as alternating key-value Lists:
        // [key1, value1, key2, value2, ...]
        var isAlternatingPattern = true;
        for (var i = 0; i < list.length; i += 2) {
          if (list[i] is! String) {
            isAlternatingPattern = false;
            break;
          }
        }

        if (isAlternatingPattern) {
          final map = <String, dynamic>{};
          for (var i = 0; i < list.length; i += 2) {
            map[list[i] as String] = _convertValue(list[i + 1]);
          }
          return jsonEncode(map);
        }
      }

      return jsonEncode(serialized);
    } else {
      return serialized.toString();
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    String object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    try {
      return jsonDecode(object) as Object;
    } on FormatException {
      return object;
    }
  }

  @override
  Iterable<Type> get types => [String];

  /// Recursively converts built_value alternating lists to proper Map/List structures.
  dynamic _convertValue(dynamic value) {
    if (value is List) {
      if (value.length.isEven && value.isNotEmpty) {
        var isAlternatingPattern = true;
        for (var i = 0; i < value.length; i += 2) {
          if (value[i] is! String) {
            isAlternatingPattern = false;
            break;
          }
        }

        if (isAlternatingPattern) {
          final map = <String, dynamic>{};
          for (var i = 0; i < value.length; i += 2) {
            map[value[i] as String] = _convertValue(value[i + 1]);
          }
          return map;
        }
      }

      return value.map(_convertValue).toList();
    } else if (value is Map) {
      return Map<String, dynamic>.from(
        value.map((k, v) => MapEntry(k.toString(), _convertValue(v))),
      );
    }

    return value;
  }
}
