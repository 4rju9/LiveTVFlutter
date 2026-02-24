import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';
import 'package:live_tv/features/player/domain/entities/anime_servers_entity.dart';
import 'package:live_tv/features/player/domain/usecases/get_anime_stream.dart';
import 'package:live_tv/features/player/domain/usecases/get_anime_servers.dart';

abstract class PlayerState {}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerLoaded extends PlayerState {
  final StreamConfig config;
  final AnimeServersEntity? servers;
  final AnimeServerInfo? activeServer;

  PlayerLoaded(this.config, {this.servers, this.activeServer});
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError(this.message);
}

class PlayerCubit extends Cubit<PlayerState> {
  final GetAnimeStream _getAnimeStream;
  final GetAnimeServers _getAnimeServers;

  PlayerCubit({
    required GetAnimeStream getAnimeStream,
    required GetAnimeServers getAnimeServers,
  })  : _getAnimeStream = getAnimeStream,
        _getAnimeServers = getAnimeServers,
        super(PlayerInitial());

  void loadAnimeEpisode(String episodeId, String title) async {
    emit(PlayerLoading());

    final serversResult = await _getAnimeServers(episodeId);
    serversResult.fold(
      (failure) => emit(PlayerError(failure.message)),
      (servers) async {

        AnimeServerInfo? defaultServer;
        if (servers.sub.isNotEmpty) {
          defaultServer = servers.sub.first;
        } else if (servers.dub.isNotEmpty) {
          defaultServer = servers.dub.first;
        }

        if (defaultServer == null) {
          emit(PlayerError("No servers available for this episode."));
          return;
        }
        
        final streamResult = await _getAnimeStream(
          GetAnimeStreamParams(
            episodeId: episodeId,
            title: title,
            serverName: defaultServer.serverName,
            category: defaultServer.type,
          ),
        );

        streamResult.fold(
          (failure) => emit(PlayerError(failure.message)),
          (config) => emit(PlayerLoaded(
            config,
            servers: servers,
            activeServer: defaultServer,
          )),
        );
      },
    );
  }

  void changeServer(String episodeId, String title, AnimeServersEntity servers, AnimeServerInfo newServer) async {
    emit(PlayerLoading());
    final streamResult = await _getAnimeStream(
      GetAnimeStreamParams(
        episodeId: episodeId,
        title: title,
        serverName: newServer.serverName,
        category: newServer.type,
      ),
    );

    streamResult.fold(
      (failure) => emit(PlayerError(failure.message)),
      (config) => emit(PlayerLoaded(
        config,
        servers: servers,
        activeServer: newServer,
      )),
    );
  }

  void loadLiveChannel(String url, String name) {
    emit(PlayerLoading());
    final config = StreamConfig(
      url: url,
      title: name,
      type: StreamType.hls,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
      subtitles: null,
    );
    emit(PlayerLoaded(config));
  }
}
