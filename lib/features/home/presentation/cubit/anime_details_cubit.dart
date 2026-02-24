import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/home/domain/entities/anime_details_entity.dart';
import 'package:live_tv/features/home/domain/usecases/get_anime_details.dart';

abstract class AnimeDetailsState {}

class AnimeDetailsInitial extends AnimeDetailsState {}

class AnimeDetailsLoading extends AnimeDetailsState {}

class AnimeDetailsLoaded extends AnimeDetailsState {
  final AnimeDetailsEntity details;
  AnimeDetailsLoaded(this.details);
}

class AnimeDetailsError extends AnimeDetailsState {
  final String message;
  AnimeDetailsError(this.message);
}

class AnimeDetailsCubit extends Cubit<AnimeDetailsState> {
  final GetAnimeDetails _getAnimeDetails;

  AnimeDetailsCubit(this._getAnimeDetails) : super(AnimeDetailsInitial());

  void fetchAnimeDetails(String animeId) async {
    emit(AnimeDetailsLoading());
    final result = await _getAnimeDetails(animeId);
    result.fold(
      (failure) => emit(AnimeDetailsError(failure.message)),
      (data) => emit(AnimeDetailsLoaded(data)),
    );
  }
}
