import 'package:flutter_bloc/flutter_bloc.dart';

class PremiumState {
  final bool isPremium;
  PremiumState({required this.isPremium});
}

class PremiumCubit extends Cubit<PremiumState> {
  PremiumCubit() : super(PremiumState(isPremium: false));

  void activatePremium() {
    emit(PremiumState(isPremium: true));
  }

  void revokePremium() {
    emit(PremiumState(isPremium: false));
  }
}
