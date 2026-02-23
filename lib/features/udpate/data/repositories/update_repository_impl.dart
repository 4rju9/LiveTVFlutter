import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/udpate/data/datasources/update_remote_data_source.dart';
import 'package:live_tv/features/udpate/data/models/update_model.dart';
import 'package:live_tv/features/udpate/domain/repositories/update_repository.dart';

class UpdateRepositoryImpl implements UpdateRepository {
  final UpdateRemoteDataSource remoteDataSource;

  UpdateRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UpdateModel>> checkUpdate() async {
    try {
      final updateInfo = await remoteDataSource.getLatestVersion();
      return Right(updateInfo);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
