# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Toolchain and commands

- The project requires Dart `^3.10.7` and Flutter `>=3.22.0`. Install packages with `flutter pub get`.
- Run the app with `flutter run`; list/select targets with `flutter devices` and `flutter run -d <device-id>`.
- The API URL is currently a source constant in `lib/core/network/dio_client.dart`. Its `10.0.2.2` host reaches the development machine from an Android emulator; change/configure it before using another target or backend location.
- Static analysis: `flutter analyze`.
- Format all Dart sources: `dart format lib test`.
- Check formatting without changing files: `dart format --output=none --set-exit-if-changed lib test`.
- Run all tests: `flutter test`.
- Run one test file: `flutter test test/path/to/file_test.dart`.
- Run one named test: `flutter test test/path/to/file_test.dart --plain-name "test name"`.
- Build Android: `flutter build apk` (or `flutter build appbundle`). Other checked-in Flutter targets can use the corresponding `flutter build <target>` command.
- There is no code-generation dependency or generated Dart model layer; entities and JSON parsing are handwritten. Do not add a `build_runner` step unless the dependencies and source annotations are introduced.

## Architecture

This is a Flutter client organized as a layered application with feature-oriented presentation code:

- `lib/domain/entities/` contains immutable value/request/response objects. They usually extend `Equatable` and implement `fromJson`/`toJson` manually.
- `lib/domain/repositories/` defines the interfaces consumed by presentation BLoCs.
- `lib/data/datasources/` owns Dio endpoint calls and response-shape parsing. Authenticated endpoints opt into bearer headers with `Options(extra: {requiresBearerAuthKey: true})`.
- `lib/data/repositories/` implements domain interfaces, delegates to remote data sources, maps `DioException` through `DioExceptionMapper`, and translates malformed payloads to typed `AppException`s.
- `lib/features/` is the presentation layer. Each feature groups pages, widgets, and one or more `flutter_bloc` event/state/BLoC sets. Page widgets normally create feature-scoped BLoCs using repository interfaces from `context.read<T>()`; BLoCs should consume domain repositories rather than Dio/data sources directly.
- `lib/core/` contains cross-feature networking, dependency composition, routing, errors, theme, JSON/model parsers, and reusable form widgets.

The usual request path is:

`Page/widget -> BLoC event -> domain repository interface -> repository implementation -> remote data source -> Dio/backend`

Results flow back as domain entities. Repository implementations convert transport and parsing failures to `AppException`; feature BLoCs expose localized loading/success/failure state to widgets.

## Application composition and authentication

- `lib/main.dart` awaits `AppDependencies.create()` before calling `runApp`.
- `lib/core/di/injection.dart` is the manual composition root. It creates one persistent cookie jar, one shared Dio instance, every remote data source, and every repository. When adding a repository, wire it here, pass it through `App`, and register its domain interface in `MultiRepositoryProvider`.
- `lib/app.dart` publishes repositories at the app root and owns the app-wide `AuthBloc`.
- The Dio client persists cookies under the application documents directory. Its interceptor order is cookie management, CSRF header injection, opt-in bearer authentication, then automatic refresh/retry for specific 401 error codes. Preserve request `extra` flags when adding authenticated calls.
- Splash dispatches `AuthStarted` and replaces the root route with login or the main shell. Logout/unauthenticated state also clears the root navigation stack.

## Navigation

Navigation has two levels and does not use a declarative routing package:

- `lib/core/router/` handles only root routes: splash, login, and the authenticated main shell.
- `MainShellPage` keeps four independent nested `Navigator` stacks in an `IndexedStack` for Home, Utilities, Notifications, and Profile. Re-selecting a tab pops that tab to its root; system back first pops the active tab stack, then returns to Home.
- `lib/features/main/navigation/main_tab_routes.dart` chooses the router for each tab. Utility screens belong in `lib/features/utilities/navigation/utilities_routes.dart` and `utilities_router.dart`; profile child routes belong in the profile routing files.
- Child routes are pushed on the current tab navigator. Use the root navigator only for app-wide transitions/dialogs that must sit above the shell.

## Feature conventions

- Larger workflows commonly separate a context/load BLoC from submit/action BLoCs. Keep loading state and mutation state distinct when following those features.
- Event, state, and BLoC files are handwritten; the BLoC file commonly exports its sibling event and state files.
- API payloads are not fully uniform. Use `core/utils/json_helpers.dart` and existing nearby parsers to handle direct payloads versus `{data: ...}` envelopes, and validate required identities instead of blindly casting.
- Shared visual form primitives live in `lib/core/widgets/form/`; feature-specific compositions and validation remain under the feature.
- UI and error copy is predominantly Vietnamese; preserve that language and nearby terminology when modifying user-visible strings.

## Tests

Tests mirror the source layers under `test/`:

- BLoC tests use `bloc_test` and `mocktail`, mocking domain repository interfaces.
- Data-source tests mock Dio behavior and verify payload parsing/request construction.
- Repository tests verify transport/parsing exception mapping.
- Widget tests cover pages and reusable feature sections.

When changing an API-backed feature, identify the affected layer and run its focused test file first, then `flutter test` and `flutter analyze`.
