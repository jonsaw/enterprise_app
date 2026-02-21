import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A [FTile] that shows a visual indicator when selected.
///
/// This wraps [FTile] and applies custom styling to show a background
/// color and border when [selected] is true.
class SelectableTile extends StatelessWidget {
  /// Creates a [SelectableTile].
  const SelectableTile({
    required this.title,
    this.subtitle,
    this.prefix,
    this.suffix,
    this.selected = false,
    this.enabled,
    this.onPress,
    this.onLongPress,
    super.key,
  });

  /// The tile's title.
  final Widget title;

  /// The tile's subtitle.
  final Widget? subtitle;

  /// A widget displayed before the title.
  final Widget? prefix;

  /// A widget displayed after the title.
  final Widget? suffix;

  /// Whether this tile is currently selected.
  final bool selected;

  /// Whether the tile is enabled.
  final bool? enabled;

  /// A callback for when the tile is pressed.
  final VoidCallback? onPress;

  /// A callback for when the tile is long pressed.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: title,
      subtitle: subtitle,
      prefix: prefix,
      suffix: suffix,
      enabled: enabled,
      onPress: onPress,
      onLongPress: onLongPress,
      style: selected
          ? .delta(
              decoration: .delta([
                .all(
                  .value(
                    BoxDecoration(
                      color: context.theme.colors.primary.withAlpha(25),
                      border: Border.all(color: context.theme.colors.primary),
                      borderRadius: context.theme.style.borderRadius,
                    ),
                  ),
                ),
              ]),
            )
          : const .context(),
      selected: selected,
    );
  }
}
