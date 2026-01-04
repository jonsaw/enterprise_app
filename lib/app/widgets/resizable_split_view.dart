import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A reusable two-panel resizable layout widget.
///
/// This widget provides a horizontal split view with resizable panels,
/// handling window resize scenarios to prevent invalid extent values.
class ResizableSplitView extends StatefulWidget {
  /// Creates a [ResizableSplitView].
  const ResizableSplitView({
    required this.leftPanel,
    required this.rightPanel,
    this.initialLeftExtentRatio = 0.3,
    this.minExtentRatio = 0.3,
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

  @override
  State<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<ResizableSplitView> {
  double? _leftPanelExtent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;
        final minExtent = halfWidth * widget.minExtentRatio;
        final maxExtent =
            constraints.maxWidth - minExtent; // Reserve space for right panel

        // Initialize extent on first build only
        _leftPanelExtent ??=
            constraints.maxWidth * widget.initialLeftExtentRatio;

        // Ensure left panel extent is within valid bounds
        // This handles window resize scenarios where the stored extent
        // may be too large for the new window size
        final validLeftExtent = _leftPanelExtent!.clamp(minExtent, maxExtent);

        return FResizable(
          hitRegionExtent: 10,
          axis: Axis.horizontal,
          children: [
            FResizableRegion(
              initialExtent: validLeftExtent,
              minExtent: minExtent,
              builder: (context, data, _) {
                // Update stored extent when user resizes
                if (data.extent.current != _leftPanelExtent) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _leftPanelExtent = data.extent.current;
                      });
                    }
                  });
                }
                return widget.leftPanel;
              },
            ),
            FResizableRegion(
              initialExtent: constraints.maxWidth - validLeftExtent,
              minExtent: minExtent,
              builder: (context, data, _) {
                return widget.rightPanel;
              },
            ),
          ],
        );
      },
    );
  }
}
