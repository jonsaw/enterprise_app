import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'split_view_size_provider.g.dart';

/// Common group identifier for company-related pages (users, invites, etc.)
/// that should share the same split view size.
const String companyPagesGroup = 'companyPages';

/// Notifier for managing split view size for a specific group.
///
/// Use [companyPagesGroup] for pages that should share the same width,
/// or provide a unique string for pages that need independent sizing.
@riverpod
class SplitViewSize extends _$SplitViewSize {
  @override
  double? build(String group) {
    return null;
  }

  /// Update the size for this group.
  set size(double value) {
    state = value;
  }
}
