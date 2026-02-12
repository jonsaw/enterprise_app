# Enterprise Flutter Application - Architecture Guide

This is a multi-platform Flutter application with a monorepo structure, featuring GraphQL API integration, two-factor authentication, and comprehensive state management.

## Project Structure

```
enterprise_app/
├── lib/
│   ├── app/
│   │   ├── config/              # App configuration (AppConfig, Flavor)
│   │   ├── entities/            # Domain models (Auth, UserRole)
│   │   ├── logs/                # Logging configuration (Talker)
│   │   ├── pages/               # UI pages/screens
│   │   ├── router/              # Navigation/routing (GoRouter)
│   │   ├── state/               # State management (Riverpod providers)
│   │   ├── utils/               # Utility functions
│   │   └── widgets/             # Reusable widgets
│   ├── l10n/                    # Localization files (en, ms)
│   ├── main.dart                # Application entry point
│   ├── app_clients.dart         # GraphQL client setup
│   └── l10n.dart                # Localization exports
├── packages/
│   ├── api_auth/                # Authentication API package
│   └── api_management/          # Management API package
├── build_runner.sh              # Custom build script
├── l10n.yaml                    # Localization configuration
└── pubspec.yaml                 # Main dependencies
```

## Core Technologies

- **State Management:** Riverpod 3.0 with code generation
- **Routing:** GoRouter with TypedRoutes
- **GraphQL:** Ferry client with Hive CE caching
- **UI Framework:** Forui with Zinc theme
- **Storage:** Flutter Secure Storage for tokens, Hive CE for cache
- **Localization:** ARB files (English, Malay)
- **Logging:** Talker with Riverpod integration
- **Code Generation:** build_runner for providers, routes, GraphQL operations

## Architecture Patterns

### Layered Architecture
```
Presentation (Pages/Widgets)
      ↓
State Management (Riverpod Providers)
      ↓
Domain Logic (Controllers)
      ↓
Data Layer (GraphQL Clients)
      ↓
Backend APIs (Auth, Management)
```

### State Management (Riverpod)

**Key Providers:**
- `authControllerProvider` - Authentication state and operations
- `secureStorageServiceProvider` - Token and session persistence
- `permissionsProvider` - User role-based permissions
- `gqlAuthClientProvider` - GraphQL client for auth API
- `gqlManagementClientProvider` - GraphQL client for management API
- `routerProvider` - GoRouter instance with auth-based redirects

**Usage Pattern:**
```dart
// Watching state
final auth = ref.watch(authControllerProvider);

// Reading once
final storage = ref.read(secureStorageServiceProvider);

// Calling methods
await ref.read(authControllerProvider.notifier).signIn(email: email, password: password);
```

### Routing (GoRouter)

**Routes:**
- `/splash` - Loading screen during auth check
- `/signin` - Two-factor authentication (email/password + OTP)
- `/home` - Main dashboard (requires auth)
- `/profile` - User profile (requires auth)

**Authentication Flow:**
```
App Start → Splash → Check Session
    ↓
Session Valid? → Yes → Home
    ↓
    No → SignIn → Enter Credentials → OTP Verification → Home
```

**Redirect Logic:**
- Unauthenticated users → SignIn
- Authenticated users on splash → Home
- Auth errors → SignIn

### API Integration

**Two GraphQL Clients:**
1. **Auth Client** - Authentication operations (sign in, sign out, registration)
2. **Management Client** - Business logic (companies, integrations, items)

**Custom Links:**
- `AddAuthorizationHeaderLink` - Injects JWT token from SecureStorage
- `AddAcceptLanguageHeaderLink` - Adds locale header for i18n

**Caching Strategy:**
- Hive CE for local persistence
- Separate cache boxes per client
- Cache invalidation on auth changes

### Domain Models

**Auth Entity:**
```dart
@freezed
class Auth with _$Auth {
  const factory Auth({
    required String userId,
    required String name,
    required String email,
    required UserRole role,
  }) = _Auth;
}
```

**UserRole (Sealed Hierarchy):**
```dart
sealed class UserRole {}
final class Owner extends UserRole {}
final class Manager extends UserRole {}
final class User extends UserRole {}
final class None extends UserRole {}
```

## Monorepo Packages

### api_auth Package
**Location:** `packages/api_auth/`

**GraphQL Operations:**
- `authenticated.graphql` - Check session validity
- `sign_in.graphql` - Email/password authentication
- `confirm_sign_in.graphql` - OTP verification
- `resend_confirm_sign_in.graphql` - Resend OTP
- `sign_out.graphql` - End session
- `register.graphql` - User registration
- `confirm_registration.graphql` - Verify registration OTP
- `api_version.graphql` - Get API version

### api_management Package
**Location:** `packages/api_management/`

**GraphQL Operations:**
- `list_my_companies.graphql` - Fetch user's companies

**Schema Features:**
- Company management (CRUD)
- Company users and invites
- Integrations (MyEinvoice, BA, Shopify)
- Item types and currencies
- Service clients

## Localization

**Supported Locales:** English (en), Malay (ms)

**Files:**
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_ms.arb` - Malay translations
- `lib/l10n/generated/` - Auto-generated code

**Usage:**
```dart
Text(context.tr.appName)
Text(context.tr.signInTitle)
```

## Theming

**UI Framework:** Forui with Zinc color palette

**Dynamic Theming:**
- Automatic light/dark mode based on system brightness
- Smooth transitions with `FAnimatedTheme`

**Theme Access:**
```dart
final theme = context.theme;
theme.typography.xl4  // Typography
theme.colors.primary  // Colors
```

**Responsive Design:**
- Breakpoint: 768px
- Adaptive layouts for mobile/tablet/desktop
- Reusable components: `PageHeader`, `SectionWidget`, `AppShellPage`

## Code Generation

**Build Script:** `./build_runner.sh`

**Runs code generation for:**
1. `packages/api_auth/` - GraphQL operations
2. `packages/api_management/` - GraphQL operations
3. Main app - Riverpod providers, GoRouter routes, Freezed models

**Generated Files:**
- `*.g.dart` - Riverpod providers, JSON serialization
- `*.freezed.dart` - Immutable data classes
- `*.data.gql.dart` - GraphQL data models
- `*.req.gql.dart` - GraphQL request classes
- `*.var.gql.dart` - GraphQL variables
- `router.g.dart` - TypedGoRoute implementations

## Development Workflow

### Initial Setup
```bash
flutter pub get
./build_runner.sh
```

### Development
```bash
dart run build_runner watch -d  # Watch mode
flutter run                      # Run app
```

### Adding GraphQL Operations
1. Create `.graphql` file in `packages/api_{auth|management}/lib/src/components/graphql/`
2. Run `./build_runner.sh`
3. Import generated types from package
4. Use in Riverpod provider/controller

### Adding Localization
1. Add key to `lib/l10n/app_en.arb`
2. Add translation to `lib/l10n/app_ms.arb`
3. Run `flutter gen-l10n` (or restart app)
4. Use `context.tr.newKey`

### Creating New Pages
1. Add page widget in `lib/app/pages/`
2. Define route in `lib/app/router/router.dart` with `@TypedGoRoute`
3. Run `./build_runner.sh` to generate route
4. Navigate with `PageRoute().go(context)`

### Creating New Providers
1. Add provider in `lib/app/state/`
2. Use `@riverpod` annotation
3. Run `./build_runner.sh` to generate provider
4. Access with `ref.watch(providerNameProvider)`

## Key Files Reference

### Entry Points
- `lib/main.dart` - App initialization, provider setup
- `lib/app/router/router.dart` - Navigation configuration
- `lib/app_clients.dart` - GraphQL client creation

### State Management
- `lib/app/state/auth_controller.dart` - Authentication logic
- `lib/app/state/secure_storage_service.dart` - Token persistence
- `lib/app/state/permissions.dart` - Role-based permissions

### Configuration
- `lib/app/config/app_config.dart` - Environment config (endpoints, flavor)

### UI Components
- `lib/app/widgets/page_header.dart` - Reusable page header
- `lib/app/widgets/section_widget.dart` - Responsive section layout
- `lib/app/pages/app_shell_page.dart` - Navigation shell (sidebar/drawer)

### Utilities
- `lib/app/utils/utils.dart` - GraphQL client factory, device info
- `lib/l10n.dart` - Localization extension method

## Common Tasks

### Debugging Authentication
1. Check Talker logs in app (integrated with Riverpod)
2. Verify token in SecureStorage
3. Test GraphQL operations in GraphiQL/Playground
4. Check `authControllerProvider` state with Riverpod Inspector

### Clearing Cache/Storage
```dart
final storage = ref.read(secureStorageServiceProvider);
await storage.clearAll();  // Clears all tokens

// Clear Hive cache
await Hive.box('api_auth_cache_box').clear();
await Hive.box('api_management_cache_box').clear();
```

### Testing Navigation
```dart
HomeRoute().go(context);
ProfileRoute(userId: '123').push(context);
final location = GoRouterState.of(context).uri.toString();
```

### Accessing Auth State
```dart
final auth = ref.watch(authControllerProvider);
auth.when(
  data: (auth) => Text('Hello ${auth?.name}'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);

final role = await ref.watch(permissionsProvider.future);
if (role is Owner) {
  // Show admin features
}
```

## Troubleshooting

### Build Errors After Pull
```bash
flutter clean
flutter pub get
./build_runner.sh
```

### Provider Not Found
- Ensure provider file has `@riverpod` annotation
- Run `./build_runner.sh`
- Check imports include `.g.dart` file

### GraphQL Operation Not Generated
- Verify `.graphql` file syntax
- Check `build.yaml` in package
- Run build_runner with `--delete-conflicting-outputs`

### Route Not Found
- Ensure route has `@TypedGoRoute` annotation
- Verify route is in `$appRoutes` list
- Run `./build_runner.sh`

## Dependencies Overview

**Core:**
- flutter_riverpod - State management
- go_router - Routing
- ferry - GraphQL client
- forui - UI components
- hive_ce - Local database
- flutter_secure_storage - Secure storage
- freezed - Immutable models
- intl - Internationalization
- talker_flutter - Logging

**Dev:**
- build_runner - Code generation
- riverpod_lint - Riverpod lints
- very_good_analysis - Strict lints

## Configuration

**Endpoints:**
- Auth API: `https://resource-api.ap.ngrok.io/auth`
- Management API: `https://resource-api.ap.ngrok.io/management`

**Environment:** Set in `lib/main.dart` via `AppConfig.create()`

**Flavors:** production, staging, development (configured in AppConfig)

## Platform Support

Android, iOS, macOS, Web, Linux, Windows
