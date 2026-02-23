import 'package:live_tv/features/splash/domain/repositories/update_repository.dart';

class CheckUpdateUseCase {
  final UpdateRepository repository;
  CheckUpdateUseCase(this.repository);

  Future call() => repository.checkUpdate();
}
