import 'package:dio/dio.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/home/data/models/anime_details_model.dart';
import 'package:live_tv/features/home/data/models/anime_model.dart';
import 'package:live_tv/features/home/data/models/live_channel_model.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataEntity> fetchAllLiveChannels();
  Future<AnimeDetailsModel> fetchAnimeInfo(String animeId);
  Future<List<EpisodeEntity>> fetchAnimeEpisodes(String animeId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);

  @override
  Future<HomeDataEntity> fetchAllLiveChannels() async {
    try {
      final response = await dio.get(AppSecrets.liveTvFetchEndpoint);
      final data = response.data;

      Map<String, List<LiveChannelModel>> categoryMap = {};
      AnimeDataModel? animeData;

      if (data is Map<String, dynamic>) {
        data.forEach((key, value) {
          if (key == 'anime' && value is Map<String, dynamic>) {
            final animeContent = value['data'];
            if (animeContent is Map<String, dynamic>) {
              animeData = AnimeDataModel.fromJson(animeContent);
            }
          } else if (value is List) {
            categoryMap[key] = value
                .map((json) => LiveChannelModel.fromJson(json))
                .toList();
          }
        });
      }

      return HomeDataEntity(channelsMap: categoryMap, animeData: animeData);
    } catch (e) {
      throw ServerException('Failed to fetch live channels.');
    }
  }

  @override
  Future<AnimeDetailsModel> fetchAnimeInfo(String animeId) async {
    try {
      final response = await dio.get(
        '${AppSecrets.animeBaseUrl}/api/info',
        queryParameters: {'id': animeId},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return AnimeDetailsModel.fromInfoJson(response.data);
      }
      throw ServerException('Failed to fetch anime info');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<EpisodeEntity>> fetchAnimeEpisodes(String animeId) async {
    try {
      final response = await dio.get(
        '${AppSecrets.animeBaseUrl}/api/episodes/$animeId',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List eps = response.data['results']['episodes'];
        return eps
            .map(
              (e) => EpisodeEntity(
                id: e['id'].toString(),
                title: e['title']?.toString() ?? 'Episode ${e['episode_no']}',
                episodeNumber: e['episode_no'].toString(),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
