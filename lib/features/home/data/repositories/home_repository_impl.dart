import 'package:dartz/dartz.dart';
import 'package:live_tv/core/error/exceptions.dart';
import 'package:live_tv/core/error/failures.dart';
import 'package:live_tv/features/home/data/datasources/home_remote_data_source.dart';
import 'package:live_tv/features/home/domain/entities/live_channel_entity.dart';
import 'package:live_tv/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Map<String, List<LiveChannelEntity>>>>
  getLiveChannels() async {
    try {
      final result = await remoteDataSource.fetchAllLiveChannels();
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
