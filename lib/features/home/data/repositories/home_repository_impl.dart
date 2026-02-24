import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/home/data/datasources/home_remote_data_source.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, HomeDataEntity>> getLiveChannels() async {
    try {
      final res = await remoteDataSource.fetchAllLiveChannels();
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnimeDetailsEntity>> getAnimeDetails(
    String animeId,
  ) async {
    try {
      final info = await remoteDataSource.fetchAnimeInfo(animeId);
      final episodes = await remoteDataSource.fetchAnimeEpisodes(animeId);
      return Right(info.copyWithEpisodes(episodes));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
