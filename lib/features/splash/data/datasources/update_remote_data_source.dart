import 'package:dio/dio.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/splash/data/models/update_model.dart';

abstract class UpdateRemoteDataSource {
  Future<UpdateModel> getLatestVersion();
}

class UpdateRemoteDataSourceImpl implements UpdateRemoteDataSource {
  final Dio dio;
  UpdateRemoteDataSourceImpl(this.dio);

  @override
  Future<UpdateModel> getLatestVersion() async {
    try {
      final response = await dio.get(AppSecrets.liveTvUpdateEndpoint);
      return UpdateModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Failed to check for updates.');
    }
  }
}
