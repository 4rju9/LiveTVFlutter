import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/core/usecase/usecase.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/domain/entities/anime_entity.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';
import 'package:live_tv/features/home/domain/usecases/get_live_channels.dart';
import 'package:live_tv/features/home/domain/usecases/get_anime_details.dart';

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

class AnimeDetailsLoading extends HomeState {}

class AnimeDetailsLoaded extends HomeState {
  final AnimeDetailsEntity details;
  AnimeDetailsLoaded(this.details);
}

class HomeCubit extends Cubit<HomeState> {
  final GetLiveChannels _getLiveChannels;
  final GetAnimeDetails _getAnimeDetails;

  HomeCubit(this._getLiveChannels, this._getAnimeDetails)
    : super(HomeInitial());

  void fetchChannels() async {
    emit(HomeLoading());
    final result = await _getLiveChannels(NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(HomeLoaded(data.channelsMap, data.animeData)),
    );
  }

  void fetchAnimeDetails(String animeId) async {
    emit(AnimeDetailsLoading());
    final result = await _getAnimeDetails(animeId);
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(AnimeDetailsLoaded(data)),
    );
  }
}
