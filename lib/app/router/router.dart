import 'dart:async';

import 'package:enterprise/app/entities/auth.dart';
import 'package:enterprise/app/pages/app_shell_page.dart';
import 'package:enterprise/app/pages/companies_page.dart';
import 'package:enterprise/app/pages/home_page.dart';
import 'package:enterprise/app/pages/profile_page.dart';
import 'package:enterprise/app/pages/signin_page.dart';
import 'package:enterprise/app/pages/splash_page.dart';
import 'package:enterprise/app/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// Exposes a [GoRouter] that uses a [Listenable] to refresh its internal
/// state.
///
/// With Riverpod, we can't register a dependency via an Inherited Widget,
/// thus making this implementation the "leanest" possible
///
/// To sync our app state with this our router, we simply update our
/// listenable via `ref.listen`, and pass it to GoRouter's
/// `refreshListenable`. In this example, this will trigger redirects on any
/// authentication change.
///
/// Obviously, more logic could be implemented here, but again, this is meant
/// to be a simple example. You can always build more listenables and even
/// merge more than one into a more complex `ChangeNotifier`, but that's up
/// to your case and out of this scope.
@riverpod
GoRouter router(Ref ref) {
  final auth = ValueNotifier<AsyncValue<Auth?>>(const AsyncLoading());
  ref
    ..onDispose(auth.dispose)
    ..listen(authControllerProvider, (_, next) {
      auth.value = next;
    });

  final router = GoRouter(
    navigatorKey: _routerKey,
    refreshListenable: auth,
    initialLocation: const SplashRoute().location,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: (context, state) {
      final isSplash = state.uri.path == const SplashRoute().location;
      final isSigningIn = state.uri.path == const SignInRoute().location;

      switch (auth.value) {
        case AsyncError():
          return const SignInRoute().location;
        case AsyncLoading():
          // Only show splash if we're not already on signin page
          // This prevents getting stuck on splash during sign out
          if (isSigningIn) return null;
          return isSplash ? null : const SplashRoute().location;
        case AsyncData(value: null):
          if (isSplash) return const SignInRoute().location;
          if (isSigningIn) return null;

          return const SignInRoute().location;
        case AsyncData(value: Auth()):
          if (isSplash) return const CompaniesRoute().location;
          if (isSigningIn) return const CompaniesRoute().location;

          return null;
      }
    },
  );

  ref.onDispose(router.dispose);
  return router;
}

final _routerKey = GlobalKey<NavigatorState>(debugLabel: 'routerKey');

/// splash route - serves as a "buffer", while we check authentication
@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  /// splash route - serves as a "buffer", while we check authentication
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashPage();
  }
}

/// signin route - shows a sign-in page with two-step authentication
@TypedGoRoute<SignInRoute>(path: '/signin')
class SignInRoute extends GoRouteData with $SignInRoute {
  /// signin route - shows a sign-in page with two-step authentication
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SignInPage();
  }
}

/// Companies route - shows list of companies
@TypedGoRoute<CompaniesRoute>(
  path: '/companies',
  routes: [
    TypedGoRoute<CompanyBaseRoute>(
      path: ':companyId',
      routes: [
        TypedStatefulShellRoute<AppShellRoute>(
          branches: [
            TypedStatefulShellBranch(
              routes: [
                TypedGoRoute<AppHomeRoute>(path: 'home'),
              ],
            ),
            TypedStatefulShellBranch(
              routes: [
                TypedGoRoute<AppProfileRoute>(path: 'profile'),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
)
class CompaniesRoute extends GoRouteData with $CompaniesRoute {
  /// Creates a [CompaniesRoute].
  const CompaniesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CompaniesPage();
  }
}

/// Company base route - parent for company-specific routes
class CompanyBaseRoute extends GoRouteData with $CompanyBaseRoute {
  /// Creates a [CompanyBaseRoute].
  const CompanyBaseRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SizedBox.shrink();
  }

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    // Check if the current location ends with the company ID (meaning no sub-route)
    if (state.uri.path.endsWith(companyId)) {
      return '${state.uri.path}/home';
    }
    return null;
  }
}

/// App shell route with branches for home and profile navigation
class AppShellRoute extends StatefulShellRouteData {
  /// Creates an [AppShellRoute].
  const AppShellRoute();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return NoTransitionPage(
      child: AppShellPage(
        key: ValueKey('shell-${state.pathParameters['companyId']}'),
        navigationShell: navigationShell,
      ),
    );
  }
}

/// Home route - displays the main home page
class AppHomeRoute extends GoRouteData with $AppHomeRoute {
  /// Creates an [AppHomeRoute].
  const AppHomeRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return HomePage(companyId: companyId);
  }
}

/// Profile route - displays the user profile page
class AppProfileRoute extends GoRouteData with $AppProfileRoute {
  /// Creates an [AppProfileRoute].
  const AppProfileRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}
