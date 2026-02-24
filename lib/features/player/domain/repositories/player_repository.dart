import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';

abstract class PlayerRepository {
  Future<Either<Failure, StreamConfig>> getAnimeStream(
    String episodeId,
    String title,
  );
}
