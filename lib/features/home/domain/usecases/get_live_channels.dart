import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/core/usecase/usecase.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class GetLiveChannels
    implements UseCase<Map<String, List<LiveChannelEntity>>, NoParams> {
  final HomeRepository repository;

  GetLiveChannels(this.repository);

  @override
  Future<Either<Failure, Map<String, List<LiveChannelEntity>>>> call(
    NoParams params,
  ) async {
    return await repository.getLiveChannels();
  }
}
