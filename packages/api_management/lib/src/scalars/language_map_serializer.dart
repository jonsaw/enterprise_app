import 'package:api_management/src/scalars/json_string_serializer.dart';

/// Custom serializer for the LanguageMap GraphQL scalar.
class LanguageMapSerializer extends JsonStringSerializer {
  /// Creates a [LanguageMapSerializer].
  const LanguageMapSerializer();

  @override
  String get wireName => 'LanguageMap';
}
