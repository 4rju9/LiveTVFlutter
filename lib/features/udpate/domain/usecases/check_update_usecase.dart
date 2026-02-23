import 'package:live_tv/features/udpate/domain/repositories/update_repository.dart';

class CheckUpdateUseCase {
  final UpdateRepository repository;
  CheckUpdateUseCase(this.repository);

  Future call() => repository.checkUpdate();
}
