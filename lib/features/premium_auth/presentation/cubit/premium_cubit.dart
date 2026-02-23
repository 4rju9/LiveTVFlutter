import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:live_tv/features/premium_auth/domain/usecases/validate_premium_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PremiumState {}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumStatus extends PremiumState {
  final bool isPremium;
  PremiumStatus({required this.isPremium});
}

class PremiumError extends PremiumState {
  final String message;
  PremiumError(this.message);
}

class PremiumCubit extends Cubit<PremiumState> {
  final ValidatePremiumKey validatePremiumKey;
  final SharedPreferences sharedPreferences;

  PremiumCubit({
    required this.validatePremiumKey,
    required this.sharedPreferences,
  }) : super(PremiumInitial());

  void checkPremiumStatus() {
    // Use AppSecrets.prefsKeyIsPremium instead
    final isPremium =
        sharedPreferences.getBool(AppSecrets.prefsKeyIsPremium) ?? false;
    emit(PremiumStatus(isPremium: isPremium));
  }

  Future<void> activatePremium(String key) async {
    emit(PremiumLoading());

    final result = await validatePremiumKey(key);

    result.fold((failure) => emit(PremiumError(failure.message)), (
      success,
    ) async {
      // Use AppSecrets.prefsKeyIsPremium instead
      await sharedPreferences.setBool(AppSecrets.prefsKeyIsPremium, true);
      emit(PremiumStatus(isPremium: true));
    });
  }

  void continueFree() {
    emit(PremiumStatus(isPremium: false));
  }
}
