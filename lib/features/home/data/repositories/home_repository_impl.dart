import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/home/data/datasources/home_local_data_source.dart';
import 'package:live_tv/features/home/data/datasources/home_remote_data_source.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';
import 'package:live_tv/features/home/domain/entities/anime_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, HomeDataEntity>> getCachedLiveChannels() async {
    try {
      final res = await localDataSource.getCachedHomeData();
      if (res != null) {
        return Right(res);
      }
      return Left(Failure('No cache found'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

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
      final results = await Future.wait([
        remoteDataSource.fetchAnimeInfo(animeId),
        remoteDataSource.fetchAnimeEpisodes(animeId),
      ]);
      final info = results[0] as AnimeDetailsEntity;
      final episodes = results[1] as List<EpisodeEntity>;
      return Right(info.copyWithEpisodes(episodes));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnimeEntity>>> searchAnime(
    String keyword, {
    int page = 1,
  }) async {
    try {
      final res = await remoteDataSource.searchAnime(keyword, page: page);
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
