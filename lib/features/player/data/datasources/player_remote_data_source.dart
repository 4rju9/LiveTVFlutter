import 'package:dio/dio.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';

abstract class PlayerRemoteDataSource {
  Future<StreamConfig> getAnimeStream(String episodeId, String title);
}

class PlayerRemoteDataSourceImpl implements PlayerRemoteDataSource {
  final Dio dio;
  PlayerRemoteDataSourceImpl(this.dio);

  @override
  Future<StreamConfig> getAnimeStream(String episodeId, String title) async {
    try {
      final serverRes = await dio.get(
        '${AppSecrets.animeBaseUrl}/api/servers/$episodeId',
      );

      if (serverRes.statusCode != 200 || serverRes.data['success'] != true) {
        throw ServerException('Failed to fetch available servers');
      }

      final List servers = serverRes.data['results'];
      final defaultServer = servers[0];

      final streamRes = await dio.get(
        '${AppSecrets.animeBaseUrl}/api/stream',
        queryParameters: {
          'id': episodeId,
          'server': defaultServer['serverName'],
          'type': defaultServer['type'],
        },
      );

      if (streamRes.statusCode == 200 && streamRes.data['success'] == true) {
        final result = streamRes.data['results'];

        final streamingLink = result['streamingLink'];
        final link = streamingLink['link'];
        final intro = streamingLink['intro'];
        final outro = streamingLink['outro'];

        return StreamConfig(
          url: link['file'],
          title: title,
          type: StreamType.hls,
          headers: {
            'Referer': 'https://megacloud.blog/',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          },
          subtitles: (streamingLink['tracks'] as List)
              .where((t) => t.containsKey('label'))
              .map((t) => SubtitleEntity(url: t['file'], label: t['label']))
              .toList(),
        );
      }
      throw ServerException('Failed to fetch streaming information');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
