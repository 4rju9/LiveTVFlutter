import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/core/usecase/usecase.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class GetCachedLiveChannels implements UseCase<HomeDataEntity, NoParams> {
  final HomeRepository repository;

  GetCachedLiveChannels(this.repository);

  @override
  Future<Either<Failure, HomeDataEntity>> call(NoParams params) async {
    return await repository.getCachedLiveChannels();
  }
}
