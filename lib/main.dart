import 'package:api_auth/api_auth.dart' as api_auth;
import 'package:enterprise/app/config/app_config.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/router/router.dart';
import 'package:enterprise/app/state/secure_storage_service.dart';
import 'package:enterprise/app_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forui/forui.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_settings.dart';

void main() async {
  // Ensure Flutter binding is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.create(
    appName: 'Enterprise',
    authEndpoint: 'https://resource-api.ap.ngrok.io/auth',
  );

  // Create secure storage service
  final storage = SecureStorageService(const FlutterSecureStorage());

  // Create GraphQL client with secure storage integration
  final gqlAuthClient = await createClient(
    'api_auth_cache_box',
    AppConfig.shared.authEndpoint,
    api_auth.possibleTypesMap,
    storage,
  );

  runApp(
    ProviderScope(
      overrides: [
        gqlAuthClientProvider.overrideWith((ref) => gqlAuthClient),
        secureStorageServiceProvider.overrideWith((ref) => storage),
      ],
      observers: [
        TalkerRiverpodObserver(
          talker: talker,
          settings: const TalkerRiverpodLoggerSettings(
            printProviderDisposed: true,
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

/// The main application widget.
class MainApp extends ConsumerWidget {
  /// Creates a [MainApp].
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Enterprise',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        return FAnimatedTheme(
          data: FThemes.zinc.dark,
          child: child!,
        );
      },
    );
  }
}
