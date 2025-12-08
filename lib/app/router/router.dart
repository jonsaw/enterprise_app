import 'dart:async';

import 'package:enterprise/app/entities/auth.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/pages/home_page.dart';
import 'package:enterprise/app/pages/manager_page.dart';
import 'package:enterprise/app/pages/owner_page.dart';
import 'package:enterprise/app/pages/signin_page.dart';
import 'package:enterprise/app/pages/splash_page.dart';
import 'package:enterprise/app/pages/user_page.dart';
import 'package:enterprise/app/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  // build a `Listenable` to be fed to GoRouter
  final notifier = _AuthStateNotifier(ref.read(authControllerProvider));

  // update the notifier when the auth state changes
  ref
    ..onDispose(notifier.dispose)
    ..listen(authControllerProvider, (_, next) {
      notifier.update(next);
    });

  final router = GoRouter(
    navigatorKey: _routerKey,
    refreshListenable: notifier,
    initialLocation: const SplashRoute().location,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: (context, state) {
      final isSplash = state.uri.path == const SplashRoute().location;
      final isSigningIn = state.uri.path == const SignInRoute().location;

      switch (notifier.value) {
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
          if (isSplash) return const HomeRoute().location;
          if (isSigningIn) return const HomeRoute().location;

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

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<OwnerRoute>(path: 'owner'),
    TypedGoRoute<ManagerRoute>(path: 'manager'),
    TypedGoRoute<UserRoute>(path: 'user'),
  ],
)
/// home route - redirects based on user role
class HomeRoute extends GoRouteData with $HomeRoute {
  /// home route - redirects based on user role
  const HomeRoute();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    final container = ProviderScope.containerOf(context, listen: false);

    // Read auth state synchronously to avoid provider disposal
    final auth = container.read(authControllerProvider).value;

    if (auth == null) {
      return null;
    }

    return switch (auth.role) {
      Owner() => const OwnerRoute().location,
      User() => const UserRoute().location,
      Manager() => const ManagerRoute().location,
      None() => null,
    };
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

/// owner route - shows the owner page
class OwnerRoute extends GoRouteData with $OwnerRoute {
  /// owner route - shows the owner page
  const OwnerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OwnerPage();
  }
}

/// user route - shows the user page
class UserRoute extends GoRouteData with $UserRoute {
  /// user route - shows the user page
  const UserRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UserPage();
  }
}

/// manager route - shows the manager page
class ManagerRoute extends GoRouteData with $ManagerRoute {
  /// manager route - shows the manager page
  const ManagerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ManagerPage();
  }
}

/// ChangeNotifier that wraps auth state for GoRouter refresh
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(this._value);

  AsyncValue<Auth?> _value;

  AsyncValue<Auth?> get value => _value;

  void update(AsyncValue<Auth?> newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
}
