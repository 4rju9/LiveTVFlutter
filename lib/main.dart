import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/core/theme/cubit/theme_cubit.dart';
import 'package:live_tv/features/premium_auth/presentation/cubit/premium_cubit.dart';
import 'package:live_tv/features/splash/presentation/cubit/update_cubit.dart';
import 'package:live_tv/features/splash/presentation/pages/splash_page.dart';
import 'package:live_tv/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<UpdateCubit>()),
        BlocProvider(create: (_) => sl<PremiumCubit>()),
      ],
      child: const LiveTvApp(),
    ),
  );
}

class LiveTvApp extends StatelessWidget {
  const LiveTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp(
          title: 'LiveTV',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const SplashPage(),
        );
      },
    );
  }
}
