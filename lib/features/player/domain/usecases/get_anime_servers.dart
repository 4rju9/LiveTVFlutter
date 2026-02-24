import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/core/usecase/usecase.dart';
import 'package:live_tv/features/player/domain/entities/anime_servers_entity.dart';
import 'package:live_tv/features/player/domain/repositories/player_repository.dart';

class GetAnimeServers implements UseCase<AnimeServersEntity, String> {
  final PlayerRepository repository;
  
  GetAnimeServers(this.repository);

  @override
  Future<Either<Failure, AnimeServersEntity>> call(String episodeId) async {
    return await repository.getAnimeServers(episodeId);
  }
}
