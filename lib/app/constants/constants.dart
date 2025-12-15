/// Width of the sidebar
const sidebarWidth = 400.0;

/// Large screen breakpoint
const largeScreenBreakpoint = 768.0;

/// Checks if the given width corresponds to a large screen.
bool isLargeScreen(double width) {
  return width >= largeScreenBreakpoint;
}
