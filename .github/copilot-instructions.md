# Project Guidelines

Enterprise Flutter app with GraphQL APIs, Riverpod state management, and ForUI components.

For detailed architecture, see [ARCHITECTURE.md](../ARCHITECTURE.md).

## Build and Test

```bash
# Code generation (after modifying .graphql, @riverpod, @freezed, or @TypedGoRoute)
./build_runner.sh

# Localization (after modifying .arb files)
flutter gen-l10n

# Linting — run before considering any task complete
flutter analyze

# Clean rebuild
flutter clean && flutter pub get && ./build_runner.sh
```

No test suite exists yet. Validate changes with `flutter analyze`.

## Code Style

- **Dart dot-shorthands** for named constructors, static methods, and enum values. Never for unnamed constructors:
  ```dart
  // Good
  FButton(variant: .outline, ...)
  EdgeInsetsGeometry padding = .all(8);
  // Bad — don't use .new()
  FWidgetStyle style = FWidgetStyle(...);  // Use this instead
  ```
- **Geometry types**: Prefer `AlignmentGeometry` / `BorderRadiusGeometry` / `EdgeInsetsGeometry` over concrete `Alignment` / `BorderRadius` / `EdgeInsets`.
- **UI framework**: Use ForUI (`F`-prefixed) components. Do not use raw Material or Cupertino widgets.
- **Lints**: `very_good_analysis` with `riverpod_lint`. Line length limit relaxed.

## Architecture

### Layers
```
Pages/Widgets → Riverpod Providers → GraphQL Clients → Backend APIs
```

### Key directories
| Directory | Purpose |
|-----------|---------|
| `lib/app/pages/` | All pages (flat, no subfolders) |
| `lib/app/state/` | Riverpod providers/controllers |
| `lib/app/entities/` | Freezed domain models + sealed class hierarchies |
| `lib/app/widgets/` | Reusable widgets (forms, layout, sidebar) |
| `lib/app/router/router.dart` | GoRouter with TypedGoRoute annotations |
| `lib/app/config/` | AppConfig, Flavor enum |
| `lib/app/constants/` | Breakpoints, sidebar width |
| `lib/l10n/` | ARB files (English + Malay) |
| `packages/api_auth/` | Auth GraphQL package |
| `packages/api_management/` | Management GraphQL package |

### Two GraphQL clients
- **Auth** (`gqlAuthClientProvider`) — sign in, OTP, registration
- **Management** (`gqlManagementClientProvider`) — business logic (companies, products, users)

Both are `@riverpod` providers overridden in `main.dart`.

## Conventions

### Pages
- Use `ConsumerStatefulWidget` for pages with local state; `ConsumerWidget` for simple pages.
- Receive IDs as constructor parameters (`companyId`, `categoryId`, etc.).
- Responsive layout: `isMediumOrLargeScreen(context)` → `ResizableSplitView`; small → push navigation.
- Wrap form pages in `UnsavedChangesScope`. Use `GlobalKey<FormState>` + `TextEditingController`.
- Handle async state with `.when(data:, loading:, error:)`.
- Show feedback via `showFToast(context: context, title: Text(context.tr.xxx))`.

### Providers (`@riverpod`)
Always use `@riverpod` annotation — never create providers manually:
- **Data fetchers**: Class-based `_$Controller`, parameterized by IDs (family pattern), returns `Future<T>` from `build()`.
- **Action controllers**: `FutureOr<void> build()`, action methods return `(bool, String?)` tuple `(success, errorMessage)`.
- **Simple state**: Override `build()` for initial value, expose setters.
- **Keep-alive**: Use `@Riverpod(keepAlive: true)` when state must persist across navigation.
- Invalidate stale data: `ref.invalidate(someControllerProvider)`.

### Entities
- Use `@freezed` for all data classes.
- Use `sealed class` for type hierarchies (e.g., `UserRole`).
- Map from GraphQL types via named factory constructors: `Entity.fromGraphQL(...)`.
- No JSON serialization — entities only map from GraphQL generated types.

### Routing
- Define routes in `lib/app/router/router.dart` with `@TypedGoRoute`.
- Route classes extend `GoRouteData with $RouteName`.
- Use `ShellRouteData` for layout wrappers, `StatefulShellRouteData` for tabbed navigation.
- Navigate with `SomeRoute(id: '...').go(context)`.
- Run `./build_runner.sh` after any route changes.

### GraphQL Operations
- `.graphql` files go in `packages/api_{auth|management}/lib/src/components/graphql/`.
- Snake_case filenames matching the operation.
- Import generated types from barrel file: `package:api_management/api_management.dart`.
- Use `FetchPolicy.NetworkOnly` for mutations and fresh-data queries.
- Run `./build_runner.sh` after adding/modifying operations.

### Localization
- Add keys to **both** `lib/l10n/app_en.arb` and `lib/l10n/app_ms.arb`.
- Key naming: camelCase, suffixed by intent (`*Title`, `*Message`, `*Hint`, `*Required`).
- CRUD pattern: `create*`, `edit*`, `delete*`, `*CreatedSuccessfully`, `failedToCreate*`.
- Access via `context.tr.keyName`. Never hardcode user-facing strings.
- Run `flutter gen-l10n` after changes.

### Theming
- Access via `context.theme` — never hard-code colors.
- Typography: `context.theme.typography.xl4`, etc.
- Responsive breakpoints from ForUI: small (<768), medium (768–1024), large (≥1024).

### Logging
- Use the global `talker` instance: `talker.info(...)`, `talker.error(...)`, `talker.warning(...)`.
