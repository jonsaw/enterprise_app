import 'package:flutter/material.dart';

/// Width of the sidebar
const sidebarWidth = 400.0;

/// Medium screen breakpoint (sidebar visible, single panel navigation)
const mediumScreenBreakpoint = 768.0;

/// Large screen breakpoint (sidebar visible, split view with list and detail)
const largeScreenBreakpoint = 1200.0;

/// Checks if the given width corresponds to a small screen.
bool isSmallScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width < mediumScreenBreakpoint;
}

/// Checks if the given width corresponds to a medium screen only.
bool isMediumScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= mediumScreenBreakpoint && width < largeScreenBreakpoint;
}

/// Checks if the given width corresponds to a large screen.
bool isLargeScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= largeScreenBreakpoint;
}

/// Checks if the given width corresponds to a small or medium screen.
bool isSmallOrMediumScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width < largeScreenBreakpoint;
}

/// Checks if the given width corresponds to a medium or larger screen.
bool isMediumOrLargeScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= mediumScreenBreakpoint;
}
