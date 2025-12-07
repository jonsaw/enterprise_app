import 'package:api_auth/api_auth.dart' as api_auth;
import 'package:enterprise/app/config/app_config.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/widgets/api_auth_version_widget.dart';
import 'package:enterprise/app_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_settings.dart';

void main() async {
  // Ensure Flutter binding is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.create(
    appName: 'Enterprise',
    authEndpoint: 'https://resource-api.ap.ngrok.io/auth',
  );

  final gqlAuthClient = await createClient(
    'api_auth_cache_box',
    AppConfig.shared.authEndpoint,
    api_auth.possibleTypesMap,
  );

  runApp(
    ProviderScope(
      overrides: [
        gqlAuthClientProvider.overrideWith((ref) => gqlAuthClient),
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
class MainApp extends StatelessWidget {
  /// Creates a [MainApp].
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: ApiAuthVersionWidget(),
        ),
      ),
    );
  }
}
