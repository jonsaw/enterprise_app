import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Width of the sidebar
const sidebarWidth = 400.0;

/// Checks if the given width corresponds to a small screen.
/// Small screens are mobile devices typically smaller than 768px (md breakpoint).
bool isSmallScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final breakpoints = context.theme.breakpoints;
  return width < breakpoints.md;
}

/// Checks if the given width corresponds to a medium screen only.
/// Medium screens are tablets between 768px (md) and 1024px (lg).
bool isMediumScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final breakpoints = context.theme.breakpoints;
  return width >= breakpoints.md && width < breakpoints.lg;
}

/// Checks if the given width corresponds to a large screen.
/// Large screens are desktop devices 1024px (lg) and above.
bool isLargeScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final breakpoints = context.theme.breakpoints;
  return width >= breakpoints.lg;
}

/// Checks if the given width corresponds to a small or medium screen.
/// Screens smaller than 1024px (lg breakpoint).
bool isSmallOrMediumScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final breakpoints = context.theme.breakpoints;
  return width < breakpoints.lg;
}

/// Checks if the given width corresponds to a medium or larger screen.
/// Screens 768px (md breakpoint) and above.
bool isMediumOrLargeScreen(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final breakpoints = context.theme.breakpoints;
  return width >= breakpoints.md;
}
