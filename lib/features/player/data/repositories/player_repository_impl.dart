import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/player/data/datasources/player_remote_data_source.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';
import 'package:live_tv/features/player/domain/entities/anime_servers_entity.dart';
import 'package:live_tv/features/player/domain/repositories/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerRemoteDataSource remoteDataSource;
  PlayerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AnimeServersEntity>> getAnimeServers(String episodeId) async {
    try {
      final servers = await remoteDataSource.getAnimeServers(episodeId);
      return Right(servers);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StreamConfig>> getAnimeStream(
    String episodeId,
    String title,
    String serverName,
    String category,
  ) async {
    try {
      final streamConfig = await remoteDataSource.getAnimeStream(
        episodeId,
        title,
        serverName,
        category,
      );
      return Right(streamConfig);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
