import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:live_tv/core/theme/cubit/theme_cubit.dart';
import 'package:live_tv/features/premium_auth/domain/usecases/validate_premium_key.dart';
import 'package:live_tv/features/premium_auth/presentation/cubit/premium_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initCore();
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
