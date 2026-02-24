import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/player/data/datasources/player_remote_data_source.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';
import 'package:live_tv/features/player/domain/repositories/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerRemoteDataSource remoteDataSource;
  PlayerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, StreamConfig>> getAnimeStream(
    String episodeId,
    String title,
  ) async {
    try {
      final streamConfig = await remoteDataSource.getAnimeStream(
        episodeId,
        title,
      );
      return Right(streamConfig);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
