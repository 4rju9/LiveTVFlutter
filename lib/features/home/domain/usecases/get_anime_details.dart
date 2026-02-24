import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/core/usecase/usecase.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class GetAnimeDetails implements UseCase<AnimeDetailsEntity, String> {
  final HomeRepository repository;

  GetAnimeDetails(this.repository);

  @override
  Future<Either<Failure, AnimeDetailsEntity>> call(String animeId) async {
    return await repository.getAnimeDetails(animeId);
  }
}
