import 'dart:async';

import 'package:enterprise/app/entities/auth.dart';
import 'package:enterprise/app/pages/companies_page.dart';
import 'package:enterprise/app/pages/company_app_shell_page.dart';
import 'package:enterprise/app/pages/company_home_page.dart';
import 'package:enterprise/app/pages/company_invite_detail_page.dart';
import 'package:enterprise/app/pages/company_invites_page.dart';
import 'package:enterprise/app/pages/company_product_categories_page.dart';
import 'package:enterprise/app/pages/company_product_category_detail_page.dart';
import 'package:enterprise/app/pages/company_product_type_detail_page.dart';
import 'package:enterprise/app/pages/company_product_types_page.dart';
import 'package:enterprise/app/pages/company_profile_page.dart';
import 'package:enterprise/app/pages/company_shell_page.dart';
import 'package:enterprise/app/pages/company_user_detail_page.dart';
import 'package:enterprise/app/pages/company_users_page.dart';
import 'package:enterprise/app/pages/create_company_invite_page.dart';
import 'package:enterprise/app/pages/create_product_category_page.dart';
import 'package:enterprise/app/pages/create_product_type_page.dart';
import 'package:enterprise/app/pages/signin_page.dart';
import 'package:enterprise/app/pages/splash_page.dart';
import 'package:enterprise/app/pages/update_product_category_page.dart';
import 'package:enterprise/app/pages/update_product_type_page.dart';
import 'package:enterprise/app/state/auth_controller.dart';
import 'package:enterprise/app/state/product_category_detail_controller.dart';
import 'package:enterprise/app/state/product_type_detail_controller.dart';
import 'package:enterprise/app/widgets/app_header.dart';
import 'package:enterprise/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
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
    TypedShellRoute<CompanyShellRoute>(
      routes: [
        TypedGoRoute<CompanyBaseRoute>(
          path: ':companyId',
          routes: [
            TypedStatefulShellRoute<CompanyAppShellRoute>(
              branches: [
                TypedStatefulShellBranch(
                  routes: [
                    TypedGoRoute<CompanyHomeRoute>(path: 'home'),
                  ],
                ),
                TypedStatefulShellBranch(
                  routes: [
                    TypedGoRoute<CompanyProfileRoute>(path: 'profile'),
                  ],
                ),
                TypedStatefulShellBranch(
                  routes: [
                    TypedGoRoute<CompanyUsersRoute>(
                      path: 'users',
                      routes: [
                        TypedGoRoute<CompanyUserDetailRoute>(path: ':userId'),
                      ],
                    ),
                  ],
                ),
                TypedStatefulShellBranch(
                  routes: [
                    TypedGoRoute<CompanyInvitesRoute>(
                      path: 'invites',
                      routes: [
                        TypedGoRoute<CreateCompanyInviteRoute>(path: 'create'),
                        TypedGoRoute<CompanyInviteDetailRoute>(
                          path: ':inviteId',
                        ),
                      ],
                    ),
                  ],
                ),
                TypedStatefulShellBranch(
                  routes: [
                    TypedGoRoute<CompanyProductCategoriesRoute>(
                      path: 'product-categories',
                      routes: [
                        TypedGoRoute<CreateProductCategoryRoute>(
                          path: 'create',
                        ),
                        TypedGoRoute<CompanyProductCategoryDetailRoute>(
                          path: ':categoryId',
                          routes: [
                            TypedGoRoute<EditProductCategoryRoute>(
                              path: 'edit',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                TypedStatefulShellBranch(
                  routes: [
                    TypedGoRoute<CompanyProductTypesRoute>(
                      path: 'product-types',
                      routes: [
                        TypedGoRoute<CreateProductTypeRoute>(
                          path: 'create',
                        ),
                        TypedGoRoute<CompanyProductTypeDetailRoute>(
                          path: ':typeId',
                          routes: [
                            TypedGoRoute<EditProductTypeRoute>(
                              path: 'edit',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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

/// Company shell route - wraps all company routes with sidebar on medium+ screens
class CompanyShellRoute extends ShellRouteData {
  /// Creates a [CompanyShellRoute].
  const CompanyShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    final companyId = state.pathParameters['companyId'];
    if (companyId == null) {
      return navigator;
    }
    return CompanyShellPage(
      companyId: companyId,
      child: navigator,
    );
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

/// Company App shell route with branches for home and profile navigation
class CompanyAppShellRoute extends StatefulShellRouteData {
  /// Creates an [CompanyAppShellRoute].
  const CompanyAppShellRoute();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return NoTransitionPage(
      child: CompanyAppShellPage(
        key: ValueKey('shell-${state.pathParameters['companyId']}'),
        navigationShell: navigationShell,
      ),
    );
  }
}

/// Company home route - displays the main home page
class CompanyHomeRoute extends GoRouteData with $CompanyHomeRoute {
  /// Creates an [CompanyHomeRoute].
  const CompanyHomeRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyHomePage(companyId: companyId);
  }
}

/// Company profile route - displays the user profile page
class CompanyProfileRoute extends GoRouteData with $CompanyProfileRoute {
  /// Creates an [CompanyProfileRoute].
  const CompanyProfileRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyProfilePage(companyId: companyId);
  }
}

/// Company users route - displays the company users page
class CompanyUsersRoute extends GoRouteData with $CompanyUsersRoute {
  /// Creates a [CompanyUsersRoute].
  const CompanyUsersRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyUsersPage(companyId: companyId);
  }
}

/// Company user detail route - displays a single user's details
class CompanyUserDetailRoute extends GoRouteData with $CompanyUserDetailRoute {
  /// Creates a [CompanyUserDetailRoute].
  const CompanyUserDetailRoute({
    required this.companyId,
    required this.userId,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the user.
  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyUserDetailPage(
      companyId: companyId,
      userId: userId,
    );
  }
}

/// Company invites route - displays the company invites page
class CompanyInvitesRoute extends GoRouteData with $CompanyInvitesRoute {
  /// Creates a [CompanyInvitesRoute].
  const CompanyInvitesRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyInvitesPage(companyId: companyId);
  }
}

/// Company invite detail route - displays a single invite's details
class CompanyInviteDetailRoute extends GoRouteData
    with $CompanyInviteDetailRoute {
  /// Creates a [CompanyInviteDetailRoute].
  const CompanyInviteDetailRoute({
    required this.companyId,
    required this.inviteId,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the invite.
  final String inviteId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyInviteDetailPage(
      companyId: companyId,
      inviteId: inviteId,
    );
  }
}

/// Create company invite route - displays the create invite page
class CreateCompanyInviteRoute extends GoRouteData
    with $CreateCompanyInviteRoute {
  /// Creates a [CreateCompanyInviteRoute].
  const CreateCompanyInviteRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CreateCompanyInvitePage(
      companyId: companyId,
      onSuccess: () {
        // Pop back to invites page
        context.pop();
      },
    );
  }
}

/// Company product categories route - displays the product categories page
class CompanyProductCategoriesRoute extends GoRouteData
    with $CompanyProductCategoriesRoute {
  /// Creates a [CompanyProductCategoriesRoute].
  const CompanyProductCategoriesRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyProductCategoriesPage(companyId: companyId);
  }
}

/// Company product category detail route - displays a single category's details
class CompanyProductCategoryDetailRoute extends GoRouteData
    with $CompanyProductCategoryDetailRoute {
  /// Creates a [CompanyProductCategoryDetailRoute].
  const CompanyProductCategoryDetailRoute({
    required this.companyId,
    required this.categoryId,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the category.
  final String categoryId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyProductCategoryDetailPage(
      companyId: companyId,
      categoryId: categoryId,
    );
  }
}

/// Create product category route - displays the create category page
class CreateProductCategoryRoute extends GoRouteData
    with $CreateProductCategoryRoute {
  /// Creates a [CreateProductCategoryRoute].
  const CreateProductCategoryRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CreateProductCategoryPage(
      companyId: companyId,
      onSuccess: () {
        // Pop back to categories page
        context.pop();
      },
    );
  }
}

/// Edit product category route - edits an existing category
class EditProductCategoryRoute extends GoRouteData
    with $EditProductCategoryRoute {
  /// Creates an [EditProductCategoryRoute].
  const EditProductCategoryRoute({
    required this.companyId,
    required this.categoryId,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the category to edit.
  final String categoryId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _EditProductCategoryPageLoader(
      companyId: companyId,
      categoryId: categoryId,
    );
  }
}

/// Loader widget that fetches category data before showing the edit page
class _EditProductCategoryPageLoader extends ConsumerWidget {
  const _EditProductCategoryPageLoader({
    required this.companyId,
    required this.categoryId,
  });

  final String companyId;
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(
      productCategoryDetailControllerProvider(companyId, categoryId),
    );

    return categoryAsync.when(
      data: (category) {
        if (category == null) {
          return FScaffold(
            header: AppHeader.nested(
              title: Text(context.tr.editCategory),
              prefixes: [FHeaderAction.back(onPress: () => context.pop())],
            ),
            child: Center(
              child: Text(context.tr.categoryNotFound),
            ),
          );
        }

        return UpdateProductCategoryPage(
          companyId: companyId,
          categoryId: categoryId,
          initialName: category.name,
          initialDescription: category.description,
          onSuccess: () {
            // Pop back to detail page
            context.pop();
          },
        );
      },
      loading: () => FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.editCategory),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: const Center(child: FCircularProgress()),
      ),
      error: (error, stack) => FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.editCategory),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Text(context.tr.errorLoadingCategories),
              FButton(
                variant: .outline,
                onPress: () {
                  ref.invalidate(
                    productCategoryDetailControllerProvider(
                      companyId,
                      categoryId,
                    ),
                  );
                },
                child: Text(context.tr.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Company product types list route - displays all product types
class CompanyProductTypesRoute extends GoRouteData
    with $CompanyProductTypesRoute {
  /// Creates a [CompanyProductTypesRoute].
  const CompanyProductTypesRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyProductTypesPage(companyId: companyId);
  }
}

/// Company product type detail route - displays a single type's details
class CompanyProductTypeDetailRoute extends GoRouteData
    with $CompanyProductTypeDetailRoute {
  /// Creates a [CompanyProductTypeDetailRoute].
  const CompanyProductTypeDetailRoute({
    required this.companyId,
    required this.typeId,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the type.
  final String typeId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CompanyProductTypeDetailPage(
      companyId: companyId,
      typeId: typeId,
    );
  }
}

/// Create product type route - shows form to create a new product type
class CreateProductTypeRoute extends GoRouteData with $CreateProductTypeRoute {
  /// Creates a [CreateProductTypeRoute].
  const CreateProductTypeRoute({required this.companyId});

  /// The ID of the company.
  final String companyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CreateProductTypePage(
      companyId: companyId,
      onSuccess: () {
        // No need to pop - the create page already does that
      },
    );
  }
}

/// Edit product type route - shows form to edit an existing product type
class EditProductTypeRoute extends GoRouteData with $EditProductTypeRoute {
  /// Creates an [EditProductTypeRoute].
  const EditProductTypeRoute({
    required this.companyId,
    required this.typeId,
  });

  /// The ID of the company.
  final String companyId;

  /// The ID of the type to edit.
  final String typeId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _EditProductTypePageLoader(
      companyId: companyId,
      typeId: typeId,
    );
  }
}

/// Loader widget that fetches type data before showing the edit page
class _EditProductTypePageLoader extends ConsumerWidget {
  const _EditProductTypePageLoader({
    required this.companyId,
    required this.typeId,
  });

  final String companyId;
  final String typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeAsync = ref.watch(
      productTypeDetailControllerProvider(companyId, typeId),
    );

    return typeAsync.when(
      data: (type) {
        if (type == null) {
          return FScaffold(
            header: AppHeader.nested(
              title: Text(context.tr.editType),
              prefixes: [FHeaderAction.back(onPress: () => context.pop())],
            ),
            child: Center(
              child: Text(context.tr.typeNotFound),
            ),
          );
        }

        return UpdateProductTypePage(
          companyId: companyId,
          typeId: typeId,
          initialName: type.name,
          initialDescription: type.description,
          initialDetailsUi: type.detailsUi ?? '{}',
          revision: type.revision ?? 0,
          onSuccess: () {
            // Refresh the detail page after update
            // No need to pop - the update page already does that
          },
        );
      },
      loading: () => FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.editType),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: const Center(child: FCircularProgress()),
      ),
      error: (error, stack) => FScaffold(
        header: AppHeader.nested(
          title: Text(context.tr.editType),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Text(context.tr.errorLoadingTypes),
              FButton(
                variant: .outline,
                onPress: () {
                  ref.invalidate(
                    productTypeDetailControllerProvider(
                      companyId,
                      typeId,
                    ),
                  );
                },
                child: Text(context.tr.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
