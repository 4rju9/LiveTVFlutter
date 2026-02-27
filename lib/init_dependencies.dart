import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:live_tv/core/theme/cubit/theme_cubit.dart';
import 'package:live_tv/features/home/data/datasources/home_local_data_source.dart';
import 'package:live_tv/features/home/domain/usecases/search_anime.dart';
import 'package:live_tv/features/home/data/datasources/home_remote_data_source.dart';
import 'package:live_tv/features/home/data/repositories/home_repository_impl.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';
import 'package:live_tv/features/home/domain/usecases/get_cached_live_channels.dart';
import 'package:live_tv/features/home/domain/usecases/get_anime_details.dart';
import 'package:live_tv/features/home/domain/usecases/get_live_channels.dart';
import 'package:live_tv/features/home/presentation/cubit/anime_details_cubit.dart';
import 'package:live_tv/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_tv/features/player/data/datasources/player_remote_data_source.dart';
import 'package:live_tv/features/player/data/repositories/player_repository_impl.dart';
import 'package:live_tv/features/player/domain/repositories/player_repository.dart';
import 'package:live_tv/features/player/domain/usecases/get_anime_stream.dart';
import 'package:live_tv/features/player/domain/usecases/get_anime_servers.dart';
import 'package:live_tv/features/player/presentation/cubit/player_cubit.dart';
import 'package:live_tv/features/premium_auth/domain/usecases/validate_premium_key.dart';
import 'package:live_tv/features/premium_auth/presentation/cubit/premium_cubit.dart';
import 'package:live_tv/features/splash/data/datasources/update_remote_data_source.dart';
import 'package:live_tv/features/splash/data/repositories/update_repository_impl.dart';
import 'package:live_tv/features/splash/domain/repositories/update_repository.dart';
import 'package:live_tv/features/splash/domain/usecases/check_update_usecase.dart';
import 'package:live_tv/features/splash/presentation/cubit/update_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  await Hive.initFlutter();
  final box = await Hive.openBox('blogs');

  sl.registerLazySingleton(() => box);
  sl.registerLazySingleton(() => sharedPreferences);

  _initCore();
  _initSplashFeature();
  _initPremiumAuth();
  _initHome();
  _initAnime();
  _initPlayer();
}

void _initCore() {
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => ThemeCubit(sharedPreferences: sl()));
}

void _initHome() {
  sl
    ..registerFactory<HomeLocalDataSource>(() => HomeLocalDataSourceImpl())
    ..registerFactory<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl(), sl()),
    )
    ..registerFactory<HomeRepository>(() => HomeRepositoryImpl(sl(), sl()))
    ..registerFactory(() => GetCachedLiveChannels(sl()))
    ..registerFactory(() => GetLiveChannels(sl()))
    ..registerFactory(() => GetAnimeDetails(sl()))
    ..registerFactory(() => SearchAnime(sl()))
    ..registerFactory(() => AnimeDetailsCubit(sl()))
    ..registerLazySingleton(() => HomeCubit(sl(), sl(), sl()));
}

void _initPlayer() {
  sl
    ..registerFactory<PlayerRemoteDataSource>(
      () => PlayerRemoteDataSourceImpl(sl()),
    )
    ..registerFactory<PlayerRepository>(() => PlayerRepositoryImpl(sl()))
    ..registerFactory(() => GetAnimeServers(sl()))
    ..registerFactory(() => GetAnimeStream(sl()))
    ..registerLazySingleton(
      () => PlayerCubit(getAnimeStream: sl(), getAnimeServers: sl()),
    );
}

void _initAnime() {}

void _initPremiumAuth() {
  sl
    ..registerFactory(() => ValidatePremiumKey())
    ..registerLazySingleton(
      () => PremiumCubit(validatePremiumKey: sl(), sharedPreferences: sl()),
    );
}

void _initSplashFeature() {
  sl
    ..registerFactory<UpdateRemoteDataSource>(
      () => UpdateRemoteDataSourceImpl(sl()),
    )
    ..registerFactory<UpdateRepository>(() => UpdateRepositoryImpl(sl()))
    ..registerFactory(() => CheckUpdateUseCase(sl()))
    ..registerLazySingleton(() => UpdateCubit(checkUpdateUseCase: sl()));
}
