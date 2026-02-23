import 'package:dio/dio.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/home/data/models/live_channel_model.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, List<LiveChannelModel>>> fetchAllLiveChannels();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, List<LiveChannelModel>>> fetchAllLiveChannels() async {
    try {
      final response = await dio.get(AppSecrets.liveTvFetchEndpoint);
      final Map<String, dynamic> data = response.data;

      Map<String, List<LiveChannelModel>> categoryMap = {};

      data.forEach((categoryName, channelListJson) {
        if (channelListJson is List) {
          final List<LiveChannelModel> channels = channelListJson
              .map((json) => LiveChannelModel.fromJson(json))
              .toList();
          categoryMap[categoryName] = channels;
        }
      });

      return categoryMap;
    } catch (e) {
      throw ServerException('Failed to fetch live channels.');
    }
  }
}
