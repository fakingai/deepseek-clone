import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

/// Failure related to server errors.
class ServerFailure extends Failure {}

/// Failure related to cache operations (local storage).
class CacheFailure extends Failure {}

/// Failure related to network connectivity issues.
class NetworkFailure extends Failure {}

/// Failure when a resource is not found.
class NotFoundFailure extends Failure {}

/// Failure for invalid input data.
class InvalidInputFailure extends Failure {}

/// Failure for authentication issues.
class AuthFailure extends Failure {}
