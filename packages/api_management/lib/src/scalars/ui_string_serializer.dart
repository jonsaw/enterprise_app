import 'dart:convert';

import 'package:built_value/serializer.dart';

/// Custom serializer for UI scalar that converts JSON objects to/from strings.
class UIStringSerializer implements PrimitiveSerializer<String> {
  @override
  String deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    // When deserializing from the server, it comes as structured JSON
    // We need to encode it to a string for our app to use
    if (serialized is String) {
      // Already a string, use as-is
      return serialized;
    } else if (serialized is Map) {
      // It's a Map, encode it to JSON string
      return jsonEncode(serialized);
    } else if (serialized is List) {
      // built_value deserializes Maps as alternating key-value Lists
      // Pattern: [key1, value1, key2, value2, ...]
      final list = serialized;
      if (list.length.isEven && list.isNotEmpty) {
        // Check if it's an alternating key-value pattern
        var isAlternatingPattern = true;
        for (var i = 0; i < list.length; i += 2) {
          if (list[i] is! String) {
            // Keys should be strings
            isAlternatingPattern = false;
            break;
          }
        }

        if (isAlternatingPattern) {
          // Reconstruct as Map
          final map = <String, dynamic>{};
          for (var i = 0; i < list.length; i += 2) {
            map[list[i] as String] = _convertValue(list[i + 1]);
          }
          return jsonEncode(map);
        }
      }

      // Regular list - encode as-is
      return jsonEncode(serialized);
    } else {
      // Fallback: convert to string
      return serialized.toString();
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    String object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    // When serializing to send to the server, parse the JSON string
    // and return the actual object structure (Map or List)
    try {
      return jsonDecode(object) as Object;
    } on FormatException {
      // If parsing fails, return as-is
      return object;
    }
  }

  @override
  Iterable<Type> get types => [String];

  @override
  String get wireName => 'UI';

  /// Recursively convert built_value alternating lists to proper structures.
  dynamic _convertValue(dynamic value) {
    if (value is List) {
      if (value.length.isEven && value.isNotEmpty) {
        // Check if ALL even-indexed elements are strings (map keys)
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

      // Regular list - convert each element
      return value.map(_convertValue).toList();
    } else if (value is Map) {
      return Map<String, dynamic>.from(
        value.map(
          (k, v) => MapEntry(k.toString(), _convertValue(v)),
        ),
      );
    }

    // Primitive value - return as-is
    return value;
  }
}
