import 'package:dio/dio.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';
import 'package:live_tv/features/player/domain/entities/anime_servers_entity.dart';

abstract class PlayerRemoteDataSource {
  Future<AnimeServersEntity> getAnimeServers(String episodeId);
  Future<StreamConfig> getAnimeStream(
      String episodeId, String title, String serverName, String category);
}

class PlayerRemoteDataSourceImpl implements PlayerRemoteDataSource {
  final Dio dio;
  PlayerRemoteDataSourceImpl(this.dio);

  @override
  Future<AnimeServersEntity> getAnimeServers(String episodeId) async {
    try {
      final serverRes = await dio.get(
        '${AppSecrets.animeBaseUrl}/api/servers/$episodeId',
      );

      if (serverRes.statusCode != 200 || serverRes.data['success'] != true) {
        throw ServerException('Failed to fetch available servers');
      }

      final List servers = serverRes.data['results'];
      final sub = <AnimeServerInfo>[];
      final dub = <AnimeServerInfo>[];

      for (var json in servers) {
        final server = AnimeServerInfo.fromJson(json);
        if (server.type == 'sub') {
          sub.add(server);
        } else if (server.type == 'dub') {
          dub.add(server);
        }
      }

      return AnimeServersEntity(sub: sub, dub: dub);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StreamConfig> getAnimeStream(
      String episodeId, String title, String serverName, String category) async {
    try {
      final streamRes = await dio.get(
        '${AppSecrets.animeBaseUrl}/api/stream',
        queryParameters: {
          'id': episodeId,
          'server': serverName,
          'type': category,
        },
      );

      if (streamRes.statusCode == 200 && streamRes.data['success'] == true) {
        final result = streamRes.data['results'];
        final streamingLink = result['streamingLink'];
        final link = streamingLink['link'];
        
        return StreamConfig(
          url: link['file'],
          title: title,
          type: StreamType.hls,
          headers: {'Referer': 'https://megacloud.blog/'},
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
