import 'package:api_management/src/scalars/json_string_serializer.dart';

/// Custom serializer for the DetailsData GraphQL scalar.
class DetailsDataSerializer extends JsonStringSerializer {
  /// Creates a [DetailsDataSerializer].
  const DetailsDataSerializer();

  @override
  String get wireName => 'DetailsData';
}
