import 'package:api_auth/api_auth.dart';
import 'package:enterprise/app_clients.dart';
import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that displays the API version from the auth endpoint
class ApiAuthVersionWidget extends ConsumerWidget {
  /// Creates an [ApiAuthVersionWidget]
  const ApiAuthVersionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(gqlAuthClientProvider);

    return StreamBuilder<OperationResponse<GAPIVersionData, GAPIVersionVars>>(
      stream: client.request(GAPIVersionReq()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final data = snapshot.data?.data;
        if (data == null) {
          return Text(
            'No version data',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }

        return Text(
          'API v${data.apiVersion}',
          style: Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}
