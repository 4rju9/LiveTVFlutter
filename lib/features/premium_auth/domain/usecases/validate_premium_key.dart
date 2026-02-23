import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';

class ValidatePremiumKey {
  Future<Either<Failure, bool>> call(String key) async {
    // 1. Basic length check for 16 chars
    if (key.length != 16) {
      return Left(Failure('Invalid Key: Must be 16 characters long.'));
    }

    try {
      // 2. Logic to verify with your backend via Dio goes here
      // For now, we return true for validation logic
      return const Right(true);
    } catch (e) {
      return Left(Failure('Server verification failed.'));
    }
  }
}
