import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A custom header implementation that provides control over SafeArea behavior.
///
/// This widget is based on [FHeader] but allows customization of SafeArea edges,
/// which is useful for different screen sizes where you may want to disable
/// certain SafeArea constraints.
///
/// Example:
/// ```dart
/// // Default - maintains all safe areas except bottom
/// AppHeader(
///   title: Text('My Page'),
/// )
///
/// // Disable all safe areas
/// AppHeader(
///   title: Text('My Page'),
///   maintainSafeArea: false,
/// )
///
/// // Custom safe area control
/// AppHeader(
///   title: Text('My Page'),
///   safeAreaTop: false, // Allow content under status bar
///   safeAreaLeft: true,
///   safeAreaRight: true,
/// )
/// ```
class AppHeader extends StatelessWidget {
  /// Creates a root header with customizable SafeArea.
  const AppHeader({
    this.title = const SizedBox(),
    this.style,
    this.suffixes = const [],
    this.maintainSafeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = false,
    this.safeAreaLeft = true,
    this.safeAreaRight = true,
    super.key,
  }) : nested = false,
       prefixes = const [],
       titleAlignment = Alignment.centerLeft;

  /// Creates a nested header with customizable SafeArea.
  const AppHeader.nested({
    this.title = const SizedBox(),
    this.style,
    this.prefixes = const [],
    this.suffixes = const [],
    this.titleAlignment = Alignment.center,
    this.maintainSafeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = false,
    this.safeAreaLeft = false,
    this.safeAreaRight = true,
    super.key,
  }) : nested = true;

  /// The title widget.
  final Widget title;

  /// The header's style customization.
  final FHeaderStyle Function(FHeaderStyle style)? style;

  /// The actions aligned to the right in LTR locales (left in RTL).
  final List<Widget> suffixes;

  /// Whether this is a nested header (with centered title and back button support).
  final bool nested;

  /// The actions aligned to the left in LTR locales (right in RTL).
  /// Only applicable when [nested] is true.
  final List<Widget> prefixes;

  /// The title's alignment for nested headers.
  final AlignmentGeometry titleAlignment;

  /// Whether to maintain safe area at all. If false, all safe area edges are disabled.
  final bool maintainSafeArea;

  /// Whether to maintain top safe area (status bar).
  final bool safeAreaTop;

  /// Whether to maintain bottom safe area.
  final bool safeAreaBottom;

  /// Whether to maintain left safe area.
  final bool safeAreaLeft;

  /// Whether to maintain right safe area.
  final bool safeAreaRight;

  @override
  Widget build(BuildContext context) {
    final headerStyle = nested
        ? (style?.call(context.theme.headerStyles.nestedStyle) ??
              context.theme.headerStyles.nestedStyle)
        : (style?.call(context.theme.headerStyles.rootStyle) ??
              context.theme.headerStyles.rootStyle);

    var header = _buildHeader(context, headerStyle);

    // Wrap with SafeArea if needed
    if (maintainSafeArea) {
      header = SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        left: safeAreaLeft,
        right: safeAreaRight,
        child: header,
      );
    }

    // Apply background filter if specified
    if (headerStyle.backgroundFilter case final filter?) {
      header = Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(filter: filter, child: Container()),
            ),
          ),
          header,
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: headerStyle.systemOverlayStyle,
      child: header,
    );
  }

  Widget _buildHeader(BuildContext context, FHeaderStyle headerStyle) {
    if (nested) {
      return _buildNestedHeader(context, headerStyle);
    } else {
      return _buildRootHeader(context, headerStyle);
    }
  }

  Widget _buildRootHeader(BuildContext context, FHeaderStyle headerStyle) {
    return Semantics(
      header: true,
      child: Padding(
        padding: headerStyle.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style: headerStyle.titleTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                child: title,
              ),
            ),
            FHeaderData(
              actionStyle: headerStyle.actionStyle,
              child: Row(
                children: suffixes
                    .expand(
                      (action) => [
                        SizedBox(width: headerStyle.actionSpacing),
                        action,
                      ],
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNestedHeader(BuildContext context, FHeaderStyle headerStyle) {
    final alignment = titleAlignment.resolve(
      Directionality.maybeOf(context) ?? TextDirection.ltr,
    );

    return Semantics(
      header: true,
      child: DecoratedBox(
        decoration: headerStyle.decoration,
        child: Padding(
          padding: headerStyle.padding,
          child: FHeaderData(
            actionStyle: headerStyle.actionStyle,
            child: _NestedHeaderLayout(
              alignment: alignment,
              prefixes: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: headerStyle.actionSpacing,
                children: prefixes,
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DefaultTextStyle.merge(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                  style: headerStyle.titleTextStyle,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  child: title,
                ),
              ),
              suffixes: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: headerStyle.actionSpacing,
                children: suffixes,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('nested', nested))
      ..add(DiagnosticsProperty('titleAlignment', titleAlignment))
      ..add(
        FlagProperty(
          'maintainSafeArea',
          value: maintainSafeArea,
          ifFalse: 'no safe area',
        ),
      )
      ..add(
        FlagProperty(
          'safeAreaTop',
          value: safeAreaTop,
          ifFalse: 'no top safe area',
        ),
      )
      ..add(
        FlagProperty(
          'safeAreaBottom',
          value: safeAreaBottom,
          ifTrue: 'bottom safe area',
        ),
      )
      ..add(
        FlagProperty(
          'safeAreaLeft',
          value: safeAreaLeft,
          ifFalse: 'no left safe area',
        ),
      )
      ..add(
        FlagProperty(
          'safeAreaRight',
          value: safeAreaRight,
          ifFalse: 'no right safe area',
        ),
      );
  }
}

// Custom layout widget for nested header to properly position prefixes, title, and suffixes
class _NestedHeaderLayout extends MultiChildRenderObjectWidget {
  _NestedHeaderLayout({
    required this.alignment,
    required Widget prefixes,
    required Widget title,
    required Widget suffixes,
  }) : super(children: [prefixes, title, suffixes]);

  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderNestedHeaderLayout(
        alignment: alignment,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderNestedHeaderLayout renderObject,
  ) => renderObject
    ..alignment = alignment
    ..direction = Directionality.of(context);
}

class _RenderNestedHeaderLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _NestedHeaderLayoutData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _NestedHeaderLayoutData> {
  _RenderNestedHeaderLayout({
    required Alignment alignment,
    required TextDirection textDirection,
  }) : _alignment = alignment,
       _direction = textDirection;

  Alignment _alignment;
  TextDirection _direction;

  @override
  void setupParentData(RenderBox child) =>
      child.parentData = _NestedHeaderLayoutData();

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    final prefixes = firstChild!;
    final title = childAfter(prefixes)!;
    final suffixes = childAfter(title)!;

    // Layout prefixes and suffixes first (they take priority)
    prefixes.layout(constraints, parentUsesSize: true);
    suffixes.layout(constraints, parentUsesSize: true);

    // Layout title with remaining space
    title.layout(
      constraints.copyWith(
        maxWidth:
            constraints.maxWidth - prefixes.size.width - suffixes.size.width,
      ),
      parentUsesSize: true,
    );

    // Calculate container height
    final height = [
      title.size.height,
      prefixes.size.height,
      suffixes.size.height,
    ].reduce(max);
    size = constraints.constrain(Size(constraints.maxWidth, height));

    // Position prefixes and suffixes based on text direction
    final (left, right) = _direction == TextDirection.ltr
        ? (prefixes, suffixes)
        : (suffixes, prefixes);

    (left.parentData! as _NestedHeaderLayoutData).offset = Offset(
      0,
      (size.height - left.size.height) / 2,
    );
    (right.parentData! as _NestedHeaderLayoutData).offset = Offset(
      size.width - right.size.width,
      (size.height - right.size.height) / 2,
    );

    // Position title based on alignment
    final titleX = (size.width - title.size.width) / 2 * (_alignment.x + 1);
    final titleY = (size.height - title.size.height) * (_alignment.y + 1) / 2;
    (title.parentData! as _NestedHeaderLayoutData).offset = Offset(
      titleX.clamp(
        left.size.width,
        size.width - right.size.width - title.size.width,
      ),
      titleY,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  Alignment get alignment => _alignment;

  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  TextDirection get direction => _direction;

  set direction(TextDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }
}

class _NestedHeaderLayoutData extends ContainerBoxParentData<RenderBox> {}
