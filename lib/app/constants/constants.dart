import 'package:flutter/material.dart';

/// Width of the sidebar
const sidebarWidth = 400.0;

/// Medium screen breakpoint (sidebar visible, single panel navigation)
const mediumScreenBreakpoint = 768.0;

/// Large screen breakpoint (sidebar visible, split view with list and detail)
const largeScreenBreakpoint = 1200.0;

/// Checks if the given width corresponds to a small screen.
/// On small screens, sidebar is hidden and content uses single panel navigation.
bool isSmallScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width < mediumScreenBreakpoint;
}

/// Checks if the given width corresponds to a medium or larger screen.
/// On medium screens, sidebar is visible but content uses single panel navigation.
bool isMediumScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= mediumScreenBreakpoint;
}

/// Checks if the given width corresponds to a large screen.
/// On large screens, sidebar is visible and split view is used.
bool isLargeScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= largeScreenBreakpoint;
}
