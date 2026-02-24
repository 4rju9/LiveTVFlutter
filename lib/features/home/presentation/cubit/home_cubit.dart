import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/core/usecase/usecase.dart';
import 'package:live_tv/features/home/domain/entities/anime_entity.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';
import 'package:live_tv/features/home/domain/usecases/get_cached_live_channels.dart';
import 'package:live_tv/features/home/domain/usecases/get_live_channels.dart';
import 'package:live_tv/features/home/domain/usecases/search_anime.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Map<String, List<LiveChannelEntity>> channelsMap;
  final AnimeDataEntity? animeData;
  HomeLoaded(this.channelsMap, this.animeData);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}


class AnimeSearchLoading extends HomeState {}

class AnimeSearchLoaded extends HomeState {
  final List<AnimeEntity> results;
  AnimeSearchLoaded(this.results);
}

class HomeCubit extends Cubit<HomeState> {
  final GetLiveChannels _getLiveChannels;
  final GetCachedLiveChannels _getCachedLiveChannels;
  final SearchAnime _searchAnime;

  HomeCubit(
    this._getLiveChannels,
    this._getCachedLiveChannels,
    this._searchAnime,
  ) : super(HomeInitial());

  void fetchChannels() async {
    emit(HomeLoading());
    
    // 1. Try to load cached data immediately to unblock UI
    final cachedResult = await _getCachedLiveChannels(NoParams());
    cachedResult.fold(
      (failure) => null, // Ignore cache misses
      (data) => emit(HomeLoaded(data.channelsMap, data.animeData)),
    );

    // 2. Fetch fresh data from network in background
    final result = await _getLiveChannels(NoParams());
    result.fold(
      (failure) {
        // Only emit error if we don't already have cached data loaded
        if (state is! HomeLoaded) {
          emit(HomeError(failure.message));
        }
      },
      (data) => emit(HomeLoaded(data.channelsMap, data.animeData)),
    );
  }


  Timer? _searchDebounce;

  void executeAnimeSearch(String keyword, {int page = 1}) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    _searchDebounce = Timer(const Duration(seconds: 1), () async {
      if (keyword.isEmpty) {
        // Revert to HomeLoaded with default data if search goes empty
        fetchChannels();
        return;
      }
      emit(AnimeSearchLoading());
      final result = await _searchAnime(
        SearchAnimeParams(keyword: keyword, page: page),
      );
      result.fold(
        (failure) => emit(HomeError(failure.message)),
        (data) => emit(AnimeSearchLoaded(data)),
      );
    });
  }
}
