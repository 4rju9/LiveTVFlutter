import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/udpate/data/models/update_model.dart';

abstract class UpdateRepository {
  Future<Either<Failure, UpdateModel>> checkUpdate();
}
