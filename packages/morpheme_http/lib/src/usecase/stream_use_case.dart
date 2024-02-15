import '../errors/morpheme_failures.dart';
import '../utils/either.dart';

/// The interface for stream use case
abstract interface class StreamUseCase<Success, Body> {
  Stream<Either<MorphemeFailure, Success>> call(Body body);
}
