import 'package:api_management/src/scalars/json_string_serializer.dart';

/// Custom serializer for the UI GraphQL scalar.
class UIStringSerializer extends JsonStringSerializer {
  /// Creates a [UIStringSerializer].
  const UIStringSerializer();

  @override
  String get wireName => 'UI';
}
