import 'dart:io';

import 'package:enterprise/app/state/secure_storage_service.dart';
import 'package:enterprise/app/utils/utils.dart' as utils;
import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_clients.g.dart';

/// Creates a GraphQL client for the given [endpoint] with the specified
/// [boxName] for caching and [possibleTypesMap] for handling unions and
/// interfaces.
///
/// The [storage] parameter is used to retrieve the authentication token
/// for authenticated requests.
Future<TypedLink> createClient(
  String boxName,
  String endpoint,
  Map<String, Set<String>> possibleTypesMap,
  SecureStorageService storage,
) async {
  var lang = 'en';
  if (!kIsWeb) lang = Platform.localeName.split('_').first;

  return utils.createClient(
    boxName: boxName,
    endpoint: endpoint,
    possibleTypesMap: possibleTypesMap,
    getLanguage: () async => lang,
    getAuthToken: () async {
      final token = await storage.getToken();
      return token ?? '';
    },
  );
}

/// Provides the GraphQL client for authentication-related operations.
@riverpod
TypedLink gqlAuthClient(Ref ref) {
  // will be overridden in main.dart after creating the client asynchronously
  throw UnimplementedError();
}

/// Provides the GraphQL client for management-related operations.
@riverpod
TypedLink gqlManagementClient(Ref ref) {
  // will be overridden in main.dart after creating the client asynchronously
  throw UnimplementedError();
}
