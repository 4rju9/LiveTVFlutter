import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/player/domain/entities/stream_config.dart';
import 'package:live_tv/features/player/domain/usecases/get_anime_stream.dart';

abstract class PlayerState {}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerLoaded extends PlayerState {
  final StreamConfig config;
  PlayerLoaded(this.config);
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError(this.message);
}

class PlayerCubit extends Cubit<PlayerState> {
  final GetAnimeStream _getAnimeStream;

  PlayerCubit({required GetAnimeStream getAnimeStream})
    : _getAnimeStream = getAnimeStream,
      super(PlayerInitial());

  void loadAnimeEpisode(String episodeId, String title) async {
    emit(PlayerLoading());
    final result = await _getAnimeStream(
      GetAnimeStreamParams(episodeId: episodeId, title: title),
    );
    result.fold(
      (failure) => emit(PlayerError(failure.message)),
      (config) => emit(PlayerLoaded(config)),
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
