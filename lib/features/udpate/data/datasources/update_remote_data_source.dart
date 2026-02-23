import 'package:dio/dio.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/features/udpate/data/models/update_model.dart';

abstract class UpdateRemoteDataSource {
  Future<UpdateModel> getLatestVersion();
}

class UpdateRemoteDataSourceImpl implements UpdateRemoteDataSource {
  final Dio dio;
  UpdateRemoteDataSourceImpl(this.dio);

  @override
  Future<UpdateModel> getLatestVersion() async {
    try {
      final response = await dio.get(
        'https://livetv.4rju9.workers.dev/livetv/update',
      );
      return UpdateModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Failed to check for updates.');
    }
  }
}
