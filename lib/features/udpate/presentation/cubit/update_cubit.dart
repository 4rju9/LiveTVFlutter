import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/udpate/data/models/update_model.dart';
import 'package:live_tv/features/udpate/domain/usecases/check_update_usecase.dart';

abstract class UpdateState {}

class UpdateInitial extends UpdateState {}

class UpdateLoading extends UpdateState {}

class UpdateFound extends UpdateState {
  final UpdateModel updateInfo;
  UpdateFound(this.updateInfo);
}

class NoUpdateFound extends UpdateState {}

class UpdateError extends UpdateState {
  final String message;
  UpdateError(this.message);
}

class UpdateCubit extends Cubit<UpdateState> {
  final CheckUpdateUseCase checkUpdateUseCase;

  UpdateCubit({required this.checkUpdateUseCase}) : super(UpdateInitial());

  Future<void> checkForUpdates(int currentVersionCode) async {
    emit(UpdateLoading());
    final result = await checkUpdateUseCase();

    result.fold((failure) => emit(UpdateError(failure.message)), (updateModel) {
      if (updateModel.latestVersionCode > currentVersionCode) {
        emit(UpdateFound(updateModel));
      } else {
        emit(NoUpdateFound());
      }
    });
  }
}
