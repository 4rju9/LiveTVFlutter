import 'package:dio/dio.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/home/data/models/anime_model.dart';
import 'package:live_tv/features/home/data/models/live_channel_model.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataEntity> fetchAllLiveChannels();
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
}
