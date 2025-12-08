import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/state/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions.g.dart';

/// Provider that derives the user's role from the authentication state.
///
/// Returns [None] if the user is not authenticated, otherwise returns
/// the user's role ([Owner], [Manager], or [User]).
@riverpod
Future<UserRole> permissions(Ref ref) async {
  final auth = await ref.watch(authControllerProvider.future);

  if (auth == null) {
    return const None();
  }

  return auth.role;
}
