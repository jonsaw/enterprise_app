import 'package:enterprise/app/state/split_view_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// A reusable two-panel resizable layout widget.
///
/// This widget provides a horizontal split view with resizable panels,
/// handling window resize scenarios to prevent invalid extent values.
///
/// Sizes can be shared across different instances by using the same
/// [sizeGroup]. For example, all pages using [companyPagesGroup]
/// will maintain the same left panel width.
class ResizableSplitView extends ConsumerWidget {
  /// Creates a [ResizableSplitView].
  const ResizableSplitView({
    required this.leftPanel,
    required this.rightPanel,
    this.initialLeftExtentRatio = 0.3,
    this.minExtentRatio = 0.3,
    this.sizeGroup,
    super.key,
  }) : assert(
         initialLeftExtentRatio > 0 && initialLeftExtentRatio < 1,
         'initialLeftExtentRatio must be between 0 and 1',
       ),
       assert(
         minExtentRatio > 0 && minExtentRatio < 0.5,
         'minExtentRatio must be between 0 and 0.5',
       );

  /// The widget to display in the left panel.
  final Widget leftPanel;

  /// The widget to display in the right panel.
  final Widget rightPanel;

  /// The initial ratio of the left panel width to the total width.
  /// Defaults to 0.5 (50%).
  final double initialLeftExtentRatio;

  /// The minimum ratio of each panel width to half of the total width.
  /// Defaults to 0.3 (30% of half width).
  final double minExtentRatio;

  /// The group that determines size sharing behavior.
  ///
  /// Pages with the same group will share the same left panel width.
  /// Use [companyPagesGroup] for company-related pages, or provide
  /// a unique string for independent sizing. If null, each instance
  /// maintains its own size (uses a unique key based on hashCode).
  final String? sizeGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use sizeGroup if provided, otherwise use a unique key for this instance
    final group = sizeGroup ?? 'independent_$hashCode';

    final sizeNotifier = ref.watch(splitViewSizeProvider(group).notifier);
    final storedSize = ref.watch(splitViewSizeProvider(group));

    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;
        final minExtent = halfWidth * minExtentRatio;
        final maxExtent =
            constraints.maxWidth - minExtent; // Reserve space for right panel

        // Use stored size from the provider if available,
        // otherwise use the initial ratio
        final leftPanelExtent =
            storedSize ?? constraints.maxWidth * initialLeftExtentRatio;

        // Ensure left panel extent is within valid bounds
        // This handles window resize scenarios where the stored extent
        // may be too large for the new window size
        final validLeftExtent = leftPanelExtent.clamp(minExtent, maxExtent);

        return FResizable(
          hitRegionExtent: 10,
          axis: Axis.horizontal,
          children: [
            FResizableRegion(
              initialExtent: validLeftExtent,
              minExtent: minExtent,
              builder: (context, data, _) {
                // Update stored extent in the provider when user resizes
                if (data.extent.current != storedSize) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    sizeNotifier.size = data.extent.current;
                  });
                }
                return leftPanel;
              },
            ),
            FResizableRegion(
              initialExtent: constraints.maxWidth - validLeftExtent,
              minExtent: minExtent,
              builder: (context, data, _) {
                return rightPanel;
              },
            ),
          ],
        );
      },
    );
  }
}
