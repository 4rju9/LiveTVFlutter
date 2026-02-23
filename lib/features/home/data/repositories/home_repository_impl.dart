import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/home/data/datasources/home_remote_data_source.dart';
import 'package:live_tv/features/home/domain/entities/home_data_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, HomeDataEntity>> getLiveChannels() async {
    try {
      final data = await remoteDataSource.fetchAllLiveChannels();
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
