import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';
import 'package:live_tv/features/home/domain/entities/anime_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class SearchAnimeParams {
  final String keyword;
  final int page;

  SearchAnimeParams({required this.keyword, this.page = 1});
}

class SearchAnime {
  final HomeRepository repository;

  SearchAnime(this.repository);

  Future<Either<Failure, List<AnimeEntity>>> call(SearchAnimeParams params) async {
    return await repository.searchAnime(params.keyword, page: params.page);
  }
}
