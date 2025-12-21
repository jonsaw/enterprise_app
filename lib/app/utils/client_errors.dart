import 'package:ferry/ferry.dart';

/// Base class for client errors.
sealed class ClientError {
  const ClientError(this.code, this.reason);

  /// The code of the client error.
  final String code;

  /// The reason for the bad request.
  final String reason;
}

/// Represents a bad request error from the client.
final class BadRequestError extends ClientError {
  /// Creates a [BadRequestError] with the given [reason].
  BadRequestError(String reason) : super('bad_request', reason);
}

/// Represents a precondition failed error from the client.
final class PreconditionFailedError extends ClientError {
  /// Creates a [PreconditionFailedError] with the given [reason].
  PreconditionFailedError(String reason) : super('precondition_failed', reason);
}

/// Represents a not found error from the client.
final class NotFoundError extends ClientError {
  /// Creates a [NotFoundError] with the given [reason].
  NotFoundError(String reason) : super('not_found', reason);
}

/// Represents a too many requests error from the client.
final class TooManyRequestsError extends ClientError {
  /// Creates a [TooManyRequestsError] with the given [reason].
  TooManyRequestsError(String reason) : super('too_many_requests', reason);
}

/// Represents an unauthorized error from the client.
final class UnauthorizedError extends ClientError {
  /// Creates an [UnauthorizedError] with the given [reason].
  UnauthorizedError(String reason) : super('unauthorized', reason);
}

/// Represents a forbidden error from the client.
final class ForbiddenError extends ClientError {
  /// Creates a [ForbiddenError] with the given [reason].
  ForbiddenError(String reason) : super('forbidden', reason);
}

/// Represents an internal server error from the client.
final class InternalServerError extends ClientError {
  /// Creates an [InternalServerError] with the given [reason].
  InternalServerError(String reason) : super('internal_server_error', reason);
}

/// Represents an unknown error from the client.
final class UnknownClientError extends ClientError {
  /// Creates an [UnknownClientError] with the given [reason].
  UnknownClientError(super.code, super.reason);
}

/// Helper to extract error message from Graphql errors
/// Returns the first (code, reason) if available
ClientError graphqlErrorMessage<D, V>(
  OperationResponse<D, V> response,
) {
  if (response.graphqlErrors != null && response.graphqlErrors!.isNotEmpty) {
    final error = response.graphqlErrors!.first;
    final extensions = error.extensions;
    if (extensions != null) {
      final code = extensions['code'] as String?;
      final reason = extensions['reason'] as String? ?? error.message;

      if (code != null) {
        switch (code) {
          case 'bad_request':
            return BadRequestError(reason);
          case 'precondition_failed':
            return PreconditionFailedError(reason);
          case 'not_found':
            return NotFoundError(reason);
          case 'too_many_requests':
            return TooManyRequestsError(reason);
          case 'unauthorized':
            return UnauthorizedError(reason);
          case 'forbidden':
            return ForbiddenError(reason);
          case 'internal_server_error':
            return InternalServerError(reason);
          default:
            return UnknownClientError(code, reason);
        }
      }

      return UnknownClientError('unknown_error', reason);
    }
  }
  return UnknownClientError('unknown_error', 'Invalid error response');
}
