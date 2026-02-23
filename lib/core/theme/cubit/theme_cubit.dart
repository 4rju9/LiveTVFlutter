import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_themeList[0]);

  static final List<ThemeData> _themeList = [
    ThemeData(primaryColor: Color(0xFF00BEF7), brightness: Brightness.dark),
    ThemeData(primaryColor: Colors.brown, brightness: Brightness.dark),
  ];

  void changeTheme(int index) {
    if (index >= 0 && index < _themeList.length) {
      emit(_themeList[index]);
    }
  }
}
