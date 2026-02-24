import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/core/usecase/usecase.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';
import 'package:live_tv/features/player/domain/repositories/player_repository.dart';

class GetAnimeStream implements UseCase<StreamConfig, GetAnimeStreamParams> {
  final PlayerRepository repository;
  GetAnimeStream(this.repository);

  @override
  Future<Either<Failure, StreamConfig>> call(
    GetAnimeStreamParams params,
  ) async {
    return await repository.getAnimeStream(params.episodeId, params.title);
  }
}

class GetAnimeStreamParams {
  final String episodeId;
  final String title;
  GetAnimeStreamParams({required this.episodeId, required this.title});
}
