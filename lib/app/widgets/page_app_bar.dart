import 'package:enterprise/app/constants/constants.dart';
import 'package:enterprise/app/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_app_bar.g.dart';
part 'page_app_bar.freezed.dart';

/// State for the PageAppBarProvider.
@freezed
abstract class PageAppBarProviderState with _$PageAppBarProviderState {
  /// Creates a [PageAppBarProviderState].
  const factory PageAppBarProviderState({
    required String title,
  }) = _PageAppBarProviderState;

  const PageAppBarProviderState._();
}

/// Provider for managing the state of the page app bar.
@Riverpod(keepAlive: true)
class PageAppBarProvider extends _$PageAppBarProvider {
  @override
  PageAppBarProviderState build() {
    return const PageAppBarProviderState(title: '');
  }

  /// Sets the title of the app bar.
  set title(String value) {
    state = state.copyWith(title: value);
  }
}

/// A responsive page app bar widget that adapts to screen size.
///
/// This widget displays a page title that automatically adjusts based on the
/// screen dimensions:
/// - **Large screens**: The title is rendered directly on the page.
/// - **Small screens**: The title is hidden but updates the [PageAppBarProvider]
///   state, which can be read by [PageAppBarReader] in the app bar.
///
/// ## Usage
///
/// ```dart
/// PageAppBar(title: 'Dashboard')
/// ```
///
/// **Note**: [PageAppBarProvider] must be available in the widget tree.
///
/// See also:
/// - [PageAppBarReader], which reads the title from [PageAppBarProvider].
/// - [PageAppBarProvider], which manages the app bar title state.
class PageAppBar extends ConsumerWidget {
  /// Creates a [PageAppBar].
  const PageAppBar({required this.title, super.key});

  /// The title text to display on the page.
  ///
  /// On large screens, this is rendered directly. On small screens, it updates
  /// the [PageAppBarProvider] state instead.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    // Get current route path from context
    final currentPath = GoRouterState.of(context).uri.path;

    // Get the router's actual current location
    final router = ref.read(routerProvider);
    final actualCurrentPath =
        router.routerDelegate.currentConfiguration.uri.path;

    // Only set title if this page's route matches the actual current route
    if (currentPath == actualCurrentPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pageAppBarProviderProvider.notifier).title = title;
      });
    }

    if (!isLargeScreen(context)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: theme.typography.xl2.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A widget that displays the current page title from [PageAppBarProvider].
///
/// This widget is typically used in the app bar on small screens where
/// [PageAppBar] is hidden. It watches the [PageAppBarProvider] state and
/// displays the title set by the active page.
///
/// ## Usage
///
/// ```dart
/// AppBar(
///   title: PageAppBarReader(),
/// )
/// ```
///
/// See also:
/// - [PageAppBar], which sets the title in [PageAppBarProvider].
/// - [PageAppBarProvider], which manages the app bar title state.
class PageAppBarReader extends ConsumerWidget {
  /// Creates a [PageAppBarReader].
  const PageAppBarReader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final title = ref.watch(pageAppBarProviderProvider).title;

    return Text(
      title,
      style: theme.typography.xl2.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
