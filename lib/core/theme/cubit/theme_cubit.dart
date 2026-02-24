import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:live_tv/core/app_secrets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeData> {
  final SharedPreferences sharedPreferences;

  ThemeCubit({required this.sharedPreferences})
    : super(
        themeList[sharedPreferences.getInt(
              AppSecrets.prefsKeySelectedThemeIndex,
            ) ??
            0],
      );

  static final List<ThemeData> themeList = [
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BEF7)),
      useMaterial3: true,
    ),
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 149, 95, 73),
      ),
      useMaterial3: true,
    ),
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF3B60D)),
      useMaterial3: true,
    ),
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 109, 49, 169),
      ),
      useMaterial3: true,
    ),
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF90576)),
      useMaterial3: true,
    ),
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 39, 38, 38),
      ),
      useMaterial3: true,
    ),
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 54, 35, 87),
      ),
      useMaterial3: true,
    ),
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 53, 178, 128),
      ),
      useMaterial3: true,
    ),
  ];

  void changeTheme(int index) {
    if (index >= 0 && index < themeList.length) {
      sharedPreferences.setInt(AppSecrets.prefsKeySelectedThemeIndex, index);
      emit(themeList[index]);
    }
  }
}
