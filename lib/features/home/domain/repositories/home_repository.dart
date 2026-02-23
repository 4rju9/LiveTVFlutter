import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, Map<String, List<LiveChannelEntity>>>>
  getLiveChannels();
}
