import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';
import 'package:live_tv/features/player/domain/entities/anime_servers_entity.dart';

abstract class PlayerRepository {
  Future<Either<Failure, AnimeServersEntity>> getAnimeServers(String episodeId);

  Future<Either<Failure, StreamConfig>> getAnimeStream(
    String episodeId,
    String title,
    String serverName,
    String category,
  );
}
