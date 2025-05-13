import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Interface for all Use Cases in the application.
/// 
/// [Type] - The return type of the use case
/// [Params] - The parameters required by the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when a use case doesn't require any parameters.
class NoParams {
  const NoParams();
}
