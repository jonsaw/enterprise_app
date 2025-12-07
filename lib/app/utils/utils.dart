import 'package:ferry/ferry.dart';
import 'package:ferry_hive_ce_store/ferry_hive_ce_store.dart';
import 'package:gql_exec/gql_exec.dart' as gql_exec;
import 'package:gql_http_link/gql_http_link.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Create client using regular ferry client
Future<Client> createClient({
  required String boxName,
  required String endpoint,
  required Map<String, Set<String>> possibleTypesMap,
  Future<String?> Function()? getAuthToken,
  Future<String?> Function()? getLanguage,
}) async {
  await Hive.initFlutter();

  final box = await Hive.openBox<dynamic>(boxName);

  final store = HiveStore(box);

  final cache = Cache(store: store, possibleTypes: possibleTypesMap);

  final link = HttpLink(endpoint);

  final client = Client(
    link: Link.from([
      AddAuthorizationHeaderLink(getAuthToken ?? () async => null),
      AddAcceptLanguageHeaderLink(getLanguage ?? () async => null),
      link,
    ]),
    cache: cache,
  );

  return client;
}

/// A [Link] which adds a Accept-Language header to requests
class AddAcceptLanguageHeaderLink extends Link {
  /// Creates a [AddAcceptLanguageHeaderLink].
  AddAcceptLanguageHeaderLink(this.getLanguage);

  /// A function that returns the current language as a [Future<String?>].
  final Future<String?> Function() getLanguage;

  @override
  Stream<gql_exec.Response> request(
    gql_exec.Request request, [
    NextLink? forward,
  ]) async* {
    assert(
      forward != null,
      'AddAcceptLanguageHeaderLink cannot be the last link in the chain',
    );
    final lang = await getLanguage();
    if (lang != null) {
      final newReq = gql_exec.Request(
        operation: request.operation,
        variables: request.variables,
        context: request.context.updateEntry<gql_exec.HttpLinkHeaders>(
          (headers) => gql_exec.HttpLinkHeaders(
            headers: {
              ...?headers?.headers,
              'Accept-Language': lang,
            },
          ),
        ),
      );
      yield* forward!(newReq);
    } else {
      yield* forward!(request);
    }
  }
}

/// A [Link] which adds a Authorization header to requests
class AddAuthorizationHeaderLink extends Link {
  /// Creates a [AddAuthorizationHeaderLink].
  AddAuthorizationHeaderLink(this.getAuthToken);

  /// A function that returns the current authorization token
  /// as a [Future<String?>].
  final Future<String?> Function() getAuthToken;

  @override
  Stream<gql_exec.Response> request(
    gql_exec.Request request, [
    NextLink? forward,
  ]) async* {
    assert(
      forward != null,
      'AddAuthorizationHeaderLink cannot be the last link in the chain',
    );
    final token = await getAuthToken();
    if (token != null) {
      final newReq = gql_exec.Request(
        operation: request.operation,
        variables: request.variables,
        context: request.context.updateEntry<gql_exec.HttpLinkHeaders>(
          (headers) => gql_exec.HttpLinkHeaders(
            headers: {
              ...?headers?.headers,
              'Authorization': token,
            },
          ),
        ),
      );
      yield* forward!(newReq);
    } else {
      yield* forward!(request);
    }
  }
}
