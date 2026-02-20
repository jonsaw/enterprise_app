# Claude Code Instructions

For detailed architecture, see ARCHITECTURE.md.

## Key Commands

- Code generation: `./build_runner.sh`
- Analyzer: `flutter analyze`
- Localization: `flutter gen-l10n`
- Clean rebuild: `flutter clean && flutter pub get && ./build_runner.sh`

## Rules

- Run `./build_runner.sh` after modifying `.graphql` files, `@riverpod`/`@freezed` annotations, or `@TypedGoRoute` routes.
- Run `flutter gen-l10n` after modifying `.arb` files.
- Run `flutter analyze` before considering any task complete.
- Use `context.tr.*` for all user-facing strings. Never hardcode strings.
- Use Forui components (F-prefixed) for UI. Do not use raw Material widgets.
- Use `@riverpod` annotation for all providers. Never create providers manually.
- Use `freezed` for all data classes.
- Use sealed classes for type hierarchies.
- GraphQL operations go in `packages/api_{auth|management}/lib/src/components/graphql/`.
- New pages go in `lib/app/pages/` with a `@TypedGoRoute` in `lib/app/router/router.dart`.
- New providers go in `lib/app/state/` with `@riverpod` annotation.
- Localization: add keys to both `lib/l10n/app_en.arb` and `lib/l10n/app_ms.arb`.
