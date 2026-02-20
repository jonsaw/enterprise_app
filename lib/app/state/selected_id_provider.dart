import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_id_provider.g.dart';

/// Enum to distinguish between different types of selected IDs.
enum SelectedIdType {
  /// Selected invite ID
  invite,

  /// Selected user ID
  user,

  /// Selected product category ID
  productCategory,

  /// Selected product type ID
  productType,
}

/// Notifier for managing a selected ID.
///
/// This is a generic provider that can be used to manage any selected ID
/// in the application. Use [SelectedIdType] to distinguish between different
/// types of selections.
@riverpod
class SelectedId extends _$SelectedId {
  @override
  String? build(SelectedIdType type) => null;

  /// Update the selected ID.
  set id(String? id) {
    state = id;
  }
}
