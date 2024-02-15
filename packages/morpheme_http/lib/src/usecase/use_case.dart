import '../errors/morpheme_failures.dart';
import '../utils/either.dart';

/// The interface for future use case
abstract interface class UseCase<Success, Body> {
  Future<Either<MorphemeFailure, Success>> call(Body body);
}
