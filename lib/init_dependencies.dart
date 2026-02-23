import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:live_tv/core/theme/cubit/theme_cubit.dart';
import 'package:live_tv/features/premium_auth/domain/usecases/validate_premium_key.dart';
import 'package:live_tv/features/premium_auth/presentation/cubit/premium_cubit.dart';
import 'package:live_tv/features/udpate/data/datasources/update_remote_data_source.dart';
import 'package:live_tv/features/udpate/data/repositories/update_repository_impl.dart';
import 'package:live_tv/features/udpate/domain/repositories/update_repository.dart';
import 'package:live_tv/features/udpate/domain/usecases/check_update_usecase.dart';
import 'package:live_tv/features/udpate/presentation/cubit/update_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initCore();
  _initUpdateFeature();
  _initPremiumAuth();
  _initLiveTv();
  _initAnime();
}

void _initCore() {
  serviceLocator.registerLazySingleton(() => Dio());
  serviceLocator.registerLazySingleton(() => ThemeCubit());
}

void _initLiveTv() {}

void _initAnime() {}

void _initPremiumAuth() {
  serviceLocator
    ..registerFactory(() => ValidatePremiumKey())
    ..registerLazySingleton(() => PremiumCubit());
}

void _initUpdateFeature() {
  serviceLocator
    ..registerFactory<UpdateRemoteDataSource>(
      () => UpdateRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<UpdateRepository>(
      () => UpdateRepositoryImpl(serviceLocator()),
    )
    ..registerFactory(() => CheckUpdateUseCase(serviceLocator()))
    ..registerLazySingleton(
      () => UpdateCubit(checkUpdateUseCase: serviceLocator()),
    );
}
