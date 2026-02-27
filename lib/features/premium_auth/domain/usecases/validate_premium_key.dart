import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';

class ValidatePremiumKey {
  Future<Either<Failure, bool>> call(String key) async {
    if (key.length != 16) {
      return Left(Failure('Invalid Key: Must be 16 characters long.'));
    }
    try {
      return const Right(true);
    } catch (e) {
      return Left(Failure('Server verification failed.'));
    }
  }
}
